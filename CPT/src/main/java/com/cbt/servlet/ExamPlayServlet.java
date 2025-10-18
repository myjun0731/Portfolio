package com.cbt.servlet;

import com.cbt.model.ExamSession;
import com.cbt.model.Question;
import com.cbt.service.ExamService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/exam/play")
public class ExamPlayServlet extends HttpServlet {
    private final ExamService examService = new ExamService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int sessId = Integer.parseInt(req.getParameter("sid"));
        ExamSession session;
        try {
            session = examService.resumeSession(sessId);
        } catch (IllegalStateException ex) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, ex.getMessage());
            return;
        }
        List<Question> questions = examService.loadQuestionsForSession(session);
        req.setAttribute("examSession", session);
        req.setAttribute("questions", questions);
        req.setAttribute("remaining", examService.remainingSeconds(session));
        req.setAttribute("strictNavigation", session.isStrictNavigation());
        req.setAttribute("modeLabel", session.getOriginLabel());
        req.getRequestDispatcher("/WEB-INF/jsp/exam-play.jsp").forward(req, resp);
    }
}
