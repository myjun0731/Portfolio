<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    List<ExamPaper> papers = (List<ExamPaper>) request.getAttribute("papers");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>메인 - CBT</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; background: #f4f6fb; }
        h1 { color: #667eea; }
        a { color: #667eea; text-decoration: none; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; }
        .papers { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 20px; margin-top: 30px; }
        .paper-card { background: white; padding: 20px; border-radius: 12px; border: 1px solid #e0e4f0; box-shadow: 0 12px 30px rgba(102, 126, 234, 0.08); }
        .paper-card h3 { margin-bottom: 10px; color: #374151; }
        .paper-card p { color: #6b7280; margin-bottom: 16px; }
        button { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; }
        button:hover { opacity: 0.9; }
        .empty { color: #6b7280; text-align: center; padding: 60px 0; background: white; border-radius: 12px; border: 1px dashed #cbd5f5; }
    </style>
</head>
<body>
    <div class="top-bar">
        <h1>환영합니다, <%= (user != null) ? user.getName() : "사용자" %>님!</h1>
        <div>
            <a href="<%= request.getContextPath() %>/logout">로그아웃</a>
        </div>
    </div>

    <h2>📋 기출 회차</h2>
    <div class="papers">
        <% if (papers != null && !papers.isEmpty()) { %>
            <% for (ExamPaper paper : papers) { %>
                <div class="paper-card">
                    <h3><%= paper.getName() %></h3>
                    <p>시간: <%= paper.getTimeLimitMin() %>분</p>
                    <form method="post" action="<%= request.getContextPath() %>/exam/start">
                        <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                        <button type="submit">시험 시작</button>
                    </form>
                </div>
            <% } %>
        <% } else { %>
            <div class="empty">등록된 시험지가 없습니다.</div>
        <% } %>
    </div>
</body>
</html>
