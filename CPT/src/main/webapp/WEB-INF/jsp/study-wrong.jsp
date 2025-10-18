<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    List<Question> retry = (List<Question>) request.getAttribute("retry");
    List<WrongNote> wrongNotes = (List<WrongNote>) request.getAttribute("wrongNotes");
    if (retry == null) {
        retry = Collections.emptyList();
    }
    if (wrongNotes == null) {
        wrongNotes = Collections.emptyList();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>오답 노트</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Review Center</span>
            <h1>📝 오답 노트</h1>
            <p class="subtitle">최근 오답 문항을 다시 풀고 개인 메모를 남겨 복습 루틴을 자동화하세요.</p>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>오답만 다시 풀기</h2>
            <div class="section-actions">
                <span class="pill">최근 오답 <%= retry.size() %>문항</span>
            </div>
        </div>
        <% if (retry.isEmpty()) { %>
            <div class="alert warning">최근 오답이 없습니다. CBT를 응시하고 틀린 문항을 자동으로 모아보세요.</div>
        <% } else { %>
            <div class="question-collection__list">
                <% for (Question q : retry) { %>
                    <article class="review-card">
                        <h3><%= HtmlUtil.escape(q.getStem()) %></h3>
                        <ol>
                            <% for (QOption opt : q.getOptions()) { %>
                                <li><%= HtmlUtil.escape(opt.getText()) %></li>
                            <% } %>
                        </ol>
                        <form method="post" action="${pageContext.request.contextPath}/study/review" class="review-form">
                            <input type="hidden" name="qid" value="<%= q.getQId() %>">
                            <label class="review-flag">
                                <input type="checkbox" name="star" value="Y"> 즐겨찾기
                            </label>
                            <label class="filter-field">
                                <span>메모</span>
                                <textarea id="memo-<%= q.getQId() %>" name="memo" placeholder="학습 노트를 남겨보세요."></textarea>
                            </label>
                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">메모 저장</button>
                            </div>
                        </form>
                    </article>
                <% } %>
            </div>
        <% } %>
    </section>

    <section class="app-section compact">
        <div class="section-headline">
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
</main>
</body>
</html>
