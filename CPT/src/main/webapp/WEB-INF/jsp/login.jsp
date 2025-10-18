<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - 정보처리산업기사 CBT</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="auth-body">
<div class="auth-card">
    <div class="auth-brand">
        <span class="brand-mark">CBT</span>
        <div class="brand-copy">
            <strong>정보처리산업기사 CBT</strong>
            <span>Claude 톤의 프로덕션 UI</span>
        </div>
    </div>
    <h1>로그인</h1>
    <p>계정으로 로그인하여 학습 대시보드와 CBT 시험 기능을 이용하세요.</p>

    <% if (request.getAttribute("error") != null) { %>
        <div class="error-msg">
            <%= request.getAttribute("error") %>
        </div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/login" class="form-grid">
        <div>
            <label for="email">이메일</label>
            <input type="email" id="email" name="email" placeholder="admin@test.com" required>
        </div>
        <div>
            <label for="password">비밀번호</label>
            <input type="password" id="password" name="password" placeholder="비밀번호 입력" required>
        </div>
        <button type="submit" class="btn btn-primary">로그인</button>
    </form>

    <p class="meta" style="margin-top: 18px;">테스트 계정: admin@test.com / admin123</p>
</div>
</body>
</html>
