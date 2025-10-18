<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/cbt-core.tld" %>
<%@ taglib prefix="fn" uri="/WEB-INF/tld/cbt-functions.tld" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>문항 탐색</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Item Explorer</span>
            <h1>📚 NCS 단원 맵 탐색</h1>
            <p class="subtitle">과목, 단원, 태그를 교차 필터링하며 기출 문항을 즉시 미리보고 필요한 세트를 큐레이션하세요.</p>
        </div>
    </section>
    <div class="question-layout">
        <aside class="filter-panel" aria-label="문항 필터">
            <form method="get" class="filter-form">
                <div class="filter-group">
                    <h2>검색 조건</h2>
                    <div class="filter-grid">
                        <label class="filter-field">
                            <span>키워드</span>
                            <input type="text" id="q" name="q" value="${param.q}" placeholder="문항 본문 검색">
                        </label>
                        <label class="filter-field">
                            <span>NCS 코드</span>
                            <input type="text" id="ncs" name="ncs" value="${param.ncs}" placeholder="예: 200103">
                        </label>
                        <label class="filter-field">
                            <span>연도</span>
                            <input type="number" id="year" name="year" value="${param.year}" min="2000" max="2100">
                        </label>
                        <label class="filter-field">
                            <span>회차</span>
                            <input type="number" id="round" name="round" value="${param.round}" min="1" max="10">
                        </label>
                        <label class="filter-field">
                            <span>난이도</span>
                            <input type="number" id="diff" name="diff" min="1" max="3" value="${param.diff}">
                        </label>
                        <label class="filter-field">
                            <span>단원</span>
                            <select id="unit" name="unit">
                                <option value="">전체</option>
                                <c:forEach var="unit" items="${units}">
                                    <option value="${unit.unitId}" <c:if test="${unit.unitId == selectedUnit}">selected</c:if>>
                                        <c:out value="${unit.name}" /> (<c:out value="${unit.ncsCode}" />)
                                    </option>
                                </c:forEach>
                            </select>
                        </label>
                        <label class="filter-field">
                            <span>태그 교차 방식</span>
                            <select id="tagMode" name="tagMode">
                                <option value="AND" <c:if test="${tagMode eq 'AND'}">selected</c:if>>AND</option>
                                <option value="OR" <c:if test="${tagMode eq 'OR'}">selected</c:if>>OR</option>
                            </select>
                        </label>
                    </div>
                    <label class="switch">
                        <input type="checkbox" name="favorite" value="Y" <c:if test="${favoritesOnly}">checked</c:if>>
                        <span>즐겨찾기 문항만 보기</span>
                    </label>
                </div>

                <div class="filter-group">
                    <h2>태그 선택</h2>
                    <div class="chip-group">
                        <c:forEach var="tag" items="${tags}">
                            <label class="chip">
                                <input type="checkbox" name="tags" value="${tag.tagId}" <c:if test="${selectedTags contains tag.tagId}">checked</c:if>>
                                <span><c:out value="${tag.name}" /></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">검색 적용</button>
                    <a class="btn btn-ghost" href="${pageContext.request.contextPath}/papers/quick">회차별 보기</a>
                </div>
            </form>

            <div class="filter-group">
                <h2>NCS 단원 맵</h2>
                <ul class="unit-tree">
                    <c:forEach var="subject" items="${subjects}">
                        <li>
                            <span class="unit-tree__subject"><c:out value="${subject.name}" /></span>
                            <ul>
                                <c:forEach var="unit" items="${unitsBySubject[subject.subjectId]}">
                                    <c:if test="${unit.parentId == null}">
                                        <li>
                                            <a class="unit-tree__link<c:if test="${selectedUnit == unit.unitId}"> is-active</c:if>" href="?unit=${unit.unitId}">
                                                <c:out value="${unit.name}" />
                                                <span class="unit-tree__code"><c:out value="${unit.ncsCode}" /></span>
                                            </a>
                                            <c:set var="children" value="${unitsByParent[unit.unitId]}" />
                                            <c:if test="${not empty children}">
                                                <ul>
                                                    <c:forEach var="child" items="${children}">
                                                        <li>
                                                            <a class="unit-tree__link child<c:if test="${selectedUnit == child.unitId}"> is-active</c:if>" href="?unit=${child.unitId}">
                                                                <c:out value="${child.name}" />
                                                                <span class="unit-tree__code"><c:out value="${child.ncsCode}" /></span>
                                                            </a>
                                                        </li>
                                                    </c:forEach>
                                                </ul>
                                            </c:if>
                                        </li>
                                    </c:if>
                                </c:forEach>
                            </ul>
                        </li>
                    </c:forEach>
                </ul>
            </div>

            <div class="filter-group compact">
                <h2>집중 추천 단원</h2>
                <c:forEach var="summary" items="${unitSummaries}" varStatus="loop">
                    <c:if test="${loop.index < 3}">
                        <div class="unit-hint">
                            <strong><c:out value="${summary.unit.name}" /></strong>
                            <span>즐겨찾기 ${summary.favoriteQuestions} · 오답 ${summary.wrongAttempts}</span>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </aside>

        <section class="question-collection">
            <header class="question-collection__header">
                <div>
                    <h2>검색 결과</h2>
                    <p class="subtitle">총 <c:out value="${total}" />문항 · 페이지당 <c:out value="${size}" />문항</p>
                </div>
                <c:set var="displayPages" value="1" />
                <c:if test="${totalPages > 0}">
                    <c:set var="displayPages" value="${totalPages}" />
                </c:if>
                <div class="pill">페이지 ${page + 1} / ${displayPages}</div>
            </header>

            <c:choose>
                <c:when test="${empty questions}">
                    <div class="alert warning">조건에 맞는 문항이 없습니다. 필터를 완화해 다시 시도해주세요.</div>
                </c:when>
                <c:otherwise>
                    <div class="question-collection__list">
                        <c:forEach var="question" items="${questions}">
                            <article class="question-card" id="q${question.qId}">
                                <header>
                                    <div class="question-card__badge">
                                        <span class="badge soft"><c:out value="${question.examYear}" default="미상" />년 <c:out value="${question.examRound}" default="" />회</span>
                                        <span class="meta">난이도 <strong><c:out value="${question.diff}" /></strong> · 유형 <c:out value="${question.type}" /></span>
                                    </div>
                                    <div class="question-card__actions">
                                        <form method="post" action="${pageContext.request.contextPath}/questions/favorite" class="favorite-form">
                                            <input type="hidden" name="qid" value="${question.qId}">
                                            <button type="submit" class="favorite-btn<c:if test="${favorites contains question.qId}"> is-active</c:if>" aria-label="즐겨찾기">★</button>
                                        </form>
                                    </div>
                                    <h2>[<c:out value="${question.subjectName}" />] <c:out value="${question.unitName}" /></h2>
                                </header>
                                <div class="tag-cloud">
                                    <c:forEach var="tag" items="${question.tags}">
                                        <span class="tag-pill"><c:out value="${tag.name}" /></span>
                                    </c:forEach>
                                </div>
                                <details class="question-preview">
                                    <summary>문항 미리보기</summary>
                                    <div class="question-preview__body">
                                        <p><c:out value="${question.stem}" /></p>
                                        <ol>
                                            <c:forEach var="option" items="${question.options}">
                                                <li><c:out value="${option.text}" /></li>
                                            </c:forEach>
                                        </ol>
                                        <c:if test="${not empty question.hint}">
                                            <p class="hint-text">힌트 · <c:out value="${question.hint}" /></p>
                                        </c:if>
                                        <c:if test="${not empty question.videoUrl}">
                                            <p><a class="link" href="${question.videoUrl}" target="_blank" rel="noopener">해설 영상 보기</a></p>
                                        </c:if>
                                    </div>
                                </details>
                                <div class="question-tools">
                                    <details>
                                        <summary>학습 노트</summary>
                                        <form method="post" action="${pageContext.request.contextPath}/questions/note" class="note-form">
                                            <input type="hidden" name="qid" value="${question.qId}">
                                            <textarea name="memo" rows="2" placeholder="개인 메모를 남겨보세요.">${notes[question.qId].memo}</textarea>
                                            <button type="submit" class="btn btn-ghost">노트 저장</button>
                                        </form>
                                    </details>
                                    <details>
                                        <summary>문항 피드백 (<c:out value="${feedbackCounts[question.qId]}" />)</summary>
                                        <form method="post" action="${pageContext.request.contextPath}/questions/feedback" class="feedback-form">
                                            <input type="hidden" name="qid" value="${question.qId}">
                                            <label class="filter-field">
                                                <span>유형</span>
                                                <select name="type">
                                                    <option value="내용">내용 오류</option>
                                                    <option value="해설">해설 보완</option>
                                                    <option value="오타">오타 제보</option>
                                                    <option value="기타">기타</option>
                                                </select>
                                            </label>
                                            <label class="filter-field">
                                                <span>내용</span>
                                                <textarea name="message" rows="2" required placeholder="피드백을 입력해주세요."></textarea>
                                            </label>
                                            <button type="submit" class="btn btn-ghost">피드백 전송</button>
                                        </form>
                                    </details>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>
</body>
</html>
