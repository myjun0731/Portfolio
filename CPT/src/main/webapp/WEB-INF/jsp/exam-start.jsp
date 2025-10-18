<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://cbt.com/tags/core" %>
<%@ taglib prefix="fn" uri="http://cbt.com/tags/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>응시 세션 생성</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="app-frame">
<jsp:include page="/WEB-INF/jsp/include/app-header.jspf" />
<main class="app-shell">
    <section class="page-hero">
        <div class="page-hero__lede">
            <span class="badge soft">Exam Session</span>
            <h1>🧭 CBT 응시 시작</h1>
            <p class="subtitle">문항과 선지는 서버에서 셔플되며, 재접속 시 동일 순서를 유지합니다. 시험을 선택해 세션을 생성하세요.</p>
        </div>
    </section>

    <section class="app-section">
        <div class="section-headline">
            <h2>세션 선택</h2>
            <div class="section-actions">
                <span class="pill">선택 가능 <c:out value="${paperCount}" />회차</span>
            </div>
        </div>
        <div class="alert exam-guide">
            <ul>
                <li>타이머는 서버 시간을 기준으로 동작하며, 종료 시 자동 제출됩니다.</li>
                <li>문항 이동 시 자동 저장되며 네트워크 장애가 발생해도 복구 후 즉시 재전송됩니다.</li>
                <li>시험 중 세션을 한 번까지 재개할 수 있으며, 마지막으로 접속한 탭만 유효합니다.</li>
            </ul>
        </div>
        <c:if test="${paperCount == 0}">
            <div class="alert warning">등록된 기출 회차가 없습니다. 운영자 메뉴에서 시험지를 추가한 뒤 다시 시도해주세요.</div>
        </c:if>
        <form method="post" class="exam-start-form">
            <label class="filter-field">
                <span>응시할 시험</span>
                <select id="paperId" name="paperId" class="paper-select" required <c:if test="${paperCount == 0}">disabled</c:if>>
                    <c:forEach var="paper" items="${papers}">
                        <option value="${paper.paperId}"><c:out value="${paper.examYear}" />년 <c:out value="${paper.examRound}" />회 - <c:out value="${paper.name}" /></option>
                    </c:forEach>
                </select>
            </label>
            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/papers/quick" class="btn btn-ghost">회차 목록</a>
                <button type="submit" class="btn btn-primary" <c:if test="${paperCount == 0}">disabled</c:if>>세션 시작</button>
            </div>
        </form>
    </section>
</main>
</body>
</html>
