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
    <title>응시 세션 생성</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="app-shell">
    <header class="page-header">
        <div>
            <h1>🧭 CBT 응시 시작</h1>
            <p class="subtitle">문항과 선지는 서버에서 셔플되며, 재접속 시 동일한 순서를 유지합니다.</p>
        </div>
        <nav class="nav-links">
            <a class="nav-link" href="${pageContext.request.contextPath}/main">대시보드</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/paper/gii.jsp">연·회차</a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/exam/start">응시 준비</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/study/wrong">오답 노트</a>
        </nav>
    </header>

    <section class="card">
        <div class="card-header">
            <div>
                <h2>세션 선택</h2>
                <p class="subtitle">시험을 선택하면 동일한 시드로 응시 세션이 생성되고, 남은 시간은 서버 기준으로 관리됩니다.</p>
            </div>
        </div>
        <div class="alert" style="margin-bottom:24px;">
            <ul style="padding-left:18px; margin:0;">
                <li>타이머는 서버 시간을 기준으로 동작하며, 종료 시 자동 제출됩니다.</li>
                <li>문항 이동 시 자동 저장되며 네트워크 장애가 발생해도 복구 후 즉시 재전송됩니다.</li>
                <li>시험 중 세션을 한 번까지 재개할 수 있으며, 마지막으로 접속한 탭만 유효합니다.</li>
            </ul>
        </div>
        <form method="post" class="form-grid">
            <div>
                <label for="paperId">응시할 시험</label>
                <select id="paperId" name="paperId" class="paper-select" required>
                    <% for (ExamPaper paper : papers) { %>
                        <option value="<%= paper.getPaperId() %>"><%= paper.getExamYear() %>년 <%= paper.getExamRound() %>회 - <%= paper.getName() %></option>
                    <% } %>
                </select>
            </div>
            <div style="display:flex; justify-content:flex-end;">
                <button type="submit" class="btn btn-primary">세션 시작</button>
            </div>
        </form>
    </section>
</div>
</body>
</html>
