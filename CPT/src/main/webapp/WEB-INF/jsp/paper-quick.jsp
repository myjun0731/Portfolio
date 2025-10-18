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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="app-shell">
    <header class="page-header">
        <div>
            <h1>🗂 연·회차 바로가기</h1>
            <p class="subtitle">사전 구성된 CBT 시험지를 선택해 즉시 응시하세요.</p>
        </div>
        <nav class="nav-links">
            <a class="nav-link" href="${pageContext.request.contextPath}/main">대시보드</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/q/list.jsp">문항 탐색</a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/paper/gii.jsp">연·회차</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/wrong">오답 노트</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/goal">학습 목표</a>
        </nav>
    </header>

    <section class="card">
        <div class="card-header">
            <div>
                <h2>기출 회차 모음</h2>
                <p class="subtitle">시험 모드는 "G"(기출) 기준으로 구성되었습니다. 응시 전에 결측 여부를 확인하세요.</p>
            </div>
        </div>
        <div class="card-grid">
            <% for (ExamPaper paper : papers) { %>
                <div class="card" style="box-shadow:none;border:1px solid var(--border);">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <span class="badge"><%= HtmlUtil.escape(paper.getMode()) %> 모드</span>
                        <span class="meta">ID: <%= paper.getPaperId() %></span>
                    </div>
                    <h3 style="margin-top:16px; font-size:20px;"><%= HtmlUtil.escape(paper.getName()) %></h3>
                    <p class="meta" style="margin-top:8px;">총 <strong><%= paper.getQuestionCount() %></strong> 문항 · 제한시간 <strong><%= paper.getTimeLimitMin() %>분</strong></p>
                    <p class="meta" style="margin-top:4px;">출제년도 <%= paper.getExamYear() %>년 / <%= paper.getExamRound() %>회</p>
                    <% if (paper.isHasMissingQuestions()) { %>
                        <div class="alert warning" style="margin-top:16px;">일부 문항이 누락되어 대체 문항이 자동 매핑됩니다.</div>
                    <% } %>
                    <form method="post" action="${pageContext.request.contextPath}/exam/start" style="margin-top:18px;">
                        <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                        <button type="submit" class="btn btn-primary" style="width:100%;">바로 응시</button>
                    </form>
                </div>
            <% } %>
        </div>
    </section>
</div>
</body>
</html>
