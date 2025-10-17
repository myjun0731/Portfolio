package com.cbt.servlet;

import com.cbt.model.Question;
import com.cbt.model.Unit;
import com.cbt.service.QuestionService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/q/list.jsp")
public class QuestionListServlet extends HttpServlet {
    private final QuestionService questionService = new QuestionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = parseInt(req.getParameter("page"), 0);
        int size = 20;
        Map<String, String[]> params = req.getParameterMap();
        List<Question> questions = questionService.search(params, page, size);
        long total = questionService.count(params);
        List<Unit> units = questionService.getUnits();
        List<com.cbt.model.Tag> tags = questionService.getTags();

        req.setAttribute("questions", questions);
        req.setAttribute("total", total);
        req.setAttribute("page", page);
        req.setAttribute("size", size);
        req.setAttribute("units", units);
        req.setAttribute("tags", tags);
        req.getRequestDispatcher("/WEB-INF/jsp/question-list.jsp").forward(req, resp);
    }

    private int parseInt(String value, int def) {
        if (value == null || value.isBlank()) {
            return def;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return def;
        }
    }
}
