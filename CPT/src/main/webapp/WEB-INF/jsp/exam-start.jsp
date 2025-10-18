<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/cbt-core.tld" %>
<%@ taglib prefix="fn" uri="/WEB-INF/tld/cbt-functions.tld" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>응시 세션 생성</title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Exam Session</span>
            <h1>🧭 CBT 응시 시작</h1>
            <p class="subtitle">문항과 선지는 서버에서 셔플되며, 재접속 시 동일 순서를 유지합니다. 시험 유형을 선택해 세션을 생성하세요.</p>
        </div>
        <div class="hero-meta">
            <span class="pill">즐겨찾기 ${favoriteCount}문항</span>
            <span class="pill">오답 ${wrongCount}문항</span>
        </div>
    </section>

    <c:if test="${not empty errorMessage}">
        <div class="alert warning">${errorMessage}</div>
    </c:if>

    <div class="exam-start-grid">
        <section class="app-section">
            <div class="section-headline">
                <h2>기출 회차 응시</h2>
                <div class="section-actions">
                    <span class="pill">선택 가능 ${paperCount}회차</span>
                </div>
            </div>
            <div class="alert exam-guide">
                <ul>
                    <li>타이머는 서버 시간을 기준으로 동작하며, 종료 시 자동 제출됩니다.</li>
                    <li>문항 이동 시 자동 저장되며 네트워크 장애가 발생해도 복구 후 즉시 재전송됩니다.</li>
                    <li>실전 모드를 켜면 문항 순서가 고정되고 내비게이터가 비활성화됩니다.</li>
                </ul>
            </div>
            <c:if test="${paperCount == 0}">
                <div class="alert warning">등록된 기출 회차가 없습니다. 운영자 메뉴에서 시험지를 추가한 뒤 다시 시도해주세요.</div>
            </c:if>
            <form method="post" class="exam-start-form">
                <input type="hidden" name="action" value="paper">
                <label class="filter-field">
                    <span>응시할 시험</span>
                    <select id="paperId" name="paperId" class="paper-select" required <c:if test="${paperCount == 0}">disabled</c:if>>
                        <c:forEach var="paper" items="${papers}">
                            <option value="${paper.paperId}"><c:out value="${paper.examYear}" />년 <c:out value="${paper.examRound}" />회 - <c:out value="${paper.name}" /></option>
                        </c:forEach>
                    </select>
                </label>
                <div class="form-split">
                    <label class="switch">
                        <input type="checkbox" name="strictMode">
                        <span>실전 모드 (문항 순서 고정)</span>
                    </label>
                    <label class="switch">
                        <input type="checkbox" name="fixedOrder">
                        <span>문항 순서 유지</span>
                    </label>
                </div>
                <div class="form-actions">
                    <a href="/papers/quick" class="btn btn-ghost">회차 목록</a>
                    <button type="submit" class="btn btn-primary" <c:if test="${paperCount == 0}">disabled</c:if>>세션 시작</button>
                </div>
            </form>
        </section>

        <section class="app-section">
            <div class="section-headline">
                <h2>랜덤 모의고사</h2>
                <div class="section-actions">
                    <span class="pill">맞춤 구성</span>
                </div>
            </div>
            <form method="post" class="exam-start-form">
                <input type="hidden" name="action" value="mock">
                <div class="form-grid">
                    <label class="filter-field">
                        <span>문항 수</span>
                        <input type="number" name="mockCount" value="10" min="5" max="50">
                    </label>
                    <label class="filter-field">
                        <span>과목</span>
                        <select name="mockSubject">
                            <option value="">전체</option>
                            <c:forEach var="subject" items="${subjects}">
                                <option value="${subject.subjectId}"><c:out value="${subject.name}" /></option>
                            </c:forEach>
                        </select>
                    </label>
                    <label class="filter-field">
                        <span>난이도</span>
                        <select name="mockDiff">
                            <option value="">전체</option>
                            <option value="1">쉬움</option>
                            <option value="2">보통</option>
                            <option value="3">어려움</option>
                        </select>
                    </label>
                </div>
                <div class="form-split">
                    <label class="switch">
                        <input type="checkbox" name="mockStrict">
                        <span>실전 모드</span>
                    </label>
                    <label class="switch">
                        <input type="checkbox" name="mockOrderFixed">
                        <span>문항 순서 유지</span>
                    </label>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">랜덤 세션 생성</button>
                </div>
            </form>
        </section>

        <section class="app-section">
            <div class="section-headline">
                <h2>진단 테스트</h2>
                <div class="section-actions">
                    <span class="pill">8문항 · 실전 모드</span>
                </div>
            </div>
            <form method="post" class="exam-start-form">
                <input type="hidden" name="action" value="diagnostic">
                <p class="subtitle">선택한 과목의 대표 문항 8개로 실전 모드 진단을 진행합니다. 순서는 고정되며 힌트 없이 풀이합니다.</p>
                <label class="filter-field">
                    <span>과목 선택</span>
                    <select name="diagSubject">
                        <c:forEach var="subject" items="${subjects}">
                            <option value="${subject.subjectId}"><c:out value="${subject.name}" /></option>
                        </c:forEach>
                    </select>
                </label>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">진단 세션 시작</button>
                </div>
            </form>
        </section>

        <section class="app-section">
            <div class="section-headline">
                <h2>오답만 다시 풀기</h2>
                <div class="section-actions">
                    <span class="pill">누적 ${wrongCount}문항</span>
                </div>
            </div>
            <form method="post" class="exam-start-form">
                <input type="hidden" name="action" value="wrong">
                <p class="subtitle">최근 틀린 문항을 기반으로 재응시 세트를 생성합니다. 실전 모드를 적용하면 문항을 순차적으로만 진행할 수 있습니다.</p>
                <div class="form-split">
                    <label class="switch">
                        <input type="checkbox" name="wrongStrict">
                        <span>실전 모드</span>
                    </label>
                    <label class="switch">
                        <input type="checkbox" name="wrongOrderFixed">
                        <span>문항 순서 유지</span>
                    </label>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" <c:if test="${wrongCount == 0}">disabled</c:if>>오답 세션 시작</button>
                </div>
            </form>
        </section>
    </div>

    <section class="app-section compact">
        <div class="section-headline">
            <h2>추천 학습 집중 구간</h2>
        </div>
        <c:choose>
            <c:when test="${empty unitSummaries}">
                <div class="alert">분석할 데이터가 없습니다. 시험을 응시해 학습 지표를 쌓아보세요.</div>
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
