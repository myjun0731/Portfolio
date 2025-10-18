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
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <h1>안녕하세요, <%= user.getName() %>님</h1>
        <p class="subtitle">문항 탐색부터 CBT 응시와 학습 리포트까지 하나의 허브에서 이어서 진행해 보세요.</p>
        <div class="hero-actions">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/exam/start">CBT 응시 시작</a>
            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/questions">문항 탐색 열기</a>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <div>
                <h2>바로 응시 가능한 기출 회차</h2>
                <p class="subtitle">최신 회차를 우선 정렬했어요. 원하는 회차를 선택하면 동일 시드로 세션이 생성됩니다.</p>
            </div>
            <div class="section-actions">
                <span class="pill">총 <%= papers != null ? papers.size() : 0 %>회차</span>
            </div>
        </div>
        <% if (papers != null && !papers.isEmpty()) { %>
            <div class="card-grid">
                <% for (ExamPaper paper : papers) { %>
                    <div class="card">
                        <span class="badge"><%= paper.getExamYear() %>년 <%= paper.getExamRound() %>회</span>
                        <h3 style="margin-top:18px; font-size:21px;"> <%= paper.getName() %></h3>
                        <p class="meta" style="margin-top:10px;">제한시간 <strong><%= paper.getTimeLimitMin() %>분</strong> · 문항 <strong><%= paper.getQuestionCount() %>개</strong></p>
                        <% if (paper.isHasMissingQuestions()) { %>
                            <p class="meta" style="margin-top:12px; color: var(--warning);">일부 문항 누락 → 대체 문항이 자동 적용됩니다.</p>
                        <% } %>
                        <form method="post" action="${pageContext.request.contextPath}/exam/start" style="margin-top:22px; display:flex; flex-direction:column; gap:12px;">
                            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                            <button type="submit" class="btn btn-primary" style="width:100%;">이 회차 응시하기</button>
                            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/papers/quick">상세 보기</a>
                        </form>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="alert">등록된 시험지가 없습니다. 운영자 메뉴에서 회차를 추가해주세요.</div>
        <% } %>
    </section>
</main>
</body>
</html>
