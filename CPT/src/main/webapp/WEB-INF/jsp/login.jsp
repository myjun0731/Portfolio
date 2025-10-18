<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - 정보처리산업기사 CBT</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="auth-body">
<div class="auth-grid">
    <section class="auth-welcome">
        <div class="auth-brand">
            <span class="brand-mark">CBT</span>
            <div class="brand-copy">
                <strong>정보처리산업기사 CBT</strong>
                <span>Competency-based Testing Studio</span>
            </div>
        </div>
        <h1>학습 여정을 위한 Claude 스타일 허브</h1>
        <p>로그인하면 NCS 단원 맵 탐색, CBT 응시, 오답 리커버리, 목표 관리까지 하나의 보드에서 관리할 수 있습니다.</p>
        <ul class="auth-highlights">
            <li>문항 미리보기와 태그 기반 필터링</li>
            <li>시드 고정 CBT 셔플 및 오프라인 복구</li>
            <li>오답 노트와 간격 반복 복습 제안</li>
        </ul>
    </section>
    <section class="auth-card" aria-labelledby="authTitle">
        <h1 id="authTitle">로그인</h1>
        <p class="auth-subcopy">계정을 입력해 학습 대시보드와 CBT 기능을 이어서 진행하세요.</p>

        <c:if test="${not empty requestScope.error}">
            <div class="error-msg" role="alert">
                <c:out value="${requestScope.error}" />
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login" class="form-grid auth-form">
            <div class="form-field">
                <label for="email">이메일</label>
                <input type="email" id="email" name="email" placeholder="admin@test.com" required autocomplete="username">
            </div>
            <div class="form-field">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" placeholder="비밀번호 입력" required autocomplete="current-password">
            </div>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">로그인</button>
            </div>
        </form>

        <p class="meta auth-meta">테스트 계정: <strong>admin@test.com</strong> / <strong>admin123</strong></p>
    </section>
</div>
</body>
</html>
