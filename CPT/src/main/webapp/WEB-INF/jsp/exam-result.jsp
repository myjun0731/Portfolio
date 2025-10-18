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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <h1>📈 세션 결과</h1>
        <p class="subtitle">정답 통계와 취약 단원을 확인하고 다음 학습 계획을 세워보세요.</p>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>총괄</h2>
            <div class="section-actions">
                <span class="pill">세션 #<%= report.getSession().getSessId() %></span>
            </div>
        </div>
        <div class="stat-stack">
            <div class="stat-card">
                <h3><%= report.getScore() %> 점</h3>
                <span>정답 <%= report.getCorrectCount() %> / <%= report.getTotalQuestions() %></span>
            </div>
            <div class="stat-card">
                <h3><%= report.getSession().getStartAt() %></h3>
                <span>시험 시작</span>
            </div>
            <div class="stat-card">
                <h3><%= report.getSession().getSubmitAt() %></h3>
                <span>제출 완료</span>
            </div>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>정확도 분석</h2>
        </div>
        <div class="card-grid" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));">
            <div>
                <h3>단원별 정확도</h3>
                <table class="table">
                    <tr><th>단원</th><th>정확도</th></tr>
                    <% for (UnitAccuracy acc : report.getUnitAccuracies()) { %>
                        <tr>
                            <td><%= HtmlUtil.escape(acc.getUnit().getName()) %></td>
                            <td><%= acc.getAccuracy() %>%</td>
                        </tr>
                    <% } %>
                </table>
            </div>
            <div>
                <h3>취약 태그 TOP5</h3>
                <table class="table">
                    <tr><th>태그</th><th>정확도</th></tr>
                    <% for (TagAccuracy acc : report.getTagWeaknesses()) { %>
                        <tr>
                            <td><%= HtmlUtil.escape(acc.getTag().getName()) %></td>
                            <td><%= acc.getAccuracy() %>%</td>
                        </tr>
                    <% } %>
                </table>
            </div>
        </div>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>문항별 결과</h2>
        </div>
        <table class="table">
            <tr><th>번호</th><th>문항</th><th>결과</th></tr>
            <% int idx = 0; for (Question q : questions) { idx++; %>
                <% ExamResp resp = responses.get(q.getQId()); %>
                <tr>
                    <td><%= idx %></td>
                    <td><%= HtmlUtil.escape(q.getStem()) %></td>
                    <td class="<%= resp != null && "Y".equals(resp.getIsCorrect()) ? "status-correct" : "status-wrong" %>">
                        <%= resp != null && "Y".equals(resp.getIsCorrect()) ? "정답" : "오답" %>
                    </td>
                </tr>
            <% } %>
        </table>
    </section>
</main>
</body>
</html>
