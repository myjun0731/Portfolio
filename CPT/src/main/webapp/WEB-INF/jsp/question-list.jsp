<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    List<Unit> units = (List<Unit>) request.getAttribute("units");
    List<Tag> tags = (List<Tag>) request.getAttribute("tags");
    List<com.cbt.model.Subject> subjects = (List<com.cbt.model.Subject>) request.getAttribute("subjects");
    long total = (Long) request.getAttribute("total");
    int page = (Integer) request.getAttribute("page");
    int size = (Integer) request.getAttribute("size");
    int pages = (int) Math.ceil(total / (double) size);
    String[] selectedTags = request.getParameterValues("tags");
    Set<String> selected = new HashSet<>();
    if (selectedTags != null) {
        selected.addAll(Arrays.asList(selectedTags));
    }
    Map<Integer, List<Unit>> unitsBySubject = new HashMap<>();
    Map<Integer, List<Unit>> unitsByParent = new HashMap<>();
    for (Unit unit : units) {
        unitsBySubject.computeIfAbsent(unit.getSubjectId(), k -> new ArrayList<>()).add(unit);
        Integer parentId = unit.getParentId();
        unitsByParent.computeIfAbsent(parentId != null ? parentId : 0, k -> new ArrayList<>()).add(unit);
    }
    for (List<Unit> list : unitsBySubject.values()) {
        list.sort(Comparator.comparing(Unit::getName));
    }
    for (List<Unit> list : unitsByParent.values()) {
        list.sort(Comparator.comparing(Unit::getName));
    }
    Integer selectedUnit = null;
    if (request.getParameter("unit") != null && !request.getParameter("unit").isBlank()) {
        try {
            selectedUnit = Integer.parseInt(request.getParameter("unit"));
        } catch (NumberFormatException ignore) {
            selectedUnit = null;
        }
    }
%>
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
                                <% for (Unit unit : units) { %>
                                    <option value="<%= unit.getUnitId() %>" <%= unit.getUnitId() == (selectedUnit != null ? selectedUnit : -1) ? "selected" : "" %>>
                                        <%= HtmlUtil.escape(unit.getName()) %> (<%= unit.getNcsCode() %>)
                                    </option>
                                <% } %>
                            </select>
                        </label>
                        <label class="filter-field">
                            <span>태그 교차 방식</span>
                            <select id="tagMode" name="tagMode">
                                <option value="AND" <%= "OR".equalsIgnoreCase(request.getParameter("tagMode")) ? "" : "selected" %>>AND</option>
                                <option value="OR" <%= "OR".equalsIgnoreCase(request.getParameter("tagMode")) ? "selected" : "" %>>OR</option>
                            </select>
                        </label>
                    </div>
                </div>

                <div class="filter-group">
                    <h2>태그 선택</h2>
                    <div class="chip-group">
                        <% for (Tag tag : tags) { %>
                            <label class="chip">
                                <input type="checkbox" name="tags" value="<%= tag.getTagId() %>" <%= selected.contains(String.valueOf(tag.getTagId())) ? "checked" : "" %>>
                                <span><%= HtmlUtil.escape(tag.getName()) %></span>
                            </label>
                        <% } %>
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
                    <% if (subjects != null) { %>
                        <% for (com.cbt.model.Subject subject : subjects) { %>
                            <li>
                                <span class="unit-tree__subject"><%= HtmlUtil.escape(subject.getName()) %></span>
                                <ul>
                                    <% for (Unit unit : unitsBySubject.getOrDefault(subject.getSubjectId(), java.util.Collections.emptyList())) { %>
                                        <% if (unit.getParentId() == null) { %>
                                            <li>
                                                <a class="unit-tree__link<%= selectedUnit != null && selectedUnit == unit.getUnitId() ? " is-active" : "" %>" href="?unit=<%= unit.getUnitId() %>">
                                                    <%= HtmlUtil.escape(unit.getName()) %>
                                                    <span class="unit-tree__code"><%= unit.getNcsCode() %></span>
                                                </a>
                                                <% List<Unit> children = unitsByParent.getOrDefault(unit.getUnitId(), java.util.Collections.emptyList()); %>
                                                <% if (!children.isEmpty()) { %>
                                                    <ul>
                                                        <% for (Unit child : children) { %>
                                                            <li>
                                                                <a class="unit-tree__link child<%= selectedUnit != null && selectedUnit == child.getUnitId() ? " is-active" : "" %>" href="?unit=<%= child.getUnitId() %>">
                                                                    <%= HtmlUtil.escape(child.getName()) %>
                                                                    <span class="unit-tree__code"><%= child.getNcsCode() %></span>
                                                                </a>
                                                            </li>
                                                        <% } %>
                                                    </ul>
                                                <% } %>
                                            </li>
                                        <% } %>
                                    <% } %>
                                </ul>
                            </li>
                        <% } %>
                    <% } %>
                </ul>
            </div>
        </aside>

        <section class="question-collection">
            <header class="question-collection__header">
                <div>
                    <h2>검색 결과</h2>
                    <p class="subtitle">총 <%= total %>문항 · 페이지당 <%= size %>문항</p>
                </div>
                <div class="pill">페이지 <%= page + 1 %> / <%= Math.max(pages, 1) %></div>
            </header>

            <% if (questions.isEmpty()) { %>
                <div class="alert warning">조건에 맞는 문항이 없습니다. 필터를 완화해 다시 시도해주세요.</div>
            <% } else { %>
                <div class="question-collection__list">
                    <% for (Question q : questions) { %>
                        <article class="question-card">
                            <header>
                                <div class="question-card__badge">
                                    <span class="badge soft"><%= q.getExamYear() != null ? q.getExamYear() + "년" : "미상" %> <%= q.getExamRound() != null ? q.getExamRound() + "회" : "" %></span>
                                    <span class="meta">난이도 <strong><%= q.getDiff() %></strong> · 유형 <%= q.getType() %></span>
                                </div>
                                <h2>[<%= HtmlUtil.escape(q.getSubjectName()) %>] <%= HtmlUtil.escape(q.getUnitName()) %></h2>
                            </header>
                            <div class="tag-cloud">
                                <% for (Tag tag : q.getTags()) { %>
                                    <span class="tag-pill"><%= HtmlUtil.escape(tag.getName()) %></span>
                                <% } %>
                            </div>
                            <details class="question-preview">
                                <summary>문항 미리보기</summary>
                                <div class="question-preview__body">
                                    <p><%= HtmlUtil.escape(q.getStem()) %></p>
                                    <ol>
                                        <% for (QOption opt : q.getOptions()) { %>
                                            <li><%= HtmlUtil.escape(opt.getText()) %></li>
                                        <% } %>
                                    </ol>
                                    <p class="meta">* 답안과 해설은 권한 보유자에게만 표시됩니다.</p>
                                </div>
                            </details>
                        </article>
                    <% } %>
                </div>
            <% } %>

            <% if (pages > 1) { %>
                <div class="pagination">
                    <% for (int i = 0; i < pages; i++) { %>
                        <% if (i == page) { %>
                            <span class="active"><%= (i + 1) %></span>
                        <% } else { %>
                            <a href="?page=<%= i %>"><%= (i + 1) %></a>
                        <% } %>
                    <% } %>
                </div>
            <% } %>
        </section>
    </div>
</main>
</body>
</html>
