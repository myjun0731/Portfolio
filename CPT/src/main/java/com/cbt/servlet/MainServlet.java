package com.cbt.servlet;

import com.cbt.model.ExamPaper;
import com.cbt.service.PaperService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/main")
public class MainServlet extends HttpServlet {
    private final PaperService paperService = new PaperService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<ExamPaper> papers = paperService.fetchRecentPapers();
            request.setAttribute("papers", papers);
            request.getRequestDispatcher("/WEB-INF/jsp/main.jsp").forward(request, response);
        } catch (Exception e) {
            log("Failed to load main dashboard", e);
            request.setAttribute("error", "메인 페이지 로딩 중 오류가 발생했습니다.");
            request.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(request, response);
        }
    }
}
