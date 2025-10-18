<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>오류 발생</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; background: #f4f6fb; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
        .card { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 20px 40px rgba(0,0,0,0.08); text-align: center; max-width: 420px; }
        h1 { color: #e74c3c; margin-bottom: 16px; }
        p { color: #4b5563; margin-bottom: 24px; }
        a { display: inline-block; padding: 10px 24px; background: #667eea; color: white; border-radius: 6px; text-decoration: none; }
        a:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="card">
        <h1>⚠️ 오류가 발생했습니다.</h1>
        <p><%= request.getAttribute("error") != null ? request.getAttribute("error") : "잠시 후 다시 시도해주세요." %></p>
        <a href="<%= request.getContextPath() %>/main">메인으로 이동</a>
    </div>
</body>
</html>
