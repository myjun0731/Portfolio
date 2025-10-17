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
    <title>목표 & 리포트</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; background: #f3f4f6; }
        .card { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.05); margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; }
        input { width: 100%; padding: 10px; margin-bottom: 12px; }
        button { background: #2563eb; color: #fff; border: none; padding: 10px 16px; border-radius: 6px; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 8px; border-bottom: 1px solid #e5e7eb; text-align: left; }
    </style>
</head>
<body>
    <a href="${pageContext.request.contextPath}/main">메인으로</a>
    <section class="card">
        <h1>목표 점수 설정</h1>
        <form method="post">
            <label>목표 점수</label>
            <input type="number" name="target" value="<%= goal != null ? goal.getTargetScore() : 70 %>" min="0" max="100" required>
            <label>시험 예정일</label>
            <input type="date" name="examDate" value="<%= goal != null ? goal.getExamDate() : java.time.LocalDate.now().plusMonths(1) %>" required>
            <label>일일 추천 문제 수</label>
            <input type="number" name="daily" value="<%= goal != null ? goal.getDailyQuestionCount() : 20 %>" required>
            <button type="submit">저장</button>
        </form>
    </section>
    <section class="card">
        <h2>회차별 점수 추이</h2>
        <table>
            <tr><th>날짜</th><th>점수</th></tr>
            <% for (java.util.Map.Entry<java.time.LocalDate, Integer> entry : history.entrySet()) { %>
                <tr>
                    <td><%= entry.getKey() %></td>
                    <td><%= entry.getValue() %></td>
                </tr>
            <% } %>
        </table>
    </section>
</body>
</html>
