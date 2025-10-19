<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - 정보처리산업기사 CBT</title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body>
<div class="auth-shell">
    <section class="auth-card">
        <header>
            <h1>CBT Studio</h1>
            <p class="muted">검정고시 대비를 위한 모던 CBT 환경에 오신 것을 환영합니다.</p>
        </header>

        <% if (error != null) { %>
            <div class="error-message"><%= error %></div>
        <% } %>

        <form method="post" action="/login" class="form-stack">
            <div class="form-field">
                <label for="email">이메일</label>
                <input type="email" id="email" name="email" placeholder="admin@test.com" required>
            </div>
            <div class="form-field">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" placeholder="비밀번호" required>
            </div>
            <div class="form-actions">
                <button type="submit" class="cta-btn">로그인</button>
                <span class="utility-link">테스트 계정: admin@test.com / admin123</span>
            </div>
        </form>

        <div class="auth-footer">
            <span>© <%= java.time.Year.now() %> CBT Studio</span>
            <span>Secure Login Portal</span>
        </div>
    </section>
</div>
</body>
</html>
