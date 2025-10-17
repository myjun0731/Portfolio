<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>오류가 발생했습니다</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; background: #f9f9f9; margin: 0; padding: 40px; }
        .error-box { max-width: 500px; margin: 80px auto; background: white; border-radius: 8px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); padding: 40px; text-align: center; }
        h1 { color: #e74c3c; margin-bottom: 20px; }
        p { color: #555; line-height: 1.6; }
        a { display: inline-block; margin-top: 30px; padding: 10px 20px; background: #667eea; color: #fff; text-decoration: none; border-radius: 6px; }
        a:hover { background: #5568d3; }
    </style>
</head>
<body>
<div class="error-box">
    <h1>문제가 발생했어요</h1>
    <p>
        요청을 처리하는 동안 오류가 발생했습니다.<br>
        잠시 후 다시 시도해 주세요.
    </p>
    <a href="${pageContext.request.contextPath}/main">메인으로 돌아가기</a>
</div>
</body>
</html>
