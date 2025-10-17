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
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; background: #f9fafb; }
        .grid { display: grid; gap: 16px; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); }
        .card { background: #fff; padding: 16px; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.05); }
        textarea { width: 100%; min-height: 80px; }
        button { margin-top: 8px; padding: 8px 12px; border: none; background: #3b82f6; color: #fff; border-radius: 6px; cursor: pointer; }
    </style>
</head>
<body>
    <a href="${pageContext.request.contextPath}/main">메인으로</a>
    <h1>오답 노트</h1>
    <section>
        <h2>오답만 다시 풀기</h2>
        <div class="grid">
            <% for (Question q : retry) { %>
                <div class="card">
                    <h3><%= HtmlUtil.escape(q.getStem()) %></h3>
                    <ol>
                        <% for (QOption opt : q.getOptions()) { %>
                            <li><%= HtmlUtil.escape(opt.getText()) %></li>
                        <% } %>
                    </ol>
                    <form method="post" action="${pageContext.request.contextPath}/study/review">
                        <input type="hidden" name="qid" value="<%= q.getQId() %>">
                        <label><input type="checkbox" name="star" value="Y"> 즐겨찾기</label>
                        <textarea name="memo" placeholder="메모"></textarea>
                        <button type="submit">메모 저장</button>
                    </form>
                </div>
            <% } %>
        </div>
    </section>
    <section style="margin-top:20px;">
        <h2>누적 기록</h2>
        <table>
            <tr><th>문항</th><th>마지막 오답</th><th>횟수</th></tr>
            <% for (WrongNote note : wrongNotes) { %>
                <tr>
                    <td><%= note.getQuestionId() %></td>
                    <td><%= note.getLastWrongAt() %></td>
                    <td><%= note.getAttempts() %></td>
                </tr>
            <% } %>
        </table>
    </section>
</body>
</html>
