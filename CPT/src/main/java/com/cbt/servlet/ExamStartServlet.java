package com.cbt.servlet;

import com.cbt.model.ExamPaper;
import com.cbt.model.ExamSession;
import com.cbt.model.User;
import com.cbt.service.ExamService;
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<ExamPaper> papers = store.getPapers().stream()
                .sorted(Comparator.comparing(ExamPaper::getExamYear, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(ExamPaper::getExamRound, Comparator.nullsLast(Comparator.reverseOrder())))
                .collect(Collectors.toList());
        req.setAttribute("papers", papers);
        req.setAttribute("paperCount", papers.size());
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
        int paperId = Integer.parseInt(req.getParameter("paperId"));
        ExamSession examSession = examService.startSession(user, paperId);
        resp.sendRedirect(req.getContextPath() + "/exam/play?sid=" + examSession.getSessId());
    }
}
