package com.cbt.servlet;

import com.cbt.model.ExamReport;
import com.cbt.service.ExamService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@WebServlet("/exam/result")
public class ExamResultServlet extends HttpServlet {
    private final ExamService examService = new ExamService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ExamReport report = (ExamReport) req.getSession().getAttribute("lastReport");
        if (report == null) {
            int sessId = Integer.parseInt(req.getParameter("sid"));
            report = examService.submit(sessId);
        }
        com.cbt.store.AppDataStore store = com.cbt.store.AppDataStore.getInstance();
        Map<Integer, com.cbt.model.ExamResp> responses = store.getResponses(report.getSession().getSessId());
        req.getSession().removeAttribute("lastReport");
        req.setAttribute("report", report);
        req.setAttribute("responses", responses);
        req.setAttribute("questions", examService.loadQuestionsForSession(report.getSession()));
        req.setAttribute("unitAccuracies", report.getUnitAccuracies());
        req.setAttribute("tagWeaknesses", report.getTagWeaknesses());
        req.setAttribute("activeNav", "dashboard");
        req.getRequestDispatcher("/WEB-INF/jsp/exam-result.jsp").forward(req, resp);
    }
}
