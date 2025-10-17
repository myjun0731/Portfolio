package com.cbt.servlet;

import com.cbt.service.ExamService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/exam/answer")
public class ExamAnswerServlet extends HttpServlet {
    private final ExamService examService = new ExamService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int sessId = Integer.parseInt(req.getParameter("sid"));
        int qId = Integer.parseInt(req.getParameter("qid"));
        String chosen = req.getParameter("choice");
        boolean flag = "Y".equalsIgnoreCase(req.getParameter("flag"));
        int elapsed = parseInt(req.getParameter("elapsed"), 0);
        examService.recordAnswer(sessId, qId, chosen == null || chosen.isBlank() ? null : Integer.parseInt(chosen), flag, elapsed);
        resp.setContentType("application/json");
        resp.getWriter().write("{\"status\":\"OK\"}");
    }

    private int parseInt(String value, int def) {
        if (value == null || value.isBlank()) {
            return def;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return def;
        }
    }
}
