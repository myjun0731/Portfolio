<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    List<ExamPaper> papers = (List<ExamPaper>) request.getAttribute("papers");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>연·회차 바로가기</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; background: #fdfdfd; }
        header { display: flex; justify-content: space-between; align-items: center; }
        .grid { display: grid; gap: 16px; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); margin-top: 20px; }
        .card { background: #fff; border-radius: 10px; border: 1px solid #ddd; padding: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); position: relative; }
        .badge { position: absolute; top: 12px; right: 12px; background: #4c51bf; color: #fff; padding: 4px 8px; border-radius: 12px; font-size: 12px; }
        .warning { color: #c05621; font-size: 12px; margin-top: 8px; }
        button { background: #4c51bf; color: #fff; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; }
    </style>
</head>
<body>
<header>
    <h1>연·회차 바로가기</h1>
    <a href="${pageContext.request.contextPath}/main">메인으로</a>
</header>
<div class="grid">
    <% for (ExamPaper paper : papers) { %>
        <div class="card">
            <div class="badge"><%= paper.getMode() %></div>
            <h2><%= HtmlUtil.escape(paper.getName()) %></h2>
            <p><%= paper.getExamYear() %>년 <%= paper.getExamRound() %>회</p>
            <p>총 <%= paper.getQuestionCount() %>문항 · 제한시간 <%= paper.getTimeLimitMin() %>분</p>
            <% if (paper.isHasMissingQuestions()) { %>
                <p class="warning">일부 문항이 누락되어 대체 문항을 사용합니다.</p>
            <% } %>
            <form method="post" action="${pageContext.request.contextPath}/exam/start">
                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                <button type="submit">바로 응시</button>
            </form>
        </div>
    <% } %>
</div>
</body>
</html>
