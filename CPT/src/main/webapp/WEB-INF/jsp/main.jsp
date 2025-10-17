<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<ExamPaper> papers = (List<ExamPaper>) request.getAttribute("papers");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>메인 - CBT</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; }
        h1 { color: #667eea; }
        .papers { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; margin-top: 20px; }
        .paper-card { background: white; padding: 20px; border-radius: 8px; border: 2px solid #ddd; }
        .paper-card:hover { border-color: #667eea; }
        button { background: #667eea; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <h1>환영합니다, <%= user.getName() %>님!</h1>
    <nav>
        <a href="${pageContext.request.contextPath}/q/list.jsp">문항 탐색</a> |
        <a href="${pageContext.request.contextPath}/paper/gii.jsp">연·회차 바로가기</a> |
        <a href="${pageContext.request.contextPath}/study/wrong">오답 노트</a> |
        <a href="${pageContext.request.contextPath}/study/goal">목표/리포트</a> |
        <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
    </nav>

    <h2>📋 기출 회차</h2>
    <div class="papers">
        <% if (papers != null && !papers.isEmpty()) {
            for (ExamPaper paper : papers) { %>
                <div class="paper-card">
                    <h3><%= paper.getName() %></h3>
                    <p>시간: <%= paper.getTimeLimitMin() %>분</p>
                    <form method="post" action="${pageContext.request.contextPath}/exam/start">
                        <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                        <button type="submit">시험 시작</button>
                    </form>
                </div>
            <% }
        } else { %>
            <p>등록된 시험지가 없습니다.</p>
        <% } %>
    </div>
</body>
</html>
