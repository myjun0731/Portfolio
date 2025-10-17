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
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background: #1f2937; color: #fff; }
        .layout { display: flex; min-height: 100vh; }
        .sidebar { width: 240px; background: rgba(15,23,42,0.9); padding: 16px; overflow-y: auto; }
        .main { flex: 1; padding: 20px; background: #111827; }
        .timer { font-size: 24px; margin-bottom: 12px; }
        .question { background: rgba(17,24,39,0.8); padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .options label { display: block; background: rgba(55,65,81,0.6); padding: 12px; border-radius: 8px; margin-bottom: 10px; cursor: pointer; }
        .options input { margin-right: 12px; }
        .flag { color: #fbbf24; cursor: pointer; margin-left: 8px; }
        .status-indicator { display: inline-block; width: 28px; height: 28px; border-radius: 6px; line-height: 28px; text-align: center; margin: 4px; background: #4b5563; color: #fff; cursor: pointer; position: relative; }
        .status-indicator.review::after { content: '\1F516'; position: absolute; top: -6px; right: -6px; font-size: 12px; }
        .status-indicator.answered { background: #2563eb; }
        .warning-banner { display: none; background: #f59e0b; color: #111827; padding: 8px; border-radius: 6px; margin-bottom: 10px; }
        .offline { background: #dc2626; }
        button { background: #10b981; color: #111827; padding: 12px 20px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="timer" id="timer"></div>
        <div class="warning-banner" id="warning">네트워크 연결이 불안정합니다. 재시도 중...</div>
        <div class="warning-banner offline" id="offline">오프라인입니다. 연결 복구 시 자동 저장됩니다.</div>
        <div id="navigator">
            <% int index = 1; for (Question q : questions) { %>
                <div class="status-indicator" data-qid="<%= q.getQId() %>" onclick="goQuestion(<%= index - 1 %>)"><%= index++ %></div>
            <% } %>
        </div>
        <form id="submitForm" method="post" action="${pageContext.request.contextPath}/exam/submit">
            <input type="hidden" name="sid" value="<%= sessionBean.getSessId() %>">
            <button type="submit">시험 제출</button>
        </form>
    </aside>
    <main class="main">
        <% int idx = 0; for (Question q : questions) { idx++; %>
            <article class="question" data-index="<%= idx - 1 %>">
                <header>
                    <h2>Q<%= idx %>. <%= HtmlUtil.escape(q.getStem()) %></h2>
                    <small><%= q.getExamYear() %>년 <%= q.getExamRound() %>회 · 난이도 <%= q.getDiff() %>
                        <span class="flag" onclick="toggleFlag(<%= q.getQId() %>);event.stopPropagation();">🔖</span>
                    </small>
                </header>
                <section class="options">
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
            document.getElementById('warning').style.display = 'block';
            document.getElementById('warning').textContent = `남은 시간 ${minutes}분 ${seconds}초`;
        }
        if (remaining <= 0) {
            document.getElementById('submitForm').submit();
        } else {
            remaining--;
            setTimeout(renderTimer, 1000);
        }
    }

    function goQuestion(index) {
        const articles = document.querySelectorAll('.question');
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
        const badge = document.querySelector(`.status-indicator[data-qid="${qid}"]`);
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

    document.querySelectorAll('.options input').forEach(input => {
        input.addEventListener('change', event => {
            const qid = parseInt(event.target.name.split('-')[1], 10);
            scheduleSave(qid);
        });
    });

    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            navigator.sendBeacon('${pageContext.request.contextPath}/exam/focus', new URLSearchParams({ sid: sessionId }));
        }
    });

    document.addEventListener('keydown', (event) => {
        const articles = document.querySelectorAll('.question');
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
            }
        }
    });

    goQuestion(0);
    renderTimer();
</script>
</body>
</html>
