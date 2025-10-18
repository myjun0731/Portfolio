<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
                            <article class="question-card">
                                <header>
                                    <div class="question-card__badge">
                                        <span class="badge soft"><c:out value="${question.examYear}" default="미상" />년 <c:out value="${question.examRound}" default="" />회</span>
                                        <span class="meta">난이도 <strong><c:out value="${question.diff}" /></strong> · 유형 <c:out value="${question.type}" /></span>
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
                                            <c:forEach var="opt" items="${question.options}">
                                                <li><c:out value="${opt.text}" /></li>
                                            </c:forEach>
                                        </ol>
                                        <p class="meta">* 답안과 해설은 권한 보유자에게만 표시됩니다.</p>
                                    </div>
                                </details>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>

            <c:if test="${totalPages > 1}">
                <div class="pagination">
                    <c:forEach begin="0" end="${totalPages - 1}" var="idx">
                        <c:choose>
                            <c:when test="${idx == page}">
                                <span class="active">${idx + 1}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?page=${idx}">${idx + 1}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
            </c:if>
        </section>
    </div>
</main>
</body>
</html>
