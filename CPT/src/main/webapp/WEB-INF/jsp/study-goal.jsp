<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/cbt-core.tld" %>
<%@ taglib prefix="fn" uri="/WEB-INF/tld/cbt-functions.tld" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학습 목표 & 리포트</title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Learning Coach</span>
            <h1>🎯 학습 목표 관리</h1>
            <p class="subtitle">목표 점수를 설정하고 회차별 성과를 추적하며 주간 추천 문제량을 확인하세요.</p>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>목표 점수 설정</h2>
        </div>
        <form method="post" class="goal-form">
            <div class="goal-grid">
                <label class="filter-field">
                    <span>목표 점수</span>
                    <input type="number" id="target" name="target" value="${targetScore}" min="0" max="100" required>
                </label>
                <label class="filter-field">
                    <span>시험 예정일</span>
                    <input type="date" id="examDate" name="examDate" value="${goalExamDate}" required>
                </label>
                <label class="filter-field">
                    <span>일일 추천 문제 수</span>
                    <input type="number" id="daily" name="daily" value="${dailyCount}" required>
                </label>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
        <div class="goal-callout">
            <strong>Tip.</strong> 목표일이 가까울수록 자동으로 추천 문제량이 증가하도록 설계되어 있습니다. 과도한 목표 설정을 피하려면 일일 추천량을 주 5일 기준으로 조정하세요.
        </div>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>회차별 점수 추이</h2>
            <div class="section-actions">
                <span class="pill">최근 <c:out value="${fn:length(historyEntries)}" />회차</span>
            </div>
        </div>
        <c:choose>
            <c:when test="${empty historyEntries}">
                <div class="alert warning">아직 저장된 결과가 없습니다. CBT 시험을 완료하면 자동으로 기록됩니다.</div>
            </c:when>
            <c:otherwise>
                <ol class="score-timeline">
                    <c:forEach var="entry" items="${historyEntries}">
                        <li>
                            <span class="score-timeline__label"><c:out value="${entry.key}" /></span>
                            <span class="score-timeline__value"><c:out value="${entry.value}" />점</span>
                        </li>
                    </c:forEach>
                </ol>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>주간 학습 플래너</h2>
        </div>
        <c:choose>
            <c:when test="${empty studyPlan}">
                <div class="alert">추천 학습 계획이 없습니다. 시험을 응시하면 자동으로 맞춤 플랜이 생성됩니다.</div>
            </c:when>
            <c:otherwise>
                <div class="planner-grid">
                    <c:forEach var="plan" items="${studyPlan}">
                        <article class="planner-card">
                            <h3>${plan.label}</h3>
                            <p class="planner-focus"><strong>${plan.focus}</strong></p>
                            <p class="planner-meta">추천 ${plan.questionCount}문항</p>
                            <p class="planner-note">${plan.note}</p>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>다가오는 복습 알림</h2>
        </div>
        <c:choose>
            <c:when test="${empty reminders}">
                <div class="alert">등록된 알림이 없습니다. 시험을 응시하면 복습 일정이 자동으로 쌓입니다.</div>
            </c:when>
            <c:otherwise>
                <ul class="reminder-list">
                    <c:forEach var="reminder" items="${reminders}">
                        <li>
                            <span class="reminder-date"><c:out value="${reminder.dueDate}" /></span>
                            <div>
                                <strong><c:out value="${reminder.title}" /></strong>
                                <p><c:out value="${reminder.description}" /></p>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>핵심 개념 요약</h2>
        </div>
        <div class="concept-grid">
            <c:forEach var="concept" items="${conceptSummaries}">
                <article class="concept-card">
                    <h3><c:out value="${concept.title}" /></h3>
                    <p class="concept-body"><c:out value="${concept.description}" /></p>
                    <p class="concept-tags">태그: <c:out value="${concept.tags}" /></p>
                </article>
            </c:forEach>
        </div>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>단계별 학습 모드</h2>
        </div>
        <c:choose>
            <c:when test="${empty stageRecommendations}">
                <div class="alert">추천 단계 데이터가 없습니다. 시험을 응시하면 자동으로 생성됩니다.</div>
            </c:when>
            <c:otherwise>
                <ul class="stage-list">
                    <c:forEach var="stage" items="${stageRecommendations}">
                        <li>
                            <span class="stage-label">${stage.stage}</span>
                            <div>
                                <strong><c:out value="${stage.focus}" /></strong>
                                <p><c:out value="${stage.suggestion}" /></p>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>SRS 복습 큐</h2>
        </div>
        <c:choose>
            <c:when test="${empty srsQueue}">
                <div class="alert">예정된 복습 카드가 없습니다. 오답이 누적되면 자동으로 생성됩니다.</div>
            </c:when>
            <c:otherwise>
                <table class="table srs-table">
                    <thead><tr><th>문항</th><th>다음 복습일</th><th>레벨</th></tr></thead>
                    <tbody>
                    <c:forEach var="card" items="${srsQueue}">
                        <tr>
                            <td><c:out value="${card.stem}" /></td>
                            <td>${card.dueDate}</td>
                            <td>Box ${card.box}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>집중 단원 요약</h2>
        </div>
        <c:choose>
            <c:when test="${empty unitSummaries}">
                <div class="alert">단원별 통계가 없습니다. CBT 시험을 응시하면 자동으로 채워집니다.</div>
            </c:when>
            <c:otherwise>
                <div class="unit-summary-grid">
                    <c:forEach var="summary" items="${unitSummaries}" varStatus="loop">
                        <c:if test="${loop.index < 4}">
                            <article class="unit-summary-card">
                                <h3><c:out value="${summary.unit.name}" /></h3>
                                <p class="meta">총 <strong>${summary.totalQuestions}</strong>문항 · 즐겨찾기 ${summary.favoriteQuestions} · 오답 ${summary.wrongAttempts}</p>
                                <p class="hint">NCS 코드 ${summary.unit.ncsCode}</p>
                            </article>
                        </c:if>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>
