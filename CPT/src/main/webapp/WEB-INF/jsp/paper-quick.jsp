<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    List<ExamPaper> papers = (List<ExamPaper>) request.getAttribute("papers");
    int totalPapers = papers != null ? papers.size() : 0;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>연·회차 바로가기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <h1>🗂 연·회차 바로가기</h1>
        <p class="subtitle">사전 구성된 CBT 시험지를 선택해 동일 시드로 즉시 응시하거나 시험 정보를 검토하세요.</p>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <div>
                <h2>기출 회차 모음</h2>
                <p class="subtitle">시험 모드는 "G"(기출) 기준으로 구성되었습니다. 응시 전에 결측 여부를 확인하세요.</p>
            </div>
            <div class="section-actions">
                <span class="pill">총 <%= totalPapers %>회차</span>
                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/questions">문항 탐색</a>
            </div>
        </div>
        <% if (papers != null && !papers.isEmpty()) { %>
            <div class="card-grid">
                <% for (ExamPaper paper : papers) { %>
                    <div class="card">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <span class="badge"><%= HtmlUtil.escape(paper.getMode()) %> 모드</span>
                            <span class="meta">ID: <%= paper.getPaperId() %></span>
                        </div>
                        <h3 style="margin-top:18px; font-size:21px;"><%= HtmlUtil.escape(paper.getName()) %></h3>
                        <p class="meta" style="margin-top:10px;">총 <strong><%= paper.getQuestionCount() %></strong> 문항 · 제한시간 <strong><%= paper.getTimeLimitMin() %>분</strong></p>
                        <p class="meta" style="margin-top:6px;">출제년도 <%= paper.getExamYear() %>년 / <%= paper.getExamRound() %>회</p>
                        <% if (paper.isHasMissingQuestions()) { %>
                            <div class="alert warning" style="margin-top:16px;">일부 문항이 누락되어 대체 문항이 자동 매핑됩니다.</div>
                        <% } %>
                        <form method="post" action="${pageContext.request.contextPath}/exam/start" style="margin-top:20px;">
                            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                            <button type="submit" class="btn btn-primary" style="width:100%;">바로 응시</button>
                        </form>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="alert warning">등록된 기출 시험지가 없습니다. 운영자 모드에서 회차를 추가해주세요.</div>
        <% } %>
    </section>
</main>
</body>
</html>
