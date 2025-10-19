<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.ExamPaper" %>
<%@ page import="com.cbt.model.User" %>
<%
    User user = (User) request.getAttribute("user");
    List<ExamPaper> papers = (List<ExamPaper>) request.getAttribute("papers");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>메인 대시보드 - CBT Studio</title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body>
<div class="app-shell">
    <header class="app-header">
        <div class="brand"><span class="brand-dot"></span>CBT Studio</div>
        <nav class="nav-links">
            <a class="nav-link active" href="/main">대시보드</a>
            <a class="nav-link" href="/main#papers">기출 회차</a>
            <a class="nav-link" href="/main#system">시스템 안내</a>
        </nav>
        <div class="nav-links">
            <span class="nav-link is-static">안녕하세요, <%= user != null ? user.getName() : "사용자" %> 님</span>
            <a class="nav-link" href="/logout">로그아웃</a>
        </div>
    </header>

    <main class="app-content">
        <section class="surface surface-card">
            <div>
                <p class="muted">오늘도 한 걸음씩, 검정고시 합격을 향하여.</p>
                <h2 class="section-title">맞춤 기출 세트를 선택해 바로 응시하세요.</h2>
            </div>
            <ul class="list-inline">
                <li>실전 모드</li>
                <li>정답 즉시 채점</li>
                <li>오답 자동 노트</li>
            </ul>
            <footer>
                <a class="cta-btn" href="/exam/start">새 시험 시작</a>
            </footer>
        </section>

        <section id="papers">
            <header class="section-header">
                <h2 class="section-title">기출 회차 보관함</h2>
                <span class="muted">총 <%= papers != null ? papers.size() : 0 %>개 회차</span>
            </header>
            <% if (papers != null && !papers.isEmpty()) { %>
                <div class="surface surface-grid">
                    <% for (ExamPaper paper : papers) { %>
                        <article class="surface-card">
                            <div>
                                <h3><%= paper.getName() != null ? paper.getName() : "미지정 시험" %></h3>
                                <p>연도/회차: <%= paper.getExamYear() != null ? paper.getExamYear() : "-" %>년 <%= paper.getExamRound() != null ? paper.getExamRound() : "-" %>회</p>
                                <p class="muted">제한 시간 <%= paper.getTimeLimitMin() %>분 · 모드 <%= paper.getMode() %></p>
                            </div>
                            <footer>
                                <form method="post" action="/exam/start">
                                    <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                    <button type="submit" class="cta-btn">해당 회차 응시</button>
                                </form>
                            </footer>
                        </article>
                    <% } %>
                </div>
            <% } else { %>
                <div class="surface empty-state">
                    준비된 시험지가 없습니다. 관리자에게 문의하거나 신규 시험을 생성하세요.
                </div>
            <% } %>
        </section>

        <section id="system" class="surface surface-card">
            <h2 class="section-title">시스템 안내</h2>
            <div class="alert-banner">
                <div>
                    <strong>안전한 CBT 환경</strong>
                    <p class="muted">응시 중 자동 저장과 초 단위 타이머로 안정적인 시험 환경을 제공합니다.</p>
                </div>
                <a class="cta-btn" href="/policy">정책 확인</a>
            </div>
        </section>
    </main>
</div>
</body>
</html>
