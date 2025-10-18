package com.cbt.servlet;

import com.cbt.model.ExamPaper;
import com.cbt.store.AppDataStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/papers/quick")
public class PaperQuickServlet extends HttpServlet {
    private final AppDataStore store = AppDataStore.getInstance();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<ExamPaper> papers = store.getPapers().stream()
                .sorted(Comparator.comparing(ExamPaper::getExamYear, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(ExamPaper::getExamRound, Comparator.nullsLast(Comparator.reverseOrder())))
                .collect(Collectors.toList());
        req.setAttribute("papers", papers);
        req.setAttribute("paperCount", papers.size());
        req.setAttribute("activeNav", "papers");
        req.getRequestDispatcher("/WEB-INF/jsp/paper-quick.jsp").forward(req, resp);
    }
}
