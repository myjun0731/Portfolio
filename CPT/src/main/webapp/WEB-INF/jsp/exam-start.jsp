<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%
    List<ExamPaper> papers = (List<ExamPaper>) request.getAttribute("papers");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>시험 시작</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 20px; background: #f7fafc; }
        .container { max-width: 800px; margin: 0 auto; }
        .notice { background: #ebf4ff; border: 1px solid #c3dafe; padding: 16px; border-radius: 8px; margin-bottom: 20px; }
        .paper-select { width: 100%; padding: 10px; margin-bottom: 20px; }
        button { background: #2b6cb0; color: #fff; border: none; padding: 12px 20px; border-radius: 6px; cursor: pointer; }
    </style>
</head>
<body>
<div class="container">
    <h1>응시 세션 생성</h1>
    <p><a href="${pageContext.request.contextPath}/main">메인으로</a></p>
    <div class="notice">
        <strong>안내</strong>
        <ul>
            <li>문항과 선지는 서버에서 셔플되며 재접속 시 동일한 순서를 유지합니다.</li>
            <li>타이머는 서버 시간을 기준으로 하며 시간이 종료되면 자동 제출됩니다.</li>
            <li>응시 중 오프라인이 되더라도 재연결 시 자동으로 저장된 답안을 복구합니다.</li>
        </ul>
    </div>
    <form method="post">
        <select name="paperId" class="paper-select" required>
            <% for (ExamPaper paper : papers) { %>
                <option value="<%= paper.getPaperId() %>"><%= paper.getExamYear() %>년 <%= paper.getExamRound() %>회 - <%= paper.getName() %></option>
            <% } %>
        </select>
        <button type="submit">세션 시작</button>
    </form>
</div>
</body>
</html>
