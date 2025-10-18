package com.cbt.servlet;

import com.cbt.model.Question;
import com.cbt.model.StudyNote;
import com.cbt.model.Subject;
import com.cbt.model.Unit;
import com.cbt.model.UnitSummary;
import com.cbt.model.User;
import com.cbt.service.QuestionService;
import com.cbt.service.StudyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet("/questions")
public class QuestionListServlet extends HttpServlet {
    private final QuestionService questionService = new QuestionService();
    private final StudyService studyService = new StudyService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        Integer userId = user != null ? user.getUserId() : null;
        int page = parseInt(req.getParameter("page"), 0);
        int size = 20;
        Map<String, String[]> params = req.getParameterMap();
        List<Question> questions = questionService.search(params, page, size, userId);
        long total = questionService.count(params, userId);
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
        req.setAttribute("favoritesOnly", "Y".equalsIgnoreCase(req.getParameter("favorite")));
        Set<Integer> favorites = userId != null ? questionService.getFavorites(userId) : Set.of();
        req.setAttribute("favorites", favorites);
        Map<Integer, StudyNote> notes = new HashMap<>();
        if (userId != null) {
            for (Question question : questions) {
                StudyNote note = questionService.getStudyNote(userId, question.getQId());
                if (note != null) {
                    notes.put(question.getQId(), note);
                }
            }
        }
        req.setAttribute("notes", notes);
        Map<Integer, Integer> feedbackCounts = questions.stream()
                .collect(Collectors.toMap(Question::getQId,
                        q -> questionService.getFeedbackForQuestion(q.getQId()).size()));
        req.setAttribute("feedbackCounts", feedbackCounts);
        List<UnitSummary> unitSummaries = studyService.getUnitSummaries(userId != null ? userId : 0);
        req.setAttribute("unitSummaries", unitSummaries);

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
