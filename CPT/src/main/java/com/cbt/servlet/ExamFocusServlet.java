package com.cbt.servlet;

import com.cbt.model.ExamSession;
import com.cbt.store.AppDataStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;

@WebServlet("/exam/focus")
public class ExamFocusServlet extends HttpServlet {
    private final AppDataStore store = AppDataStore.getInstance();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int sessId = Integer.parseInt(req.getParameter("sid"));
        ExamSession session = store.findSession(sessId).orElse(null);
        if (session != null) {
            session.getFocusOutEvents().add(new Timestamp(System.currentTimeMillis()));
        }
        resp.setContentType("application/json");
        resp.getWriter().write("{\"status\":\"LOGGED\"}");
    }
}
