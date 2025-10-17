package com.cbt.servlet;

import com.cbt.model.User;
import com.cbt.service.StudyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/study/review")
public class ReviewNoteServlet extends HttpServlet {
    private final StudyService studyService = new StudyService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        int qId = Integer.parseInt(req.getParameter("qid"));
        boolean starred = "Y".equalsIgnoreCase(req.getParameter("star"));
        String memo = req.getParameter("memo");
        studyService.saveReview(user.getUserId(), qId, starred, memo);
        resp.sendRedirect(req.getContextPath() + "/study/wrong");
    }
}
