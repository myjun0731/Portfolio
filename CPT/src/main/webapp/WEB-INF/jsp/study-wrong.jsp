<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/cbt-core.tld" %>
<%@ taglib prefix="fn" uri="/WEB-INF/tld/cbt-functions.tld" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>오답 노트</title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Review Center</span>
            <h1>📝 오답 노트</h1>
            <p class="subtitle">최근 오답 문항을 다시 풀고 개인 메모를 남겨 복습 루틴을 자동화하세요.</p>
        </div>
        <c:if test="${fn:length(retry) > 0}">
            <div class="hero-actions">
                <a class="btn" href="/exam/start?action=wrong">오답 세션 생성</a>
            </div>
        </c:if>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>오답만 다시 풀기</h2>
            <div class="section-actions">
                <span class="pill">최근 오답 <c:out value="${fn:length(retry)}" />문항</span>
            </div>
        </div>
        <c:choose>
            <c:when test="${empty retry}">
                <div class="alert warning">최근 오답이 없습니다. CBT를 응시하고 틀린 문항을 자동으로 모아보세요.</div>
            </c:when>
            <c:otherwise>
                <div class="question-collection__list">
                    <c:forEach var="question" items="${retry}">
                        <article class="review-card">
                            <h3><c:out value="${question.stem}" /></h3>
                            <ol>
                                <c:forEach var="opt" items="${question.options}">
                                    <li><c:out value="${opt.text}" /></li>
                                </c:forEach>
                            </ol>
                            <c:if test="${not empty question.commentary or not empty question.hint}">
                                <div class="review-explain">
                                    <c:if test="${not empty question.commentary}">
                                        <p class="result-commentary"><strong>해설</strong> · <c:out value="${question.commentary}" /></p>
                                    </c:if>
                                    <c:if test="${not empty question.hint}">
                                        <p class="result-hint"><strong>힌트</strong> · <c:out value="${question.hint}" /></p>
                                    </c:if>
                                </div>
                            </c:if>
                            <form method="post" action="/study/review" class="review-form">
                                <input type="hidden" name="qid" value="${question.qId}">
                                <label class="review-flag">
                                    <input type="checkbox" name="star" value="Y"> 즐겨찾기
                                </label>
                                <label class="filter-field">
                                    <span>메모</span>
                                    <textarea id="memo-${question.qId}" name="memo" placeholder="학습 노트를 남겨보세요."></textarea>
                                </label>
                                <div class="form-actions">
                                    <button type="submit" class="btn btn-primary">메모 저장</button>
                                </div>
                            </form>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>누적 기록</h2>
        </div>
        <table class="table">
            <thead>
            <tr><th>문항 ID</th><th>마지막 오답일</th><th>오답 횟수</th></tr>
            </thead>
            <tbody>
            <c:forEach var="note" items="${wrongNotes}">
                <tr>
                    <td><c:out value="${note.questionId}" /></td>
                    <td><c:out value="${note.lastWrongAt}" /></td>
                    <td><c:out value="${note.attempts}" /></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </section>
</main>
</body>
</html>
