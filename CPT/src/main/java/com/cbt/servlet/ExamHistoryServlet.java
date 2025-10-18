package com.cbt.servlet;

import com.cbt.model.ExamSession;
import com.cbt.model.User;
import com.cbt.service.ExamService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/exam/history")
public class ExamHistoryServlet extends HttpServlet {
    private final ExamService examService = new ExamService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        List<ExamSession> sessions = examService.history(user.getUserId());
        String modeFilter = req.getParameter("mode");
        if (modeFilter != null && !modeFilter.isBlank()) {
            sessions = sessions.stream()
                    .filter(sess -> modeFilter.equalsIgnoreCase(sess.getMode()))
                    .collect(Collectors.toList());
        }
        double averageScore = sessions.stream()
                .map(ExamSession::getScore)
                .filter(score -> score != null)
                .mapToInt(Integer::intValue)
                .average()
                .orElse(0);
        int bestScore = sessions.stream()
                .map(ExamSession::getScore)
                .filter(score -> score != null)
                .max(Integer::compareTo)
                .orElse(0);
        ExamSession lastSession = sessions.stream()
                .findFirst()
                .orElse(null);
        Map<String, Long> modeBreakdown = sessions.stream()
                .collect(Collectors.groupingBy(ExamSession::getMode, Collectors.counting()));
        List<ExamSession> podium = sessions.stream()
                .filter(sess -> sess.getScore() != null)
                .sorted(Comparator.comparing(ExamSession::getScore, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(3)
                .collect(Collectors.toList());
        req.setAttribute("sessions", sessions);
        req.setAttribute("averageScore", Math.round(averageScore));
        req.setAttribute("bestScore", bestScore);
        req.setAttribute("lastSession", lastSession);
        req.setAttribute("modeBreakdown", modeBreakdown);
        req.setAttribute("podium", podium);
        req.setAttribute("activeNav", "history");
        req.getRequestDispatcher("/WEB-INF/jsp/exam-history.jsp").forward(req, resp);
    }
}
