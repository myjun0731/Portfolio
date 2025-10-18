<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/cbt-core.tld" %>
<%@ taglib prefix="fn" uri="/WEB-INF/tld/cbt-functions.tld" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>응시 기록</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Session Archive</span>
            <h1>🗂️ 응시 기록</h1>
            <p class="subtitle">모든 CBT 세션의 점수, 모드, 제한 시간 정보를 모아 비교할 수 있습니다.</p>
        </div>
        <form method="get" class="hero-filter">
            <label class="filter-field">
                <span>모드 필터</span>
                <select name="mode">
                    <option value="">전체</option>
                    <option value="PAPER" <c:if test="${param.mode eq 'PAPER'}">selected</c:if>>기출</option>
                    <option value="REAL" <c:if test="${param.mode eq 'REAL'}">selected</c:if>>실전</option>
                    <option value="MOCK" <c:if test="${param.mode eq 'MOCK'}">selected</c:if>>모의</option>
                    <option value="WRONG" <c:if test="${param.mode eq 'WRONG'}">selected</c:if>>오답</option>
                </select>
            </label>
            <button type="submit" class="btn btn-ghost">필터 적용</button>
        </form>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>요약 지표</h2>
        </div>
        <div class="overview-grid">
            <article class="metric-card">
                <h3>평균 점수</h3>
                <p class="metric-value">${averageScore}점</p>
                <p class="metric-caption">필터 적용된 세션 기준</p>
            </article>
            <article class="metric-card">
                <h3>최고 점수</h3>
                <p class="metric-value">${bestScore}점</p>
                <p class="metric-caption">Top 3은 아래 랭킹에서 확인</p>
            </article>
            <article class="metric-card">
                <h3>최근 세션</h3>
                <c:choose>
                    <c:when test="${lastSession ne null}">
                        <p class="metric-value">${lastSession.mode} · ${lastSession.score}점</p>
                        <p class="metric-caption">세션 ID ${lastSession.sessId}</p>
                    </c:when>
                    <c:otherwise>
                        <p class="metric-value">데이터 없음</p>
                    </c:otherwise>
                </c:choose>
            </article>
            <article class="metric-card">
                <h3>모드 분포</h3>
                <ul class="mini-list">
                    <c:forEach var="entry" items="${modeBreakdown}">
                        <li><strong>${entry.key}</strong> · ${entry.value}회</li>
                    </c:forEach>
                    <c:if test="${empty modeBreakdown}">
                        <li>응시 기록 없음</li>
                    </c:if>
                </ul>
            </article>
        </div>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>랭킹 보드</h2>
        </div>
        <c:choose>
            <c:when test="${empty podium}">
                <div class="alert">랭킹을 생성할 세션 데이터가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <ol class="podium-list">
                    <c:forEach var="session" items="${podium}" varStatus="loop">
                        <li>
                            <span class="podium-rank">#${loop.index + 1}</span>
                            <div>
                                <strong>${session.score}점</strong>
                                <p>${session.mode} · 세션 ${session.sessId}</p>
                            </div>
                        </li>
                    </c:forEach>
                </ol>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>세션 상세 목록</h2>
            <div class="section-actions">
                <span class="pill">총 ${fn:length(sessions)}회</span>
            </div>
        </div>
        <c:choose>
            <c:when test="${empty sessions}">
                <div class="alert warning">조건에 맞는 응시 기록이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <table class="table">
                    <thead>
                    <tr><th>ID</th><th>모드</th><th>원본</th><th>점수</th><th>응시 시간</th><th>제출</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="session" items="${sessions}">
                        <tr>
                            <td>${session.sessId}</td>
                            <td>${session.mode}</td>
                            <td><c:out value="${session.originLabel}" /></td>
                            <td><c:out value="${session.score}" default="-" /></td>
                            <td>${session.startAt}</td>
                            <td><c:out value="${session.submitAt}" default="-" /></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>
