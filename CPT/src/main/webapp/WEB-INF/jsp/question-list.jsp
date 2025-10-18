<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    List<Unit> units = (List<Unit>) request.getAttribute("units");
    List<Tag> tags = (List<Tag>) request.getAttribute("tags");
    long total = (Long) request.getAttribute("total");
    int page = (Integer) request.getAttribute("page");
    int size = (Integer) request.getAttribute("size");
    int pages = (int) Math.ceil(total / (double) size);
    String[] selectedTags = request.getParameterValues("tags");
    Set<String> selected = new HashSet<>();
    if (selectedTags != null) {
        selected.addAll(Arrays.asList(selectedTags));
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>문항 탐색</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
    <script>
        function togglePreview(id) {
            const panel = document.getElementById('preview-' + id);
            if (!panel) return;
            panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
        }
    </script>
</head>
<body>
<div class="app-shell">
    <header class="page-header">
        <div>
            <h1>📚 NCS 단원 맵 탐색</h1>
            <p class="subtitle">과목, 단원, 태그를 교차 필터링하고 문항을 바로 미리 확인해보세요.</p>
        </div>
        <nav class="nav-links">
            <a class="nav-link" href="${pageContext.request.contextPath}/main">대시보드</a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/q/list.jsp">문항 탐색</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/paper/gii.jsp">연·회차</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/wrong">오답 노트</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/goal">학습 목표</a>
        </nav>
    </header>

    <section class="card">
        <div class="card-header">
            <div>
                <h2>검색 필터</h2>
                <p class="subtitle">최대 20문항씩 표시됩니다. 조건을 조합해 원하는 문항을 찾으세요.</p>
            </div>
        </div>
        <form method="get" class="form-grid">
            <div class="form-grid inline">
                <div>
                    <label for="q">키워드</label>
                    <input type="text" id="q" name="q" value="${param.q}">
                </div>
                <div>
                    <label for="ncs">NCS 코드</label>
                    <input type="text" id="ncs" name="ncs" value="${param.ncs}">
                </div>
                <div>
                    <label for="year">연도</label>
                    <input type="number" id="year" name="year" value="${param.year}">
                </div>
                <div>
                    <label for="round">회차</label>
                    <input type="number" id="round" name="round" value="${param.round}">
                </div>
                <div>
                    <label for="diff">난이도(1~3)</label>
                    <input type="number" id="diff" name="diff" min="1" max="3" value="${param.diff}">
                </div>
                <div>
                    <label for="unit">단원</label>
                    <select id="unit" name="unit">
                        <option value="">전체</option>
                        <% for (Unit unit : units) { %>
                            <option value="<%= unit.getUnitId() %>" <%= unit.getUnitId() == (request.getParameter("unit") != null && !request.getParameter("unit").isEmpty() ? Integer.parseInt(request.getParameter("unit")) : -1) ? "selected" : "" %>>
                                <%= HtmlUtil.escape(unit.getName()) %> (<%= unit.getNcsCode() %>)
                            </option>
                        <% } %>
                    </select>
                </div>
                <div>
                    <label for="tagMode">태그 교차 방식</label>
                    <select id="tagMode" name="tagMode">
                        <option value="AND" <%= "OR".equalsIgnoreCase(request.getParameter("tagMode")) ? "" : "selected" %>>AND</option>
                        <option value="OR" <%= "OR".equalsIgnoreCase(request.getParameter("tagMode")) ? "selected" : "" %>>OR</option>
                    </select>
                </div>
            </div>
            <div>
                <label>태그 선택</label>
                <div class="chip-group">
                    <% for (Tag tag : tags) { %>
                        <label class="chip">
                            <input type="checkbox" name="tags" value="<%= tag.getTagId() %>" <%= selected.contains(String.valueOf(tag.getTagId())) ? "checked" : "" %>>
                            <span><%= HtmlUtil.escape(tag.getName()) %></span>
                        </label>
                    <% } %>
                </div>
            </div>
            <div style="display:flex; justify-content:flex-end; gap:12px;">
                <button type="submit" class="btn btn-primary">검색</button>
            </div>
        </form>
    </section>

    <section class="form-grid" style="margin-top:32px;">
        <% if (questions.isEmpty()) { %>
            <div class="alert warning">조건에 맞는 문항이 없습니다. 필터를 완화해 다시 시도해주세요.</div>
        <% } else { %>
            <% for (Question q : questions) { %>
                <article class="question-card">
                    <header>
                        <h2>[<%= HtmlUtil.escape(q.getSubjectName()) %>] <%= HtmlUtil.escape(q.getUnitName()) %></h2>
                        <p class="meta"><%= q.getExamYear() != null ? q.getExamYear() + "년 " : "" %><%= q.getExamRound() != null ? q.getExamRound() + "회" : "" %> · 난이도 <%= q.getDiff() %></p>
                    </header>
                    <div class="tag-cloud">
                        <% for (Tag tag : q.getTags()) { %>
                            <span class="tag-pill"><%= HtmlUtil.escape(tag.getName()) %></span>
                        <% } %>
                    </div>
                    <div style="display:flex; justify-content:flex-end;">
                        <button type="button" class="btn btn-ghost" onclick="togglePreview(<%= q.getQId() %>)">문항 미리보기</button>
                    </div>
                    <div id="preview-<%= q.getQId() %>" class="question-preview" style="display:none;">
                        <p><%= HtmlUtil.escape(q.getStem()) %></p>
                        <ol>
                            <% for (QOption opt : q.getOptions()) { %>
                                <li><%= HtmlUtil.escape(opt.getText()) %></li>
                            <% } %>
                        </ol>
                        <p class="meta" style="margin-top:10px;">* 답안과 해설은 권한 보유자에게만 표시됩니다.</p>
                    </div>
                </article>
            <% } %>
        <% } %>
    </section>

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
</div>
</body>
</html>
