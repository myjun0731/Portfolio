package com.cbt.servlet;

import com.cbt.model.*;
import com.cbt.service.QuestionService;
import com.cbt.service.StudyService;
import com.cbt.store.AppDataStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.NavigableMap;
import java.util.stream.Collectors;

@WebServlet("/main")
public class MainServlet extends HttpServlet {
    private final AppDataStore store = AppDataStore.getInstance();
    private final StudyService studyService = new StudyService();
    private final QuestionService questionService = new QuestionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        try {
            List<ExamPaper> papers = store.getPapers().stream()
                    .sorted(Comparator.comparing(ExamPaper::getExamYear, Comparator.nullsLast(Comparator.reverseOrder()))
                            .thenComparing(ExamPaper::getExamRound, Comparator.nullsLast(Comparator.reverseOrder())))
                    .collect(Collectors.toList());
            request.setAttribute("papers", papers);
            request.setAttribute("questionTotal", store.getQuestions().size());
            request.setAttribute("unitTotal", store.getUnits().size());
            request.setAttribute("tagTotal", store.getTags().size());
            request.setAttribute("favoriteCount", questionService.getFavorites(user.getUserId()).size());
            request.setAttribute("wrongCount", studyService.getWrongNotes(user.getUserId()).size());
            request.setAttribute("studyPlan", studyService.buildStudyPlan(user.getUserId()));
            request.setAttribute("reminders", studyService.getReminders(user.getUserId()));
            request.setAttribute("badges", studyService.buildBadges(user.getUserId()));
            request.setAttribute("announcements", store.getAnnouncements());
            request.setAttribute("loginHistory", store.getRecentLogins(user.getUserId()));
            List<UnitSummary> unitSummaries = studyService.getUnitSummaries(user.getUserId());
            request.setAttribute("unitSummaries", unitSummaries);
            NavigableMap<java.time.LocalDate, Integer> history = studyService.getScoreHistory(user.getUserId());
            request.setAttribute("scoreHistory", history);
            request.setAttribute("scoreHistoryEntries", new java.util.ArrayList<>(history.entrySet()));
            if (!history.isEmpty()) {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("M월 d일");
                request.setAttribute("latestScoreLabel",
                        history.lastKey().format(formatter) + " · " + history.lastEntry().getValue() + "점");
                request.setAttribute("latestScore", history.lastEntry().getValue());
            }
            request.setAttribute("activeNav", "dashboard");
            request.getRequestDispatcher("/WEB-INF/jsp/main.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "메인 페이지 로딩 중 오류가 발생했습니다.");
            request.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(request, response);
        }
    }
}
