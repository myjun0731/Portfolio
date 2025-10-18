package com.cbt.servlet;

import com.cbt.model.ExamPaper;
import com.cbt.store.AppDataStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.NavigableMap;
import java.util.stream.Collectors;

@WebServlet("/main")
public class MainServlet extends HttpServlet {
    private final AppDataStore store = AppDataStore.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<ExamPaper> papers = store.getPapers().stream()
                    .sorted(Comparator.comparing(ExamPaper::getExamYear, Comparator.nullsLast(Comparator.reverseOrder()))
                            .thenComparing(ExamPaper::getExamRound, Comparator.nullsLast(Comparator.reverseOrder())))
                    .collect(Collectors.toList());
            request.setAttribute("papers", papers);
            request.setAttribute("questionTotal", store.getQuestions().size());
            request.setAttribute("unitTotal", store.getUnits().size());
            request.setAttribute("tagTotal", store.getTags().size());
            NavigableMap<java.time.LocalDate, Integer> history = store.getScoreHistory(1);
            request.setAttribute("scoreHistory", history);
            if (!history.isEmpty()) {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("M월 d일");
                request.setAttribute("latestScoreLabel",
                        history.lastKey().format(formatter) + " · " + history.lastEntry().getValue() + "점");
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
