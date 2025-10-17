<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    List<Unit> units = (List<Unit>) request.getAttribute("units");
    long total = (Long) request.getAttribute("total");
    int page = (Integer) request.getAttribute("page");
    int size = (Integer) request.getAttribute("size");
    int pages = (int) Math.ceil(total / (double) size);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>문항 탐색</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; background: #f5f6fa; }
        header { display: flex; justify-content: space-between; align-items: center; }
        .filters { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 10px; margin-top: 20px; }
        .question-list { margin-top: 20px; }
        .question-card { background: #fff; padding: 16px; border-radius: 10px; margin-bottom: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); position: relative; }
        .question-card:hover .preview { display: block; }
        .preview { display: none; position: absolute; background: #fff; border: 1px solid #ddd; padding: 16px; width: 400px; top: 100%; left: 0; z-index: 10; box-shadow: 0 4px 12px rgba(0,0,0,0.12); }
        .tags { margin-top: 10px; }
        .tag { display: inline-block; padding: 4px 8px; border-radius: 4px; background: #eef2ff; color: #4338ca; margin-right: 6px; font-size: 12px; }
        .pagination { margin-top: 20px; }
        .pagination a { margin-right: 8px; text-decoration: none; }
    </style>
    <script>
        function togglePreview(id) {
            var box = document.getElementById('preview-' + id);
            if (box) {
                box.style.display = box.style.display === 'block' ? 'none' : 'block';
            }
        }
    </script>
</head>
<body>
<header>
    <h1>📚 NCS 단원 맵 탐색</h1>
    <a href="${pageContext.request.contextPath}/main">메인으로</a>
</header>
<form method="get" class="filters">
    <input type="text" name="q" placeholder="키워드" value="${param.q}">
    <input type="text" name="ncs" placeholder="NCS 코드" value="${param.ncs}">
    <input type="number" name="year" placeholder="연도" value="${param.year}">
    <input type="number" name="round" placeholder="회차" value="${param.round}">
    <input type="number" name="diff" placeholder="난이도(1~3)" value="${param.diff}">
    <select name="unit">
        <option value="">단원 전체</option>
        <% for (Unit unit : units) { %>
            <option value="<%= unit.getUnitId() %>" <%= unit.getUnitId() == (request.getParameter("unit") != null && !request.getParameter("unit").isEmpty() ? Integer.parseInt(request.getParameter("unit")) : -1) ? "selected" : "" %>>
                <%= HtmlUtil.escape(unit.getName()) %> (<%= unit.getNcsCode() %>)
            </option>
        <% } %>
    </select>
    <select name="tagMode">
        <option value="AND" <%= "OR".equalsIgnoreCase(request.getParameter("tagMode")) ? "" : "selected" %>>AND</option>
        <option value="OR" <%= "OR".equalsIgnoreCase(request.getParameter("tagMode")) ? "selected" : "" %>>OR</option>
    </select>
    <div>
        <strong>태그</strong><br>
        <% List<Tag> tags = (List<Tag>) request.getAttribute("tags");
           String[] selectedTags = request.getParameterValues("tags");
           java.util.Set<String> selected = new java.util.HashSet<>();
           if (selectedTags != null) {
               selected.addAll(java.util.Arrays.asList(selectedTags));
           }
           for (Tag tag : tags) { %>
            <label>
                <input type="checkbox" name="tags" value="<%= tag.getTagId() %>" <%= selected.contains(String.valueOf(tag.getTagId())) ? "checked" : "" %>>
                <%= HtmlUtil.escape(tag.getName()) %>
            </label><br>
        <% } %>
    </div>
    <button type="submit">검색</button>
</form>
<section class="question-list">
    <% if (questions.isEmpty()) { %>
        <p>조건에 맞는 문항이 없습니다.</p>
    <% } else { %>
        <% for (Question q : questions) { %>
            <article class="question-card" onclick="togglePreview(<%= q.getQId() %>)">
                <strong>[<%= HtmlUtil.escape(q.getSubjectName()) %>] <%= HtmlUtil.escape(q.getUnitName()) %></strong>
                <span> | <%= q.getExamYear() != null ? q.getExamYear() : "" %> - <%= q.getExamRound() != null ? q.getExamRound() : "" %>회</span>
                <div class="tags">
                    <% for (Tag tag : q.getTags()) { %>
                        <span class="tag"><%= HtmlUtil.escape(tag.getName()) %></span>
                    <% } %>
                </div>
                <div id="preview-<%= q.getQId() %>" class="preview">
                    <p><%= HtmlUtil.escape(q.getStem()) %></p>
                    <ol>
                        <% for (QOption opt : q.getOptions()) { %>
                            <li><%= HtmlUtil.escape(opt.getText()) %></li>
                        <% } %>
                    </ol>
                    <small>답안 및 해설은 권한 필요</small>
                </div>
            </article>
        <% } %>
    <% } %>
</section>
<div class="pagination">
    <% for (int i = 0; i < pages; i++) { %>
        <a href="?page=<%= i %>"><%= (i + 1) %></a>
    <% } %>
</div>
</body>
</html>
