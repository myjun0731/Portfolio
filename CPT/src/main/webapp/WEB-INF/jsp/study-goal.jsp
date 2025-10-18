<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%
    GoalPlan goal = (GoalPlan) request.getAttribute("goal");
    java.util.NavigableMap<java.time.LocalDate, Integer> history = (java.util.NavigableMap<java.time.LocalDate, Integer>) request.getAttribute("history");
    if (history == null) {
        history = new java.util.TreeMap<>();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학습 목표 & 리포트</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Learning Coach</span>
            <h1>🎯 학습 목표 관리</h1>
            <p class="subtitle">목표 점수를 설정하고 회차별 성과를 추적하며 주간 추천 문제량을 확인하세요.</p>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>목표 점수 설정</h2>
        </div>
        <form method="post" class="goal-form">
            <div class="goal-grid">
                <label class="filter-field">
                    <span>목표 점수</span>
                    <input type="number" id="target" name="target" value="<%= goal != null ? goal.getTargetScore() : 70 %>" min="0" max="100" required>
                </label>
                <label class="filter-field">
                    <span>시험 예정일</span>
                    <input type="date" id="examDate" name="examDate" value="<%= goal != null ? goal.getExamDate() : java.time.LocalDate.now().plusMonths(1) %>" required>
                </label>
                <label class="filter-field">
                    <span>일일 추천 문제 수</span>
                    <input type="number" id="daily" name="daily" value="<%= goal != null ? goal.getDailyQuestionCount() : 20 %>" required>
                </label>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
        <div class="goal-callout">
            <strong>Tip.</strong> 목표일이 가까울수록 자동으로 추천 문제량이 증가하도록 설계되어 있습니다. 과도한 목표 설정을 피하려면 일일 추천량을 주 5일 기준으로 조정하세요.
        </div>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>회차별 점수 추이</h2>
            <div class="section-actions">
                <span class="pill">최근 <%= history.size() %>회차</span>
            </div>
        </div>
        <% if (history.isEmpty()) { %>
            <div class="alert warning">아직 저장된 결과가 없습니다. CBT 시험을 완료하면 자동으로 기록됩니다.</div>
        <% } else { %>
            <ol class="score-timeline">
                <% for (java.util.Map.Entry<java.time.LocalDate, Integer> entry : history.entrySet()) { %>
                    <li>
                        <span class="score-timeline__label"><%= entry.getKey() %></span>
                        <span class="score-timeline__value"><%= entry.getValue() %>점</span>
                    </li>
                <% } %>
            </ol>
        <% } %>
    </section>
</main>
</body>
</html>
