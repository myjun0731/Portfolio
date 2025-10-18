<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    List<Question> retry = (List<Question>) request.getAttribute("retry");
    List<WrongNote> wrongNotes = (List<WrongNote>) request.getAttribute("wrongNotes");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>오답 노트</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="app-shell">
    <header class="page-header">
        <div>
            <h1>📝 오답 노트</h1>
            <p class="subtitle">최근 오답 문항을 다시 풀고 개인 메모를 남겨 복습하세요.</p>
        </div>
        <nav class="nav-links">
            <a class="nav-link" href="${pageContext.request.contextPath}/main">대시보드</a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/study/wrong">오답 노트</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/goal">학습 목표</a>
        </nav>
    </header>

    <section class="card">
        <div class="card-header">
            <h2>오답만 다시 풀기</h2>
        </div>
        <div class="card-grid">
            <% for (Question q : retry) { %>
                <div class="card" style="box-shadow:none;border:1px solid var(--border);">
                    <h3 style="font-size:18px; line-height:1.5;"><%= HtmlUtil.escape(q.getStem()) %></h3>
                    <ol style="margin:16px 0 0 18px; padding:0;">
                        <% for (QOption opt : q.getOptions()) { %>
                            <li style="margin-bottom:6px;"> <%= HtmlUtil.escape(opt.getText()) %></li>
                        <% } %>
                    </ol>
                    <form method="post" action="${pageContext.request.contextPath}/study/review" class="form-grid" style="margin-top:16px;">
                        <input type="hidden" name="qid" value="<%= q.getQId() %>">
                        <label style="display:flex; align-items:center; gap:8px; font-weight:500; color:var(--text-muted);">
                            <input type="checkbox" name="star" value="Y"> 즐겨찾기
                        </label>
                        <div>
                            <label for="memo-<%= q.getQId() %>">메모</label>
                            <textarea id="memo-<%= q.getQId() %>" name="memo" placeholder="학습 노트를 남겨보세요." style="min-height:96px;"></textarea>
                        </div>
                        <div style="display:flex; justify-content:flex-end;">
                            <button type="submit" class="btn btn-primary">메모 저장</button>
                        </div>
                    </form>
                </div>
            <% } %>
        </div>
    </section>

    <section class="card">
        <div class="card-header">
            <h2>누적 기록</h2>
        </div>
        <table class="table">
            <tr><th>문항 ID</th><th>마지막 오답일</th><th>오답 횟수</th></tr>
            <% for (WrongNote note : wrongNotes) { %>
                <tr>
                    <td><%= note.getQuestionId() %></td>
                    <td><%= note.getLastWrongAt() %></td>
                    <td><%= note.getAttempts() %></td>
                </tr>
            <% } %>
        </table>
    </section>
</div>
</body>
</html>
