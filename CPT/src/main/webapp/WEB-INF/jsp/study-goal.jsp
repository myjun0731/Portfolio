<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%
    GoalPlan goal = (GoalPlan) request.getAttribute("goal");
    java.util.NavigableMap<java.time.LocalDate, Integer> history = (java.util.NavigableMap<java.time.LocalDate, Integer>) request.getAttribute("history");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학습 목표 & 리포트</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="app-shell">
    <header class="page-header">
        <div>
            <h1>🎯 학습 목표 관리</h1>
            <p class="subtitle">목표 점수를 설정하고 회차별 성과를 추적하세요.</p>
        </div>
        <nav class="nav-links">
            <a class="nav-link" href="${pageContext.request.contextPath}/main">대시보드</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/wrong">오답 노트</a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/study/goal">학습 목표</a>
        </nav>
    </header>

    <section class="card">
        <div class="card-header">
            <h2>목표 점수 설정</h2>
        </div>
        <form method="post" class="goal-form">
            <div>
                <label for="target">목표 점수</label>
                <input type="number" id="target" name="target" value="<%= goal != null ? goal.getTargetScore() : 70 %>" min="0" max="100" required>
            </div>
            <div>
                <label for="examDate">시험 예정일</label>
                <input type="date" id="examDate" name="examDate" value="<%= goal != null ? goal.getExamDate() : java.time.LocalDate.now().plusMonths(1) %>" required>
            </div>
            <div>
                <label for="daily">일일 추천 문제 수</label>
                <input type="number" id="daily" name="daily" value="<%= goal != null ? goal.getDailyQuestionCount() : 20 %>" required>
            </div>
            <div style="display:flex; justify-content:flex-end;">
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    </section>

    <section class="card">
        <div class="card-header">
            <h2>회차별 점수 추이</h2>
        </div>
        <table class="table">
            <tr><th>날짜</th><th>점수</th></tr>
            <% for (java.util.Map.Entry<java.time.LocalDate, Integer> entry : history.entrySet()) { %>
                <tr>
                    <td><%= entry.getKey() %></td>
                    <td><%= entry.getValue() %></td>
                </tr>
            <% } %>
        </table>
    </section>
</div>
</body>
</html>
