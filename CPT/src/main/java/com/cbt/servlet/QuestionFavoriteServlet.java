package com.cbt.servlet;

import com.cbt.model.User;
import com.cbt.store.AppDataStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/questions/favorite")
public class QuestionFavoriteServlet extends HttpServlet {
    private final AppDataStore store = AppDataStore.getInstance();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        int qId = Integer.parseInt(req.getParameter("qid"));
        store.toggleFavorite(user.getUserId(), qId);
        String referer = req.getHeader("Referer");
        if (referer == null) {
            referer = req.getContextPath() + "/questions";
        }
        resp.sendRedirect(referer);
    }
}
