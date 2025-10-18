<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/cbt-core.tld" %>
<%@ taglib prefix="fn" uri="/WEB-INF/tld/cbt-functions.tld" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>CBT 응시</title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body class="exam-body">
<div class="exam-shell">
    <aside class="exam-sidebar">
        <section class="exam-sidebar__section">
            <h2>남은 시간</h2>
            <div class="timer-display" id="timer"></div>
            <div class="session-info">세션 ID <c:out value="${examSession.sessId}" /></div>
            <div class="session-info">모드 <c:out value="${modeLabel}" default="기출" /></div>
        </section>
        <div class="exam-warning" id="warning" style="display:none;">남은 시간 알림</div>
        <div class="exam-warning offline" id="offline" style="display:none;">오프라인 상태입니다. 연결 복구 후 자동 저장됩니다.</div>
        <c:if test="${not strictNavigation}">
            <section class="exam-sidebar__section">
                <h2>문항 내비게이터</h2>
                <div class="exam-badges" id="navigator" role="list">
                    <c:forEach var="question" items="${questions}" varStatus="loop">
                        <button type="button" class="exam-badge" data-qid="${question.qId}" onclick="goQuestion(${loop.index})" role="listitem">Q${loop.index + 1}</button>
                    </c:forEach>
                </div>
            </section>
        </c:if>
        <section class="exam-sidebar__section">
            <form id="submitForm" method="post" action="/exam/submit" class="exam-submit">
                <input type="hidden" name="sid" value="${examSession.sessId}">
                <button type="submit" class="btn btn-primary">시험 제출</button>
            </form>
        </section>
    </aside>

    <main class="exam-main" data-strict="${strictNavigation}">
        <div class="exam-mode-banner">
            <c:choose>
                <c:when test="${strictNavigation}">실전 모드가 활성화되어 문항을 순차적으로 진행합니다.</c:when>
                <c:otherwise><c:out value="${modeLabel}" default="연습 세션" /> 모드로 자유롭게 이동할 수 있습니다.</c:otherwise>
            </c:choose>
        </div>
        <div class="exam-progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
            <div class="exam-progress__bar" id="progressBar"></div>
        </div>
        <c:forEach var="question" items="${questions}" varStatus="loop">
            <article class="exam-question" id="q${question.qId}" data-index="${loop.index}" <c:if test="${not loop.first}">style="display:none;"</c:if>>
                <header class="exam-question__header">
                    <div class="exam-question__meta">
                        <span class="badge soft">Q${loop.index + 1}</span>
                        <span class="meta"><c:out value="${question.examYear}" default="미상" />년 <c:out value="${question.examRound}" default="" />회 · 난이도 <c:out value="${question.diff}" /></span>
                        <button type="button" class="flag-toggle" onclick="toggleFlag(${question.qId});">🔖</button>
                    </div>
                    <h2><c:out value="${question.stem}" /></h2>
                </header>
                <section class="option-list">
                    <c:forEach var="option" items="${question.options}">
                        <label>
                            <input type="radio" name="q-${question.qId}" value="${option.optNo}" <c:if test="${not option.active}">disabled</c:if>>
                            <span><c:out value="${option.text}" /></span>
                        </label>
                    </c:forEach>
                </section>
                <c:if test="${not empty question.hint or not empty question.videoUrl}">
                    <div class="exam-hints">
                        <c:if test="${not empty question.hint}">
                            <details class="hint-panel">
                                <summary>힌트 보기</summary>
                                <p><c:out value="${question.hint}" /></p>
                            </details>
                        </c:if>
                        <c:if test="${not empty question.videoUrl}">
                            <a class="hint-link" href="${question.videoUrl}" target="_blank" rel="noopener">해설 영상 열기</a>
                        </c:if>
                    </div>
                </c:if>
                <footer class="exam-question__footer">
                    <button type="button" class="btn prev-question" <c:if test="${strictNavigation}">disabled</c:if>>이전</button>
                    <button type="button" class="btn btn-primary next-question">다음</button>
                </footer>
            </article>
        </c:forEach>
    </main>
</div>

<script>
    const sessionId = <c:out value="${examSession.sessId}" default="0" />;
    let remaining = <c:out value="${remaining}" default="0" />;
    const debounce = {};
    const queue = [];
    let offline = false;
    const strictMode = ${strictNavigation ? "true" : "false"};
    let currentIndex = 0;
    const totalQuestions = ${fn:length(questions)};
    const progressBar = document.getElementById('progressBar');
    const progressContainer = document.querySelector('.exam-progress');

    function updateProgress() {
        if (!progressBar || !progressContainer) {
            return;
        }
        const answered = document.querySelectorAll('.option-list input:checked').length;
        const byAnswered = totalQuestions === 0 ? 0 : (answered / totalQuestions) * 100;
        const byPosition = totalQuestions === 0 ? 0 : ((currentIndex + 1) / totalQuestions) * 100;
        const progress = Math.min(100, Math.max(byAnswered, byPosition));
        progressBar.style.width = progress + '%';
        progressContainer.setAttribute('aria-valuenow', Math.round(progress));
    }

    function renderTimer() {
        const timer = document.getElementById('timer');
        const minutes = Math.floor(remaining / 60);
        const seconds = remaining % 60;
        timer.textContent = `${minutes.toString().padStart(2,'0')}:${seconds.toString().padStart(2,'0')}`;
        if ([600,300,60].includes(remaining)) {
            const warn = document.getElementById('warning');
            warn.style.display = 'block';
            warn.textContent = `남은 시간 ${minutes}분 ${seconds}초 입니다.`;
        }
        if (remaining <= 0) {
            document.getElementById('submitForm').submit();
        } else {
            remaining--;
            setTimeout(renderTimer, 1000);
        }
    }

    function goQuestion(index, force) {
        if (strictMode && index < currentIndex && !force) {
            return;
        }
        currentIndex = index;
        const articles = document.querySelectorAll('.exam-question');
        articles.forEach((article, idx) => {
            article.style.display = idx === index ? 'block' : 'none';
        });
        updateNavState();
        updateProgress();
    }

    function updateNavState() {
        const prevButtons = document.querySelectorAll('.prev-question');
        const nextButtons = document.querySelectorAll('.next-question');
        prevButtons.forEach(btn => {
            btn.disabled = strictMode || currentIndex === 0;
        });
        nextButtons.forEach(btn => {
            btn.disabled = currentIndex >= totalQuestions - 1;
        });
    }

    function nextQuestion() {
        if (currentIndex < totalQuestions - 1) {
            goQuestion(currentIndex + 1, true);
        }
    }

    function prevQuestion() {
        if (!strictMode && currentIndex > 0) {
            goQuestion(currentIndex - 1, true);
        }
    }

    document.querySelectorAll('.next-question').forEach(btn => btn.addEventListener('click', nextQuestion));
    document.querySelectorAll('.prev-question').forEach(btn => btn.addEventListener('click', prevQuestion));

    function scheduleSave(qid) {
        clearTimeout(debounce[qid]);
        debounce[qid] = setTimeout(() => saveAnswer(qid), 500);
    }

    function saveAnswer(qid) {
        const radios = document.querySelectorAll(`input[name="q-${qid}"]`);
        let choice = null;
        radios.forEach(r => { if (r.checked) { choice = r.value; } });
        const payload = new URLSearchParams();
        payload.append('sid', sessionId);
        payload.append('qid', qid);
        if (choice) { payload.append('choice', choice); }
        payload.append('elapsed', <c:out value="${examSession.timeLimitMin}" default="0" /> * 60 - remaining);
        payload.append('flag', flags.has(qid) ? 'Y' : 'N');
        const task = () => fetch('/exam/answer', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: payload.toString()
        }).then(() => updateStatus(qid, choice !== null)).catch(() => {
            queue.push(task);
            setOffline(true);
        });
        task();
    }

    function updateStatus(qid, answered) {
        const badge = document.querySelector(`.exam-badge[data-qid="${qid}"]`);
        if (badge) {
            badge.classList.toggle('answered', answered);
            badge.classList.toggle('review', flags.has(qid));
        }
        updateProgress();
    }

    const flags = new Set();
    function toggleFlag(qid) {
        if (flags.has(qid)) {
            flags.delete(qid);
        } else {
            flags.add(qid);
        }
        updateStatus(qid, document.querySelector(`input[name="q-${qid}"]:checked`) != null);
        scheduleSave(qid);
    }

    function setOffline(state) {
        offline = state;
        document.getElementById('offline').style.display = state ? 'block' : 'none';
    }

    window.addEventListener('online', () => {
        setOffline(false);
        while (queue.length) {
            const task = queue.shift();
            task();
        }
    });
    window.addEventListener('offline', () => setOffline(true));

    document.querySelectorAll('.option-list input').forEach(input => {
        input.addEventListener('change', event => {
            const qid = parseInt(event.target.name.split('-')[1], 10);
            scheduleSave(qid);
            updateStatus(qid, true);
        });
    });

    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            navigator.sendBeacon('/exam/focus', new URLSearchParams({ sid: sessionId }));
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'ArrowRight') {
            nextQuestion();
        } else if (event.key === 'ArrowLeft' && !strictMode) {
            prevQuestion();
        } else if (/^[1-4]$/.test(event.key)) {
            const articles = document.querySelectorAll('.exam-question');
            const visible = articles[currentIndex];
            const option = visible ? visible.querySelectorAll('input')[parseInt(event.key, 10) - 1] : null;
            if (option) {
                option.checked = true;
                const qid = parseInt(option.name.split('-')[1], 10);
                scheduleSave(qid);
                updateStatus(qid, true);
            }
        }
    });

    goQuestion(0, true);
    renderTimer();
    updateProgress();
</script>
</body>
</html>
