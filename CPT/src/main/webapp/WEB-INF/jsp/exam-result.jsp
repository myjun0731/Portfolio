<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
                <span class="pill">세션 #<c:out value="${report.session.sessId}" /></span>
            </div>
        </div>
        <div class="result-grid">
            <article class="metric-card">
                <h3>총점</h3>
                <p class="metric-value"><c:out value="${report.score}" /> 점</p>
                <p class="metric-caption">정답 <c:out value="${report.correctCount}" /> / <c:out value="${report.totalQuestions}" /></p>
            </article>
            <article class="metric-card">
                <h3>시험 시작</h3>
                <p class="metric-value"><c:out value="${report.session.startAt}" /></p>
                <p class="metric-caption">타이머 기준 서버 시각</p>
            </article>
            <article class="metric-card">
                <h3>제출 완료</h3>
                <p class="metric-value"><c:out value="${report.session.submitAt}" /></p>
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
                    <c:forEach var="acc" items="${unitAccuracies}">
                        <tr>
                            <td><c:out value="${acc.unit.name}" /></td>
                            <td><c:out value="${acc.accuracy}" />%</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </article>
            <article class="analysis-card">
                <h3>취약 태그 TOP5</h3>
                <table class="table">
                    <thead><tr><th>태그</th><th>정확도</th></tr></thead>
                    <tbody>
                    <c:forEach var="acc" items="${tagWeaknesses}">
                        <tr>
                            <td><c:out value="${acc.tag.name}" /></td>
                            <td><c:out value="${acc.accuracy}" />%</td>
                        </tr>
                    </c:forEach>
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
            <c:forEach var="question" items="${questions}" varStatus="loop">
                <c:set var="resp" value="${responses[question.qId]}" />
                <c:set var="isCorrect" value="${resp ne null and resp.isCorrect eq 'Y'}" />
                <c:set var="resultClass" value="status-wrong" />
                <c:if test="${isCorrect}">
                    <c:set var="resultClass" value="status-correct" />
                </c:if>
                <tr>
                    <td>${loop.index + 1}</td>
                    <td><c:out value="${question.stem}" /></td>
                    <td class="${resultClass}">
                        <c:choose>
                            <c:when test="${isCorrect}">정답</c:when>
                            <c:otherwise>오답</c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </section>
</main>
</body>
</html>
