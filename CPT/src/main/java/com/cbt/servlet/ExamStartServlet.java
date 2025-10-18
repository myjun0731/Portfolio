package com.cbt.servlet;

import com.cbt.model.ExamPaper;
import com.cbt.model.ExamSession;
import com.cbt.model.Subject;
import com.cbt.model.User;
import com.cbt.service.ExamService;
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
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/exam/start")
public class ExamStartServlet extends HttpServlet {
    private final ExamService examService = new ExamService();
    private final AppDataStore store = AppDataStore.getInstance();
    private final QuestionService questionService = new QuestionService();
    private final StudyService studyService = new StudyService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        List<ExamPaper> papers = store.getPapers().stream()
                .sorted(Comparator.comparing(ExamPaper::getExamYear, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(ExamPaper::getExamRound, Comparator.nullsLast(Comparator.reverseOrder())))
                .collect(Collectors.toList());
        req.setAttribute("papers", papers);
        req.setAttribute("paperCount", papers.size());
        req.setAttribute("subjects", questionService.getSubjects());
        req.setAttribute("favoriteCount", questionService.getFavorites(user.getUserId()).size());
        req.setAttribute("wrongCount", studyService.getWrongNotes(user.getUserId()).size());
        req.setAttribute("unitSummaries", studyService.getUnitSummaries(user.getUserId()));
        req.setAttribute("activeNav", "papers");
        req.getRequestDispatcher("/WEB-INF/jsp/exam-start.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String action = req.getParameter("action");
        try {
            ExamSession examSession;
            if ("mock".equalsIgnoreCase(action)) {
                int count = parseInt(req.getParameter("mockCount"), 10);
                Integer subjectId = parseNullableInt(req.getParameter("mockSubject"));
                Integer diff = parseNullableInt(req.getParameter("mockDiff"));
                boolean strict = checked(req, "mockStrict");
                boolean shuffle = !checked(req, "mockOrderFixed");
                examSession = examService.startMockSession(user, count, subjectId, diff, strict, shuffle);
            } else if ("diagnostic".equalsIgnoreCase(action)) {
                int subjectId = parseInt(req.getParameter("diagSubject"), 1);
                boolean strict = true;
                boolean shuffle = false;
                examSession = examService.startMockSession(user, 8, subjectId, null, strict, shuffle);
                examSession.setOriginLabel("진단 테스트");
            } else if ("wrong".equalsIgnoreCase(action)) {
                boolean strict = checked(req, "wrongStrict");
                boolean shuffle = !checked(req, "wrongOrderFixed");
                examSession = examService.startWrongRetrySession(user, strict, shuffle);
            } else {
                int paperId = Integer.parseInt(req.getParameter("paperId"));
                boolean strict = checked(req, "strictMode");
                boolean shuffle = !checked(req, "fixedOrder");
                examSession = examService.startSession(user, paperId, strict, shuffle);
            }
            resp.sendRedirect(req.getContextPath() + "/exam/play?sid=" + examSession.getSessId());
        } catch (IllegalArgumentException | IllegalStateException ex) {
            req.setAttribute("errorMessage", ex.getMessage());
            doGet(req, resp);
        }
    }

    private boolean checked(HttpServletRequest req, String name) {
        return "on".equalsIgnoreCase(req.getParameter(name));
    }

    private int parseInt(String value, int def) {
        if (value == null || value.isBlank()) {
            return def;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return def;
        }
    }

    private Integer parseNullableInt(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
