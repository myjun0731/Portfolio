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
        <div class="page-hero__lede">
            <span class="badge soft">Result Analytics</span>
            <h1>📈 세션 결과</h1>
            <p class="subtitle">정답 통계와 취약 단원을 확인하고 다음 학습 계획을 세워보세요.</p>
        </div>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>총괄</h2>
            <div class="section-actions">
                <span class="pill">세션 #<%= report.getSession().getSessId() %></span>
            </div>
        </div>
        <div class="result-grid">
            <article class="metric-card">
                <h3>총점</h3>
                <p class="metric-value"><%= report.getScore() %> 점</p>
                <p class="metric-caption">정답 <%= report.getCorrectCount() %> / <%= report.getTotalQuestions() %></p>
            </article>
            <article class="metric-card">
                <h3>시험 시작</h3>
                <p class="metric-value"><%= report.getSession().getStartAt() %></p>
                <p class="metric-caption">타이머 기준 서버 시각</p>
            </article>
            <article class="metric-card">
                <h3>제출 완료</h3>
                <p class="metric-value"><%= report.getSession().getSubmitAt() %></p>
                <p class="metric-caption">자동 제출 포함</p>
            </article>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>정확도 분석</h2>
        </div>
        <div class="analysis-grid">
            <article class="analysis-card">
                <h3>단원별 정확도</h3>
                <table class="table">
                    <thead><tr><th>단원</th><th>정확도</th></tr></thead>
                    <tbody>
                    <% for (UnitAccuracy acc : report.getUnitAccuracies()) { %>
                        <tr>
                            <td><%= HtmlUtil.escape(acc.getUnit().getName()) %></td>
                            <td><%= acc.getAccuracy() %>%</td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </article>
            <article class="analysis-card">
                <h3>취약 태그 TOP5</h3>
                <table class="table">
                    <thead><tr><th>태그</th><th>정확도</th></tr></thead>
                    <tbody>
                    <% for (TagAccuracy acc : report.getTagWeaknesses()) { %>
                        <tr>
                            <td><%= HtmlUtil.escape(acc.getTag().getName()) %></td>
                            <td><%= acc.getAccuracy() %>%</td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </article>
        </div>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>문항별 결과</h2>
        </div>
        <table class="table result-table">
            <thead><tr><th>번호</th><th>문항</th><th>결과</th></tr></thead>
            <tbody>
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
            </tbody>
        </table>
    </section>
</main>
</body>
</html>
