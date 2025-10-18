package com.cbt.servlet;

import com.cbt.model.User;
import com.cbt.service.QuestionService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/questions/feedback")
public class QuestionFeedbackServlet extends HttpServlet {
    private final QuestionService questionService = new QuestionService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        int qId = Integer.parseInt(req.getParameter("qid"));
        String type = req.getParameter("type");
        String message = req.getParameter("message");
        questionService.submitFeedback(user.getUserId(), qId, type == null ? "기타" : type, message == null ? "" : message);
        String referer = req.getHeader("Referer");
        if (referer == null) {
            referer = req.getContextPath() + "/questions";
        }
        resp.sendRedirect(referer + "#q" + qId);
    }
}
