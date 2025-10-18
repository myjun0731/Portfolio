<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cbt.model.*" %>
<%@ page import="com.cbt.util.HtmlUtil" %>
<%
    ExamSession sessionBean = (ExamSession) request.getAttribute("session");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    long remaining = (Long) request.getAttribute("remaining");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>CBT 응시</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="exam-body">
<div class="exam-shell">
    <aside class="exam-sidebar">
        <section class="exam-sidebar__section">
            <h2>남은 시간</h2>
            <div class="timer-display" id="timer"></div>
            <div class="session-info">세션 ID <%= sessionBean.getSessId() %></div>
        </section>
        <div class="exam-warning" id="warning" style="display:none;">남은 시간 알림</div>
        <div class="exam-warning offline" id="offline" style="display:none;">오프라인 상태입니다. 연결 복구 후 자동 저장됩니다.</div>
        <section class="exam-sidebar__section">
            <h2>문항 내비게이터</h2>
            <div class="exam-badges" id="navigator" role="list">
                <% int index = 1; for (Question q : questions) { %>
                    <button type="button" class="exam-badge" data-qid="<%= q.getQId() %>" onclick="goQuestion(<%= index - 1 %>)" role="listitem">Q<%= index++ %></button>
                <% } %>
            </div>
        </section>
        <section class="exam-sidebar__section">
            <form id="submitForm" method="post" action="${pageContext.request.contextPath}/exam/submit" class="exam-submit">
                <input type="hidden" name="sid" value="<%= sessionBean.getSessId() %>">
                <button type="submit" class="btn btn-primary">시험 제출</button>
            </form>
        </section>
    </aside>

    <main class="exam-main">
        <% int idx = 0; for (Question q : questions) { idx++; %>
            <article class="exam-question" data-index="<%= idx - 1 %>">
                <header class="exam-question__header">
                    <div class="exam-question__meta">
                        <span class="badge soft">Q<%= idx %></span>
                        <span class="meta"><%= q.getExamYear() %>년 <%= q.getExamRound() %>회 · 난이도 <%= q.getDiff() %></span>
                        <button type="button" class="flag-toggle" onclick="toggleFlag(<%= q.getQId() %>);">🔖</button>
                    </div>
                    <h2><%= HtmlUtil.escape(q.getStem()) %></h2>
                </header>
                <section class="option-list">
                    <% for (QOption opt : q.getOptions()) { %>
                        <label>
                            <input type="radio" name="q-<%= q.getQId() %>" value="<%= opt.getOptNo() %>" <%= opt.isActive() ? "" : "disabled" %>>
                            <span><%= HtmlUtil.escape(opt.getText()) %></span>
                        </label>
                    <% } %>
                </section>
            </article>
        <% } %>
    </main>
</div>

<script>
    const sessionId = <%= sessionBean.getSessId() %>;
    let remaining = <%= remaining %>;
    const debounce = {};
    const queue = [];
    let offline = false;

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

    function goQuestion(index) {
        const articles = document.querySelectorAll('.exam-question');
        articles.forEach((article, idx) => {
            article.style.display = idx === index ? 'block' : 'none';
        });
    }

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
        payload.append('elapsed', <%= sessionBean.getTimeLimitMin() %> * 60 - remaining);
        payload.append('flag', flags.has(qid) ? 'Y' : 'N');
        const task = () => fetch('${pageContext.request.contextPath}/exam/answer', {
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
            navigator.sendBeacon('${pageContext.request.contextPath}/exam/focus', new URLSearchParams({ sid: sessionId }));
        }
    });

    document.addEventListener('keydown', (event) => {
        const articles = document.querySelectorAll('.exam-question');
        const visibleIndex = Array.from(articles).findIndex(a => a.style.display !== 'none');
        if (event.key === 'ArrowRight') {
            goQuestion(Math.min(articles.length - 1, visibleIndex + 1));
        } else if (event.key === 'ArrowLeft') {
            goQuestion(Math.max(0, visibleIndex - 1));
        } else if (/^[1-4]$/.test(event.key)) {
            const option = articles[visibleIndex].querySelectorAll('input')[parseInt(event.key, 10) - 1];
            if (option) {
                option.checked = true;
                const qid = parseInt(option.name.split('-')[1], 10);
                scheduleSave(qid);
                updateStatus(qid, true);
            }
        }
    });

    goQuestion(0);
    renderTimer();
</script>
</body>
</html>
