<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String message = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>오류가 발생했습니다</title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body>
<div class="auth-shell">
    <section class="auth-card error-panel">
        <header>
            <h1>서비스 오류</h1>
            <p class="muted">요청을 처리하는 중 문제가 발생했습니다. 아래 메시지를 확인해주세요.</p>
        </header>
        <div class="error-message">
            <%= message != null ? message : "잠시 후 다시 시도해주세요." %>
        </div>
        <footer class="form-actions row">
            <a class="cta-btn" href="/main">대시보드로 이동</a>
        </footer>
    </section>
</div>
</body>
</html>
