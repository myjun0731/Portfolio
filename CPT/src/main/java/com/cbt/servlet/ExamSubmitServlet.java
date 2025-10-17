package com.cbt.servlet;

import com.cbt.model.ExamReport;
import com.cbt.service.ExamService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/exam/submit")
public class ExamSubmitServlet extends HttpServlet {
    private final ExamService examService = new ExamService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int sessId = Integer.parseInt(req.getParameter("sid"));
        ExamReport report = examService.submit(sessId);
        req.getSession().setAttribute("lastReport", report);
        resp.sendRedirect(req.getContextPath() + "/exam/result?sid=" + sessId);
    }
}
