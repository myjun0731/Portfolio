package com.cbt.servlet;

import com.cbt.model.Question;
import com.cbt.model.User;
import com.cbt.service.StudyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/study/wrong")
public class WrongNoteServlet extends HttpServlet {
    private final StudyService studyService = new StudyService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        List<Question> retry = studyService.buildRetrySet(user.getUserId());
        req.setAttribute("retry", retry);
        req.setAttribute("wrongNotes", studyService.getWrongNotes(user.getUserId()));
        req.setAttribute("activeNav", "wrong");
        req.getRequestDispatcher("/WEB-INF/jsp/study-wrong.jsp").forward(req, resp);
    }
}
