package com.cbt.servlet;

import com.cbt.model.GoalPlan;
import com.cbt.model.User;
import com.cbt.service.StudyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/study/goal")
public class GoalServlet extends HttpServlet {
    private final StudyService studyService = new StudyService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        GoalPlan goal = studyService.getGoal(user.getUserId());
        req.setAttribute("goal", goal);
        req.setAttribute("history", studyService.getScoreHistory(user.getUserId()));
        req.getRequestDispatcher("/WEB-INF/jsp/study-goal.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        int target = Integer.parseInt(req.getParameter("target"));
        LocalDate examDate = LocalDate.parse(req.getParameter("examDate"));
        int dailyCnt = Integer.parseInt(req.getParameter("daily"));
        studyService.updateGoal(user.getUserId(), target, examDate, dailyCnt);
        resp.sendRedirect(req.getContextPath() + "/study/goal");
    }
}
