<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/cbt-core.tld" %>
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
        <div class="page-hero__lede">
            <span class="badge soft">Paper Library</span>
            <h1>🗂 연·회차 바로가기</h1>
            <p class="subtitle">사전 구성된 CBT 시험지를 선택해 동일 시드로 즉시 응시하거나 시험 정보를 검토하세요.</p>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <div>
                <h2>기출 회차 모음</h2>
                <p class="subtitle">시험 모드는 "G"(기출) 기준으로 구성되었습니다. 응시 전에 결측 여부를 확인하세요.</p>
            </div>
            <div class="section-actions">
                <span class="pill">총 <c:out value="${paperCount}" />회차</span>
                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/questions">문항 탐색</a>
            </div>
        </div>
        <c:choose>
            <c:when test="${not empty papers}">
                <div class="paper-board">
                    <c:forEach var="paper" items="${papers}">
                        <article class="paper-card">
                            <div class="paper-card__header">
                                <span class="badge"><c:out value="${paper.mode}" /> 모드</span>
                                <span class="meta">ID <c:out value="${paper.paperId}" /></span>
                            </div>
                            <h3 class="paper-card__title"><c:out value="${paper.name}" /></h3>
                            <ul class="paper-card__meta">
                                <li>총 문항 <strong><c:out value="${paper.questionCount}" /></strong>개</li>
                                <li>제한시간 <strong><c:out value="${paper.timeLimitMin}" /></strong>분</li>
                                <li>출제년도 <strong><c:out value="${paper.examYear}" /></strong>년 / <strong><c:out value="${paper.examRound}" /></strong>회</li>
                            </ul>
                            <c:if test="${paper.hasMissingQuestions}">
                                <p class="paper-card__alert">일부 문항이 누락되어 대체 문항이 자동 매핑됩니다.</p>
                            </c:if>
                            <form method="post" action="${pageContext.request.contextPath}/exam/start" class="paper-card__actions">
                                <input type="hidden" name="paperId" value="${paper.paperId}">
                                <button type="submit" class="btn btn-primary">바로 응시</button>
                            </form>
                        </article>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert warning">등록된 기출 시험지가 없습니다. 운영자 모드에서 회차를 추가해주세요.</div>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>
