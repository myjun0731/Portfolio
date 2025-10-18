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
    <title>대시보드 - 정보처리산업기사 CBT</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="app-shell">
    <header class="page-header">
        <div>
            <h1>안녕하세요, <%= user.getName() %>님</h1>
            <p class="subtitle">문항 탐색부터 CBT 응시, 학습 리포트까지 한 곳에서 관리하세요.</p>
        </div>
        <nav class="nav-links">
            <a class="nav-link active" href="${pageContext.request.contextPath}/main">대시보드</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/q/list.jsp">문항 탐색</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/paper/gii.jsp">연·회차</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/wrong">오답 노트</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/goal">학습 목표</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/logout">로그아웃</a>
        </nav>
    </header>

    <section class="card">
        <div class="card-header">
            <div>
                <h2>바로 응시 가능한 기출 회차</h2>
                <p class="subtitle">최신 회차를 우선으로 정렬했습니다. 원하는 회차를 선택해 CBT를 시작하세요.</p>
            </div>
        </div>
        <% if (papers != null && !papers.isEmpty()) { %>
            <div class="card-grid">
                <% for (ExamPaper paper : papers) { %>
                    <div class="card" style="box-shadow:none;border:1px solid var(--border);">
                        <span class="badge"><%= paper.getExamYear() %>년 <%= paper.getExamRound() %>회</span>
                        <h3 style="margin-top:16px; font-size:20px;"><%= paper.getName() %></h3>
                        <p class="meta" style="margin-top:8px;">제한시간 <strong><%= paper.getTimeLimitMin() %>분</strong> · 문항 <strong><%= paper.getQuestionCount() %>개</strong></p>
                        <% if (paper.isHasMissingQuestions()) { %>
                            <p class="meta" style="margin-top:12px; color: var(--warning);">일부 문항 누락 → 대체 문항이 자동 적용됩니다.</p>
                        <% } %>
                        <form method="post" action="${pageContext.request.contextPath}/exam/start" style="margin-top:20px;">
                            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                            <button type="submit" class="btn btn-primary" style="width:100%;">시험 시작</button>
                        </form>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="alert">등록된 시험지가 없습니다. 운영자 메뉴에서 회차를 추가해주세요.</div>
        <% } %>
    </section>
</div>
</body>
</html>
