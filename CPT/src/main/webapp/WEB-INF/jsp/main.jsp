<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>대시보드 - 정보처리산업기사 CBT</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">CBT Dashboard</span>
            <h1><c:out value="${sessionScope.user.name}" />님, 오늘의 학습을 이어가세요.</h1>
            <p class="subtitle">문항 큐레이션부터 시험 응시, 결과 분석과 복습까지 Claude 감성의 단일 워크플로우로 제공합니다.</p>
        </div>
        <div class="hero-actions">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/exam/start">CBT 응시 시작</a>
            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/questions">문항 탐색 열기</a>
        </div>
    </section>

    <section class="app-section overview">
        <div class="section-headline">
            <div>
                <h2>학습 스냅샷</h2>
                <p class="subtitle">프로덕션 운영을 위한 핵심 지표를 한 눈에 확인하세요.</p>
            </div>
            <c:if test="${not empty latestScoreLabel}">
                <div class="section-actions">
                    <span class="pill"><c:out value="${latestScoreLabel}" /></span>
                </div>
            </c:if>
        </div>
        <div class="overview-grid">
            <article class="metric-card">
                <h3>문항 풀</h3>
                <p class="metric-value"><c:out value="${questionTotal}" default="0" /> 문항</p>
                <p class="metric-caption">태그/난이도 필터로 즉시 탐색 가능합니다.</p>
            </article>
            <article class="metric-card">
                <h3>NCS 단원</h3>
                <p class="metric-value"><c:out value="${unitTotal}" default="0" /> 단원</p>
                <p class="metric-caption">좌측 트리를 통해 정교하게 매핑하세요.</p>
            </article>
            <article class="metric-card">
                <h3>태그 자산</h3>
                <p class="metric-value"><c:out value="${tagTotal}" default="0" /> 태그</p>
                <p class="metric-caption">취약 개념 TOP5 분석에 활용됩니다.</p>
            </article>
            <article class="metric-card">
                <h3>최근 점수</h3>
                <c:choose>
                    <c:when test="${empty scoreHistory}">
                        <p class="metric-value">데이터 없음</p>
                    </c:when>
                    <c:otherwise>
                        <p class="metric-value"><c:out value="${latestScore}" />점</p>
                    </c:otherwise>
                </c:choose>
                <p class="metric-caption">응시 완료 시 자동으로 기록됩니다.</p>
            </article>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <div>
                <h2>바로 응시 가능한 기출 회차</h2>
                <p class="subtitle">최신 회차 기준으로 정렬되어 있으며, 동일 시드 기반으로 문제/선지가 셔됩니다.</p>
            </div>
            <div class="section-actions">
                <span class="pill">총 <c:out value="${fn:length(papers)}" />회차</span>
            </div>
        </div>
        <c:choose>
            <c:when test="${not empty papers}">
                <div class="paper-board">
                    <c:forEach var="paper" items="${papers}">
                        <article class="paper-card">
                            <div class="paper-card__header">
                                <span class="badge"><c:out value="${paper.examYear}" />년 <c:out value="${paper.examRound}" />회</span>
                                <span class="meta">ID <c:out value="${paper.paperId}" /></span>
                            </div>
                            <h3 class="paper-card__title"><c:out value="${paper.name}" /></h3>
                            <ul class="paper-card__meta">
                                <li>제한시간 <strong><c:out value="${paper.timeLimitMin}" /></strong>분</li>
                                <li>문항수 <strong><c:out value="${paper.questionCount}" /></strong>개</li>
                            </ul>
                            <c:if test="${paper.hasMissingQuestions}">
                                <p class="paper-card__alert">일부 문항 누락 → 대체 문항이 자동 적용됩니다.</p>
                            </c:if>
                            <form method="post" action="${pageContext.request.contextPath}/exam/start" class="paper-card__actions">
                                <input type="hidden" name="paperId" value="${paper.paperId}">
                                <button type="submit" class="btn btn-primary">이 회차 응시</button>
                                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/papers/quick">세부 정보</a>
                            </form>
                        </article>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert">등록된 시험지가 없습니다. 운영자 메뉴에서 회차를 추가해주세요.</div>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <div>
                <h2>최근 점수 히스토리</h2>
                <p class="subtitle">재응시 시 추이 비교를 통해 학습 곡선을 확인할 수 있습니다.</p>
            </div>
        </div>
        <c:choose>
            <c:when test="${empty scoreHistoryEntries}">
                <div class="alert warning">아직 응시 기록이 없습니다. CBT 시험을 완료하면 결과가 축적됩니다.</div>
            </c:when>
            <c:otherwise>
                <ol class="score-timeline">
                    <c:forEach var="entry" items="${scoreHistoryEntries}">
                        <li>
                            <span class="score-timeline__label"><c:out value="${entry.key}" /></span>
                            <span class="score-timeline__value"><c:out value="${entry.value}" />점</span>
                        </li>
                    </c:forEach>
                </ol>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>
