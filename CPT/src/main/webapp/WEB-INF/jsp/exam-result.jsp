<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    ExamReport report = (ExamReport) request.getAttribute("report");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Map<Integer, ExamResp> responses = (Map<Integer, ExamResp>) request.getAttribute("responses");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>결과 리포트</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; background: #f3f4f6; }
        .summary { background: #fff; padding: 20px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .grid { display: grid; gap: 16px; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); }
        .card { background: #fff; padding: 16px; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 8px; border-bottom: 1px solid #e5e7eb; text-align: left; }
        .wrong { color: #dc2626; }
        .correct { color: #2563eb; }
    </style>
</head>
<body>
    <a href="${pageContext.request.contextPath}/main">메인으로</a>
    <section class="summary">
        <h1>세션 결과</h1>
        <p>총점: <strong><%= report.getScore() %></strong>점 (정답 <%= report.getCorrectCount() %> / <%= report.getTotalQuestions() %>)</p>
        <p>응시 시간: <%= report.getSession().getStartAt() %> ~ <%= report.getSession().getSubmitAt() %></p>
    </section>
    <section class="grid">
        <div class="card">
            <h2>단원별 정확도</h2>
            <table>
                <tr><th>단원</th><th>정확도</th></tr>
                <% for (UnitAccuracy acc : report.getUnitAccuracies()) { %>
                    <tr>
                        <td><%= HtmlUtil.escape(acc.getUnit().getName()) %></td>
                        <td><%= acc.getAccuracy() %>%</td>
                    </tr>
                <% } %>
            </table>
        </div>
        <div class="card">
            <h2>취약 태그 TOP5</h2>
            <table>
                <tr><th>태그</th><th>정확도</th></tr>
                <% for (TagAccuracy acc : report.getTagWeaknesses()) { %>
                    <tr>
                        <td><%= HtmlUtil.escape(acc.getTag().getName()) %></td>
                        <td><%= acc.getAccuracy() %>%</td>
                    </tr>
                <% } %>
            </table>
        </div>
    </section>
    <section class="card" style="margin-top:20px;">
        <h2>문항별 정오답</h2>
        <table>
            <tr><th>번호</th><th>문항</th><th>결과</th></tr>
            <% int idx = 0; for (Question q : questions) { idx++; %>
                <% ExamResp resp = responses.get(q.getQId()); %>
                <tr>
                    <td><%= idx %></td>
                    <td><%= HtmlUtil.escape(q.getStem()) %></td>
                    <td class="<%= resp != null && "Y".equals(resp.getIsCorrect()) ? "correct" : "wrong" %>">
                        <%= resp != null && "Y".equals(resp.getIsCorrect()) ? "정답" : "오답" %>
                    </td>
                </tr>
            <% } %>
        </table>
    </section>
</body>
</html>
