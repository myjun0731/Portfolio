<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>오류가 발생했습니다</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="auth-body" style="align-items:flex-start;">
<div class="auth-card" style="max-width:520px; text-align:center;">
    <h1 style="color:var(--danger);">문제가 발생했어요</h1>
    <p>요청을 처리하는 동안 오류가 발생했습니다.<br>잠시 후 다시 시도해 주세요.</p>
    <a class="btn btn-primary" style="margin-top:24px;" href="${pageContext.request.contextPath}/main">메인으로 돌아가기</a>
</div>
</body>
</html>
