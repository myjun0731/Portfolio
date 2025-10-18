package com.cbt.servlet;

import com.cbt.model.Question;
import com.cbt.model.Subject;
import com.cbt.model.Unit;
import com.cbt.service.QuestionService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/questions")
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
        List<Subject> subjects = questionService.getSubjects();

        req.setAttribute("questions", questions);
        req.setAttribute("total", total);
        req.setAttribute("page", page);
        req.setAttribute("size", size);
        int pages = (int) Math.ceil(total / (double) size);
        req.setAttribute("totalPages", pages);
        req.setAttribute("units", units);
        req.setAttribute("tags", tags);
        req.setAttribute("subjects", subjects);
        Set<Integer> selectedTags = new HashSet<>();
        String[] tagParams = req.getParameterValues("tags");
        if (tagParams != null) {
            for (String tagParam : tagParams) {
                try {
                    selectedTags.add(Integer.parseInt(tagParam));
                } catch (NumberFormatException ignore) {
                }
            }
        }
        req.setAttribute("selectedTags", selectedTags);
        Integer selectedUnit = null;
        String unitParam = req.getParameter("unit");
        if (unitParam != null && !unitParam.isBlank()) {
            try {
                selectedUnit = Integer.parseInt(unitParam);
            } catch (NumberFormatException ignore) {
                selectedUnit = null;
            }
        }
        req.setAttribute("selectedUnit", selectedUnit);
        String tagMode = req.getParameter("tagMode");
        if (!"OR".equalsIgnoreCase(tagMode)) {
            tagMode = "AND";
        }
        req.setAttribute("tagMode", tagMode);
        Map<Integer, List<Unit>> unitsBySubject = new HashMap<>();
        Map<Integer, List<Unit>> unitsByParent = new HashMap<>();
        for (Unit unit : units) {
            unitsBySubject.computeIfAbsent(unit.getSubjectId(), k -> new ArrayList<>()).add(unit);
            Integer parentId = unit.getParentId();
            unitsByParent.computeIfAbsent(parentId != null ? parentId : 0, k -> new ArrayList<>()).add(unit);
        }
        Comparator<Unit> comparator = Comparator.comparing(Unit::getName, String.CASE_INSENSITIVE_ORDER);
        unitsBySubject.values().forEach(list -> list.sort(comparator));
        unitsByParent.values().forEach(list -> list.sort(comparator));
        req.setAttribute("unitsBySubject", unitsBySubject);
        req.setAttribute("unitsByParent", unitsByParent);
        req.setAttribute("activeNav", "questions");
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
