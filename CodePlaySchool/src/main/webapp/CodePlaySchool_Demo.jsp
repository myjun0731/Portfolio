<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodePlaySchool - Demo</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #fafafa; overflow: hidden; }
        .hidden { display: none !important; }
        .pattern-bg { background: repeating-linear-gradient(45deg, #f9fafb, #f9fafb 10px, #f3f4f6 10px, #f3f4f6 20px); }
        
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .fade-in { animation: fadeIn 0.3s ease-in-out; }
        
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
        
        .card-hover { transition: all 0.2s ease-in-out; }
        .card-hover:hover { box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); transform: translateY(-2px); }
        
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem; padding: 0.5rem 1rem; 
               font-size: 0.875rem; font-weight: 500; border-radius: 0.75rem; transition: all 0.15s; cursor: pointer; border: none; }
        .btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .btn-primary { background: #111827; color: white; }
        .btn-primary:hover:not(:disabled) { background: #000; }
        .btn-secondary { background: white; color: #374151; border: 1px solid #e5e7eb; }
        .btn-secondary:hover:not(:disabled) { background: #f9fafb; }
        .btn-ghost { background: transparent; color: #374151; }
        .btn-ghost:hover:not(:disabled) { background: #f3f4f6; }
        .btn-success { background: #10b981; color: white; }
        .btn-success:hover:not(:disabled) { background: #059669; }
        .btn-danger { background: #ef4444; color: white; }
        .btn-danger:hover:not(:disabled) { background: #dc2626; }
        .btn-sm { padding: 0.25rem 0.75rem; font-size: 0.75rem; }
        
        .input { width: 100%; padding: 0.5rem 0.75rem; font-size: 0.875rem; border: 1px solid #e5e7eb; 
                 border-radius: 0.75rem; background: white; transition: all 0.15s; }
        .input:focus { outline: none; border-color: #111827; box-shadow: 0 0 0 3px rgba(17,24,39,0.1); }
        
        .badge { display: inline-flex; align-items: center; padding: 0.125rem 0.5rem; font-size: 0.75rem; 
                 border-radius: 9999px; font-weight: 500; }
        .badge-primary { background: #dbeafe; color: #1e40af; }
        .badge-success { background: #d1fae5; color: #065f46; }
        .badge-warning { background: #fef3c7; color: #92400e; }
        .badge-danger { background: #fee2e2; color: #991b1b; }
        .badge-gray { background: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
        
        .table { width: 100%; font-size: 0.875rem; }
        .table thead { background: #f9fafb; }
        .table th { padding: 0.75rem; text-align: left; font-weight: 600; color: #374151; }
        .table td { padding: 0.75rem; }
        .table tbody tr:nth-child(even) { background: #f9fafb; }
        .table tbody tr:hover { background: #f3f4f6; }
        
        .nav-item { transition: all 0.15s; }
        .nav-item:not(.active):hover { background: #f3f4f6; }
        .nav-item.active { background: #111827; color: white; }
        
        .role-btn { transition: all 0.15s; cursor: pointer; border: none; }
        .role-btn:not(.active):hover { background: #e5e7eb; }
        .role-btn.active { background: #111827; color: white; }
        
        .tag { display: inline-flex; align-items: center; padding: 0.25rem 0.5rem; font-size: 0.75rem; 
               border-radius: 0.75rem; border: 1px solid #e5e7eb; background: white; color: #374151; }
        
        .card { background: white; border-radius: 1rem; box-shadow: 0 1px 3px 0 rgba(0,0,0,0.1); border: 1px solid #f3f4f6; }
        .card-body { padding: 1rem; }
        
        .section-title { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.75rem; }
        .section-title h3 { font-size: 1.125rem; font-weight: 600; color: #111827; }
        
        .output-console { background: #1f2937; color: #f9fafb; padding: 0.75rem 1rem; border-radius: 0.75rem;
                          font-family: 'Courier New', monospace; font-size: 0.875rem; min-height: 3rem;
                          display: flex; align-items: center; justify-content: center; }
        
        .code-block { background: #1f2937; color: #f9fafb; padding: 1rem; border-radius: 0.75rem; 
                      font-family: 'Courier New', monospace; font-size: 0.875rem; overflow-x: auto; line-height: 1.5; }
        
        .entry-palette-card { background: linear-gradient(180deg, #0eb7ff 0%, #0aa5ff 65%, #0796ff 100%);
                              border-radius: 1.5rem; border: none; box-shadow: 0 18px 38px rgba(10,149,255,0.22); color: white; }
        .entry-palette-card .card-body { padding: 1.5rem; }
        .entry-palette-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem; }
        .entry-palette-header h3 { font-size: 1.1rem; font-weight: 700; letter-spacing: -0.01em; }
        .entry-search { width: 100%; border-radius: 999px; border: none; background: rgba(255,255,255,0.15);
                        color: white; padding: 0.6rem 1rem; font-size: 0.85rem; transition: background 0.2s; }
        .entry-search::placeholder { color: rgba(255,255,255,0.6); }
        .entry-search:focus { outline: none; background: rgba(255,255,255,0.25); box-shadow: inset 0 0 0 2px rgba(255,255,255,0.4); }
        .block-palette { margin-top: 1rem; display: flex; flex-direction: column; gap: 1.5rem; }
        .block-palette-category { background: rgba(255,255,255,0.12); border-radius: 1.25rem; padding: 1rem; box-shadow: inset 0 0 0 1px rgba(255,255,255,0.18); }
        .block-palette-title { font-size: 0.9rem; font-weight: 700; letter-spacing: -0.01em; margin-bottom: 0.75rem; display: flex; align-items: center; gap: 0.5rem; }
        .block-stack { display: flex; flex-direction: column; gap: 0.5rem; }
        .block-item { padding: 0.65rem 0.85rem; border-radius: 1rem; color: #0b1f33; font-weight: 600;
                      box-shadow: 0 12px 18px rgba(13,80,160,0.15); border: none; text-align: center; cursor: grab;
                      transition: transform 0.15s ease, box-shadow 0.15s ease; position: relative; }
        .block-item:active { cursor: grabbing; }
        .block-item:hover { transform: translateY(-3px); box-shadow: 0 16px 26px rgba(13,80,160,0.25); }
        .block-input { display: inline-flex; align-items: center; justify-content: center; min-width: 2.5rem; padding: 0 0.5rem;
                       border-radius: 999px; background: rgba(255,255,255,0.75); color: #0b1f33; font-size: 0.8rem;
                       margin: 0 0.2rem; box-shadow: inset 0 -1px 0 rgba(0,0,0,0.08); }
        .block-category-start { background: linear-gradient(90deg, #ffe869 0%, #ffd43a 100%); }
        .block-category-flow { background: linear-gradient(90deg, #ffb969 0%, #ff9d39 100%); }
        .block-category-calc { background: linear-gradient(90deg, #82f0aa 0%, #51d48d 100%); }
        .block-category-var { background: linear-gradient(90deg, #ff9ac9 0%, #ff77a6 100%); }
        .block-category-looks { background: linear-gradient(90deg, #9fa6ff 0%, #7b87ff 100%); }
        .block-item::after { content: ''; position: absolute; top: 50%; right: -0.6rem; transform: translateY(-50%);
                             width: 1rem; height: 0.75rem; border-radius: 0.5rem; background: inherit;
                             box-shadow: inset 0 -1px 0 rgba(0,0,0,0.08); }
        .block-item:last-child::after { display: none; }
        .workspace-area { min-height: 16rem; border-radius: 1.5rem; background: #e7f3ff;
                           box-shadow: inset 0 0 0 2px rgba(9,111,255,0.2), 0 25px 45px rgba(15,73,150,0.18);
                           position: relative; overflow: hidden; transition: box-shadow 0.2s ease, transform 0.2s ease; }
        .workspace-area.drag-hover { box-shadow: inset 0 0 0 2px rgba(9,111,255,0.28), 0 28px 52px rgba(15,73,150,0.22);
                                     transform: translateY(-2px); }
        .workspace-grid { background-image: linear-gradient(0deg, rgba(9,111,255,0.08) 1px, transparent 1px),
                                           linear-gradient(90deg, rgba(9,111,255,0.08) 1px, transparent 1px);
                           background-size: 32px 32px; }
        .workspace-overlay { position: absolute; inset: 0; pointer-events: none; background: radial-gradient(circle at top left, rgba(255,255,255,0.5) 0%, transparent 55%); opacity: 0.4; transition: opacity 0.2s ease; }
        .workspace-filled .workspace-overlay { opacity: 0.15; }
        .workspace-area.drag-hover .workspace-overlay { opacity: 0.2; }
        .workspace-empty-hint { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
                                flex-direction: column; gap: 0.5rem; color: #1b365d; font-weight: 600; font-size: 0.95rem; }
        .workspace-toolbar { background: linear-gradient(90deg, rgba(255,255,255,0.92) 0%, rgba(233,244,255,0.92) 100%);
                             border-radius: 1rem; padding: 0.5rem; display: inline-flex; align-items: center; gap: 0.5rem;
                             box-shadow: 0 12px 25px rgba(9,111,255,0.18); }
        .workspace-toolbar .btn { border-radius: 0.9rem; font-weight: 600; }
        .block-workspace-item { position: absolute; padding: 0.75rem 1.1rem; border-radius: 1.25rem; color: #0b1f33;
                                 font-weight: 700; cursor: grab; box-shadow: 0 18px 26px rgba(16,80,160,0.18);
                                 min-width: 12rem; text-align: left; transition: box-shadow 0.2s ease, transform 0.2s ease;
                                 will-change: left, top; }
        .block-workspace-item.dragging { opacity: 0.85; box-shadow: 0 22px 32px rgba(16,80,160,0.24); transform: scale(1.02);
                                         cursor: grabbing; z-index: 5; }
        .block-workspace-item.snapped { transition: left 0.18s ease, top 0.18s ease; }
        .block-workspace-item .block-input { background: rgba(255,255,255,0.85); }
        .block-workspace-item button { position: absolute; top: 0.35rem; right: 0.4rem; background: transparent;
                                       border: none; color: rgba(11,31,51,0.55); cursor: pointer; }
        .block-workspace-item button:hover { color: rgba(11,31,51,0.85); }

        .puzzle-sidebar { position: sticky; top: 6.5rem; }
        @media (max-width: 1279px) {
            .puzzle-sidebar { position: static; }
        }
        
        .modal { display: none; position: fixed; z-index: 100; left: 0; top: 0; width: 100%; height: 100%; 
                 background: rgba(0,0,0,0.5); align-items: center; justify-content: center; }
        .modal.show { display: flex; }
        .modal-content { background: white; padding: 2rem; border-radius: 1rem; max-width: 500px; width: 90%; 
                         max-height: 80vh; overflow-y: auto; }
        
        .toast { position: fixed; bottom: 2rem; right: 2rem; background: #111827; color: white; padding: 1rem 1.5rem; 
                 border-radius: 0.75rem; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); z-index: 1000; 
                 display: none; align-items: center; gap: 0.5rem; }
        .toast.show { display: flex; animation: fadeIn 0.3s ease-in-out; }
        .toast.success { background: #10b981; }
        .toast.error { background: #ef4444; }
        .toast.warning { background: #f59e0b; }
        
        @media (max-width: 768px) {
            .sidebar { position: fixed; left: -16rem; z-index: 50; transition: left 0.3s; }
            .sidebar.open { left: 0; }
        }
    </style>
</head>
<body>

<%
    String currentRole = (String) session.getAttribute("userRole");
    if (currentRole == null) {
        currentRole = "student";
        session.setAttribute("userRole", currentRole);
    }
    
    String currentPage = request.getParameter("page");
    if (currentPage == null) {
        if ("student".equals(currentRole)) currentPage = "s.dashboard";
        else if ("teacher".equals(currentRole)) currentPage = "t.classes";
        else currentPage = "a.monitor";
    }
%>

<div class="flex h-screen w-full overflow-hidden bg-gray-50">
    <!-- Sidebar -->
    <div class="sidebar flex h-full w-64 flex-col gap-4 border-r border-gray-100 bg-white p-3">
        <div class="flex items-center gap-2 px-2">
            <div class="flex h-9 w-9 items-center justify-center rounded-2xl bg-black text-white">
                <i data-lucide="sparkles" class="h-5 w-5"></i>
            </div>
            <div>
                <div class="text-sm font-semibold">CodePlay School</div>
                <div class="text-xs text-gray-500">Demo Version</div>
            </div>
        </div>

        <div class="card card-body">
            <div class="mb-2 text-xs font-medium text-gray-500">역할 전환</div>
            <div class="grid grid-cols-3 gap-2">
                <button onclick="changeRole('student')" 
                    class="role-btn <%= currentRole.equals("student") ? "active" : "" %> rounded-xl px-2 py-1 text-sm"
                    data-role="student">학생</button>
                <button onclick="changeRole('teacher')" 
                    class="role-btn <%= currentRole.equals("teacher") ? "active" : "" %> rounded-xl px-2 py-1 text-sm"
                    data-role="teacher">교사</button>
                <button onclick="changeRole('admin')" 
                    class="role-btn <%= currentRole.equals("admin") ? "active" : "" %> rounded-xl px-2 py-1 text-sm"
                    data-role="admin">관리자</button>
            </div>
        </div>

        <nav class="flex-1 space-y-1" id="navMenu"></nav>

        <div class="mt-auto rounded-2xl border border-dashed border-gray-200 p-3 text-xs text-gray-500">
           <b>Demo 버전</b><br>
            ✅ 실시간 저장/로드 예정<br>
            ✅ 블록 코딩 지원 예정 <br>
            ✅ 코드 변환 기능 추가 예정
        </div>
    </div>

    <!-- Main Content -->
    <div class="flex min-w-0 flex-1 flex-col">
        <div class="flex h-14 items-center justify-between border-b border-gray-100 bg-white px-4">
            <div class="flex items-center gap-3">
                <div class="rounded-xl bg-gray-100 px-2 py-1 text-xs font-medium text-gray-700">
                    <%= currentRole.toUpperCase() %>
                </div>
                <div class="hidden text-sm text-gray-500 md:block">학습 플랫폼 차세대 UI</div>
            </div>
            <div class="flex items-center gap-2">
                <span class="tag">Demo</span>
                <span class="tag">블록↔코드</span>
                <span class="tag">실시간 저장</span>
            </div>
        </div>

        <main class="h-[calc(100vh-3.5rem)] overflow-auto p-4">
            <div id="contentArea" class="fade-in"></div>
        </main>
    </div>
</div>

<div id="toast" class="toast"></div>
<div id="modal" class="modal"><div class="modal-content" id="modalContent"></div></div>

<script>
// ==================== STATE & DATA ====================
var AppState = {
    role: '<%= currentRole %>',
    page: '<%= currentPage %>',
    optMode: true,
    runResult: '',
    blockCount: 0,
    assignments: [],
    students: [],
    charts: {},
    workspaceBlocks: [],
    aiInsights: {
        summary: '실행을 진행하면 AI가 코드 패턴을 분석해드립니다.',
        suggestions: [
            '반복되는 패턴은 반복문으로 묶어보세요.',
            '조건문에는 명확한 종료 조건을 추가하세요.'
        ],
        warnings: [],
        score: null,
        complexity: 0,
        coverage: 0
    },
    generatedCode: {
        python: 'total = 0\nfor i in range(1, 11):\n    if i % 2 == 0:\n        total += i\nprint(total)',
        javascript: 'let total = 0;\nfor (let i = 1; i <= 10; i++) {\n  if (i % 2 === 0) {\n    total += i;\n  }\n}\nconsole.log(total);'
    },
    runHistory: [],
    lastRunLabel: null,
    latestTests: []
};

var MockData = {
    studentProgress: [
        {week:'W1',progress:15},{week:'W2',progress:28},{week:'W3',progress:40},
        {week:'W4',progress:58},{week:'W5',progress:73},{week:'W6',progress:84},{week:'W7',progress:90}
    ],
    optimizationRuns: [
        {attempt:1,steps:46,time:'2.3s'},{attempt:2,steps:33,time:'1.8s'},
        {attempt:3,steps:29,time:'1.5s'},{attempt:4,steps:27,time:'1.4s'}
    ],
    badges: [
        {id:1,name:'Starter',desc:'첫 퍼즐 클리어',earned:true},
        {id:2,name:'Looper',desc:'반복문 도입',earned:true},
        {id:3,name:'Optimizer',desc:'최소 단계 달성',earned:false}
    ],
    classStats: [
        {name:'1반',accuracy:78,speed:62,students:25},
        {name:'2반',accuracy:83,speed:58,students:23},
        {name:'3반',accuracy:69,speed:74,students:27}
    ],
    learningRhythm: [
        {day:'월',focus:'조건문 심화',minutes:32,mood:'🙂'},
        {day:'화',focus:'반복 최적화',minutes:45,mood:'🔥'},
        {day:'수',focus:'함수화 연습',minutes:28,mood:'👍'},
        {day:'목',focus:'디버깅',minutes:35,mood:'🛠️'},
        {day:'금',focus:'프로젝트 정리',minutes:22,mood:'📦'}
    ],
    platformPulse: [
        {label:'API 서버',value:99,status:'정상'},
        {label:'AI 분석',value:94,status:'안정'},
        {label:'실행 샌드박스',value:91,status:'주의'},
        {label:'이벤트 큐',value:96,status:'정상'}
    ]
};

var NavItems = {
    student: [
        {key:'s.dashboard',icon:'gauge',label:'대시보드'},
        {key:'s.puzzle',icon:'puzzle',label:'퍼즐 풀이'},
        {key:'s.compare',icon:'code-2',label:'코드 변환'},
        {key:'s.results',icon:'award',label:'결과/뱃지'}
    ],
    teacher: [
        {key:'t.classes',icon:'users',label:'반 관리'},
        {key:'t.assign',icon:'clipboard-list',label:'과제 관리'},
        {key:'t.reports',icon:'bar-chart-2',label:'리포트'}
    ],
    admin: [
        {key:'a.users',icon:'layers',label:'사용자'},
        {key:'a.monitor',icon:'server',label:'모니터링'},
        {key:'a.settings',icon:'settings',label:'설정'}
    ]
};

// ==================== STORAGE ====================
function loadState() {
    try {
        var saved = localStorage.getItem('codeplay_state');
        if (saved) {
            var parsed = JSON.parse(saved);
            AppState.assignments = parsed.assignments || [];
            AppState.students = parsed.students || [];
            if (parsed.aiInsights) AppState.aiInsights = parsed.aiInsights;
            if (parsed.generatedCode) AppState.generatedCode = parsed.generatedCode;
            if (parsed.runHistory) AppState.runHistory = parsed.runHistory;
            if (parsed.lastRunLabel) AppState.lastRunLabel = parsed.lastRunLabel;
            if (parsed.latestTests) AppState.latestTests = parsed.latestTests;
        }
    } catch(e) { console.error('Load failed:', e); }
}

function saveState(silent) {
    try {
        localStorage.setItem('codeplay_state', JSON.stringify({
            assignments: AppState.assignments,
            students: AppState.students,
            aiInsights: AppState.aiInsights,
            generatedCode: AppState.generatedCode,
            runHistory: AppState.runHistory,
            lastRunLabel: AppState.lastRunLabel,
            latestTests: AppState.latestTests
        }));
        if (!silent) showToast('데이터 저장됨', 'success');
    } catch(e) { if (!silent) showToast('저장 실패', 'error'); }
}

function initDemoData() {
    if (AppState.assignments.length === 0) {
        AppState.assignments = [
            {id:'A-101',title:'변수 기초',due:'2025-10-20',status:'진행중',submissions:15,total:20},
            {id:'A-102',title:'조건문 챌린지',due:'2025-10-27',status:'예정',submissions:0,total:20},
            {id:'A-103',title:'반복문 퍼즐',due:'2025-11-03',status:'예정',submissions:0,total:20}
        ];
    }
    if (AppState.students.length === 0) {
        AppState.students = [
            {id:1,name:'강지민',role:'학생',clazz:'1반',progress:85,score:92},
            {id:2,name:'최도윤',role:'학생',clazz:'2반',progress:78,score:88},
            {id:3,name:'박서연',role:'학생',clazz:'1반',progress:92,score:95},
            {id:4,name:'한서우',role:'교사',clazz:'—',progress:100,score:100}
        ];
    }
    if (AppState.runHistory.length === 0) {
        AppState.runHistory = [
            {timestamp:'2025-10-13 09:20',score:68,summary:'조건문으로 기본 구조 점검',coverage:52,warnings:0}
        ];
    }
    if (!AppState.latestTests || AppState.latestTests.length === 0) {
        AppState.latestTests = [
            {name:'기본 로직 검증',passed:true},
            {name:'최적화 규칙',passed:false},
            {name:'안정성 점검',passed:true}
        ];
    }
}

// ==================== UI UTILITIES ====================
function showToast(msg, type) {
    var toast = document.getElementById('toast');
    toast.textContent = msg;
    toast.className = 'toast show ' + (type || '');
    setTimeout(function() { toast.classList.remove('show'); }, 3000);
}

function showModal(content) {
    var modal = document.getElementById('modal');
    document.getElementById('modalContent').innerHTML = content;
    modal.classList.add('show');
    lucide.createIcons();
}

function closeModal() {
    document.getElementById('modal').classList.remove('show');
}

function createCard(title, icon, content, className) {
    return '<div class="card card-hover '+(className||'')+'"><div class="card-body">'+
           '<div class="section-title"><i data-lucide="'+icon+'" class="h-5 w-5"></i><h3>'+title+'</h3></div>'+
           content+'</div></div>';
}

function destroyCharts() {
    for (var k in AppState.charts) {
        if (AppState.charts[k] && AppState.charts[k].destroy) AppState.charts[k].destroy();
    }
    AppState.charts = {};
}

function formatTimestamp(value) {
    var date = value instanceof Date ? value : new Date(value);
    if (isNaN(date.getTime())) return '—';
    var y = date.getFullYear();
    var m = String(date.getMonth() + 1).padStart(2, '0');
    var d = String(date.getDate()).padStart(2, '0');
    var hh = String(date.getHours()).padStart(2, '0');
    var mm = String(date.getMinutes()).padStart(2, '0');
    return y + '-' + m + '-' + d + ' ' + hh + ':' + mm;
}

function escapeHtml(value) {
    if (value === null || value === undefined) return '';
    return String(value).replace(/[&<>"']/g, function(ch) {
        switch (ch) {
            case '&': return '&amp;';
            case '<': return '&lt;';
            case '>': return '&gt;';
            case '"': return '&quot;';
            case "'": return '&#39;';
            default: return ch;
        }
    });
}

function getOrderedBlocks() {
    if (!AppState.workspaceBlocks || AppState.workspaceBlocks.length === 0) return [];
    return AppState.workspaceBlocks.slice().sort(function(a, b) {
        var ay = typeof a.y === 'number' ? a.y : 0;
        var by = typeof b.y === 'number' ? b.y : 0;
        if (ay === by) {
            var ax = typeof a.x === 'number' ? a.x : 0;
            var bx = typeof b.x === 'number' ? b.x : 0;
            return ax - bx;
        }
        return ay - by;
    });
}

function analyzeWorkspace() {
    var counts = {};
    var blocks = AppState.workspaceBlocks || [];
    blocks.forEach(function(block) {
        counts[block.type] = (counts[block.type] || 0) + 1;
    });

    var suggestions = [];
    var warnings = [];

    if (!counts['repeat']) suggestions.push('반복되는 명령은 반복문으로 묶어 코드 길이를 줄여보세요.');
    if (!counts['if']) suggestions.push('조건문을 활용하면 입력에 따른 분기 처리가 가능해요.');
    if ((counts['repeat'] || 0) > 2) warnings.push('반복문이 많아요. 종료 조건을 명확히 해주세요.');
    if ((counts['if'] || 0) > 3) warnings.push('조건문 중첩이 많아 가독성이 떨어질 수 있어요.');
    if ((counts['print'] || 0) > 3) warnings.push('출력 블록이 많아 결과 로그가 길어질 수 있어요.');
    if (counts['random']) warnings.push('난수 블록이 있어 실행 결과가 매번 달라질 수 있어요.');

    if (blocks.length >= 8 && !counts['set-var']) {
        suggestions.push('변수를 선언해 중복 값을 저장하면 유지보수가 쉬워져요.');
    }

    var uniqueCount = Object.keys(counts).length;
    var complexity = (counts['repeat'] || 0) * 3 + (counts['if'] || 0) * 2 + (counts['change-var'] || 0) + (counts['set-var'] || 0);
    var coverage = Math.min(100, uniqueCount * 18 + (counts['repeat'] ? 12 : 0) + (counts['if'] ? 10 : 0));
    var score = 58 + (counts['repeat'] ? counts['repeat'] * 6 : 0) + (counts['if'] ? counts['if'] * 5 : 0) + (counts['set-var'] ? 4 : 0) - warnings.length * 5;
    score = Math.max(45, Math.min(100, score));

    if (suggestions.length === 0) {
        suggestions.push('세부 동작을 함수로 분리하면 재사용과 테스트가 쉬워져요.');
    }

    var summary = '반복 블록 ' + (counts['repeat'] || 0) + '개와 조건 블록 ' + (counts['if'] || 0) + '개를 활용해 ' + (AppState.blockCount || 0) + '단계를 구성했어요.';
    if (counts['print']) summary += ' 출력 블록이 ' + counts['print'] + '개 포함되어 실행 결과를 바로 확인할 수 있어요.';
    if (counts['set-var']) summary += ' 변수 블록을 사용해 상태를 관리하고 있어요.';

    var expectedOutput = counts['random'] ? '난수 기반 결과' : (counts['print'] ? '콘솔 메시지' : '시뮬레이션 액션');
    var alertLevel = warnings.length > 0 ? '주의' : (score >= 75 ? '안정' : '점검');

    return {
        counts: counts,
        suggestions: suggestions,
        warnings: warnings,
        summary: summary,
        score: score,
        complexity: complexity,
        coverage: coverage,
        expectedOutput: expectedOutput,
        alertLevel: alertLevel,
        recommendedFocus: counts['repeat'] ? '조건 최적화' : '반복 패턴 설계'
    };
}

function convertBlocksToCode(lang) {
    var ordered = getOrderedBlocks();
    var indent = lang === 'python' ? '    ' : '  ';
    if (ordered.length === 0) {
        return lang === 'python' ? '# 블록을 배치하면 Python 코드가 생성됩니다.' : '// 블록을 배치하면 JavaScript 코드가 생성됩니다.';
    }

    var lines = [];
    ordered.forEach(function(block) {
        if (lang === 'python') {
            switch(block.type) {
                case 'start':
                    lines.push('# ▶ 시작하기 이벤트');
                    break;
                case 'repeat-start':
                    lines.push('while True:');
                    lines.push(indent + '# TODO: 반복 실행할 동작');
                    break;
                case 'repeat':
                    lines.push('for i in range(10):');
                    lines.push(indent + '# TODO: 반복 본문 구현');
                    break;
                case 'if':
                    lines.push('if condition:');
                    lines.push(indent + '# TODO: 조건이 참일 때 실행');
                    break;
                case 'wait':
                    lines.push('time.sleep(1)  # 1초 대기');
                    break;
                case 'add':
                    lines.push('result = value_a + value_b');
                    break;
                case 'compare':
                    lines.push('is_equal = left == right');
                    break;
                case 'random':
                    lines.push('value = random.randint(1, 10)');
                    break;
                case 'set-var':
                    lines.push('variable = 0');
                    break;
                case 'change-var':
                    lines.push('variable += 1');
                    break;
                case 'print':
                    lines.push('print("안녕!")');
                    break;
                case 'console':
                    lines.push('print(value)');
                    break;
                default:
                    lines.push('# ' + block.type + ' 블록 처리');
            }
        } else {
            switch(block.type) {
                case 'start':
                    lines.push('// ▶ 시작하기 이벤트');
                    break;
                case 'repeat-start':
                    lines.push('while (true) {');
                    lines.push(indent + '// TODO: 반복 실행할 동작');
                    lines.push('}');
                    break;
                case 'repeat':
                    lines.push('for (let i = 0; i < 10; i++) {');
                    lines.push(indent + '// TODO: 반복 본문 구현');
                    lines.push('}');
                    break;
                case 'if':
                    lines.push('if (condition) {');
                    lines.push(indent + '// TODO: 조건이 참일 때 실행');
                    lines.push('}');
                    break;
                case 'wait':
                    lines.push('await wait(1000);');
                    break;
                case 'add':
                    lines.push('const result = valueA + valueB;');
                    break;
                case 'compare':
                    lines.push('const isEqual = left === right;');
                    break;
                case 'random':
                    lines.push('const value = Math.floor(Math.random() * 10) + 1;');
                    break;
                case 'set-var':
                    lines.push('let variable = 0;');
                    break;
                case 'change-var':
                    lines.push('variable += 1;');
                    break;
                case 'print':
                    lines.push('console.log("안녕!");');
                    break;
                case 'console':
                    lines.push('console.log(value);');
                    break;
                default:
                    lines.push('// ' + block.type + ' 블록 처리');
            }
        }
    });

    return lines.join('\n');
}

function getGeneratedCode(lang) {
    var defaults = {
        python: 'total = 0\nfor i in range(1, 11):\n    if i % 2 == 0:\n        total += i\nprint(total)',
        javascript: 'let total = 0;\nfor (let i = 1; i <= 10; i++) {\n  if (i % 2 === 0) {\n    total += i;\n  }\n}\nconsole.log(total);'
    };
    if (!AppState.generatedCode) {
        return lang === 'python' ? defaults.python : defaults.javascript;
    }
    var key = lang === 'python' ? 'python' : 'javascript';
    var code = AppState.generatedCode[key];
    if (!code || !code.trim()) {
        return defaults[key];
    }
    return code;
}

function refreshPuzzleWidgets() {
    var runOutputEl = document.getElementById('runOutput');
    if (runOutputEl) {
        var outputText = AppState.runResult ? escapeHtml(AppState.runResult).replace(/\n/g, '<br>') : '[대기 중]';
        runOutputEl.innerHTML = outputText;
    }

    var testsEl = document.getElementById('testResults');
    if (testsEl) {
        var testsHtml = (AppState.latestTests || []).map(function(test) {
            return '<div class="flex items-center justify-between rounded-lg bg-gray-50 p-2 text-xs">'+
                   '<span class="font-medium">'+escapeHtml(test.name)+'</span>'+
                   '<span class="'+(test.passed?'text-green-600':'text-red-600')+'">'+(test.passed?'통과':'실패')+'</span>'+
                   '</div>';
        }).join('');
        testsEl.innerHTML = testsHtml || '<div class="text-xs text-gray-500">테스트 결과가 없습니다.</div>';
    }

    if (AppState.aiInsights) {
        var ai = AppState.aiInsights;
        var summaryEl = document.getElementById('aiSummary');
        if (summaryEl) summaryEl.textContent = ai.summary || '실행을 진행하면 AI가 피드백을 제공합니다.';
        var scoreEl = document.getElementById('aiMetricScore');
        if (scoreEl) scoreEl.textContent = ai.score !== null ? ai.score : '—';
        var coverageEl = document.getElementById('aiMetricCoverage');
        if (coverageEl) coverageEl.textContent = (ai.coverage || 0) + '%';
        var complexityEl = document.getElementById('aiMetricComplexity');
        if (complexityEl) complexityEl.textContent = ai.complexity || 0;
        var expectedEl = document.getElementById('aiExpectedOutput');
        if (expectedEl) expectedEl.textContent = ai.expectedOutput || '—';
        var focusEl = document.getElementById('aiFocus');
        if (focusEl) {
            if (ai.recommendedFocus) {
                focusEl.style.display = '';
                focusEl.textContent = '다음 집중 주제: ' + ai.recommendedFocus;
            } else {
                focusEl.style.display = 'none';
            }
        }
        var suggestionsEl = document.getElementById('aiSuggestions');
        if (suggestionsEl) {
            var suggestionHtml = (ai.suggestions || []).map(function(text, idx) {
                return '<li class="flex items-start gap-2 text-sm"><span class="badge badge-primary">'+(idx+1)+'</span><span>'+escapeHtml(text)+'</span></li>';
            }).join('');
            suggestionsEl.innerHTML = suggestionHtml || '<li class="text-sm text-gray-500">실행 후 추천이 제공됩니다.</li>';
        }
        var warningsEl = document.getElementById('aiWarnings');
        if (warningsEl) {
            var warningHtml = (ai.warnings || []).map(function(text) {
                return '<li class="flex items-start gap-2 text-xs text-red-600"><i data-lucide="shield-alert" class="h-3 w-3 mt-0.5"></i><span>'+escapeHtml(text)+'</span></li>';
            }).join('');
            warningsEl.innerHTML = warningHtml || '<li class="text-xs text-gray-500">위험 요소 없음</li>';
        }
    }

    var pythonPreview = document.getElementById('pythonPreview');
    if (pythonPreview) pythonPreview.textContent = getGeneratedCode('python');
    var javascriptPreview = document.getElementById('javascriptPreview');
    if (javascriptPreview) javascriptPreview.textContent = getGeneratedCode('javascript');

    var timestampPython = document.getElementById('codeTimestampPython');
    var timestampJS = document.getElementById('codeTimestampJS');
    if (timestampPython) timestampPython.textContent = AppState.lastRunLabel || '최근 실행 없음';
    if (timestampJS) timestampJS.textContent = AppState.lastRunLabel || '최근 실행 없음';

    var historyEl = document.getElementById('runHistoryList');
    if (historyEl) {
        var historyHtml = AppState.runHistory.map(function(item) {
            return '<div class="flex items-start justify-between gap-3 rounded-lg border border-gray-100 bg-white p-2 text-xs">'+
                   '<div>'+ 
                   '<div class="font-semibold text-gray-700">'+item.score+'점 · 커버리지 '+(item.coverage||0)+'%</div>'+ 
                   '<div class="text-gray-500">'+escapeHtml(item.summary)+'</div>'+ 
                   '<div class="text-gray-400">경고 '+(item.warnings||0)+'건</div>'+ 
                   '</div>'+ 
                   '<div class="text-gray-400 whitespace-nowrap">'+escapeHtml(item.timestamp)+'</div>'+ 
                   '</div>';
        }).join('');
        historyHtml = historyHtml || '<div class="text-xs text-gray-500">실행 버튼을 눌러 히스토리를 쌓아보세요.</div>';
        historyEl.innerHTML = historyHtml;
    }

    lucide.createIcons();
}

// ==================== NAVIGATION ====================
function renderNav() {
    var nav = document.getElementById('navMenu');
    var items = NavItems[AppState.role];
    var html = '';
    for (var i = 0; i < items.length; i++) {
        var it = items[i];
        var active = AppState.page === it.key ? 'active' : '';
        html += '<button onclick="changePage(\''+it.key+'\')" '+
                'class="nav-item '+active+' flex w-full items-center gap-3 rounded-xl px-3 py-2 text-left text-sm">'+
                '<i data-lucide="'+it.icon+'" class="h-4 w-4"></i>'+it.label+'</button>';
    }
    nav.innerHTML = html;
    lucide.createIcons();
}

function changeRole(newRole) {
    AppState.role = newRole;
    var btns = document.querySelectorAll('.role-btn');
    for (var i = 0; i < btns.length; i++) {
        if (btns[i].dataset.role === newRole) btns[i].classList.add('active');
        else btns[i].classList.remove('active');
    }
    if (newRole === 'student') AppState.page = 's.dashboard';
    else if (newRole === 'teacher') AppState.page = 't.classes';
    else AppState.page = 'a.monitor';
    renderNav();
    renderContent();
    showToast('역할: ' + newRole, 'success');
}

function changePage(newPage) {
    AppState.page = newPage;
    renderNav();
    renderContent();
}

// ==================== CONTENT RENDERING ====================
function renderContent() {
    destroyCharts();
    var content = document.getElementById('contentArea');
    content.className = 'fade-in';
    var html = '';
    
    switch(AppState.page) {
        case 's.dashboard': html = renderStudentDashboard(); break;
        case 's.puzzle': html = renderStudentPuzzle(); break;
        case 's.compare': html = renderStudentCompare(); break;
        case 's.results': html = renderStudentResults(); break;
        case 't.classes': html = renderTeacherClasses(); break;
        case 't.assign': html = renderTeacherAssignments(); break;
        case 't.reports': html = renderTeacherReports(); break;
        case 'a.users': html = renderAdminUsers(); break;
        case 'a.monitor': html = renderAdminMonitor(); break;
        case 'a.settings': html = renderAdminSettings(); break;
        default: html = '<div class="text-sm text-gray-500">페이지를 찾을 수 없습니다</div>';
    }
    
    content.innerHTML = html;
    lucide.createIcons();
    
    setTimeout(function() {
        if (AppState.page === 's.dashboard') initStudentDashboardCharts();
        else if (AppState.page === 's.puzzle') { initBlockly(); refreshPuzzleWidgets(); }
        else if (AppState.page === 's.results') initResultsCharts();
        else if (AppState.page === 't.classes') initClassCharts();
        else if (AppState.page === 't.reports') initReportsCharts();
        else if (AppState.page === 'a.monitor') initMonitorCharts();
    }, 100);
}

// ==================== STUDENT PAGES ====================
function renderStudentDashboard() {
    var badges = '';
    for (var i = 0; i < MockData.badges.length; i++) {
        var b = MockData.badges[i];
        var cls = b.earned ? 'bg-yellow-50 border-yellow-300' : 'bg-gray-50 opacity-50';
        badges += '<div class="flex flex-col items-start rounded-xl border p-3 '+cls+'">'+
                 '<div class="flex items-center gap-2 font-semibold text-sm">'+
                 '<i data-lucide="award" class="h-4 w-4"></i>'+b.name+'</div>'+
                 '<div class="text-xs text-gray-500 mt-1">'+b.desc+'</div>'+
                 (b.earned ? '<div class="mt-2 badge badge-success">획득!</div>' : '')+'</div>';
    }

    var insights = AppState.aiInsights || {
        summary: '실행을 진행하면 AI가 코드 패턴을 분석해드립니다.',
        suggestions: ['블록을 배치하고 실행해보세요.'],
        warnings: [],
        score: null,
        coverage: 0,
        complexity: 0,
        alertLevel: '대기'
    };
    var suggestionChips = insights.suggestions.map(function(text) {
        return '<span class="tag">'+escapeHtml(text)+'</span>';
    }).join('');
    if (!suggestionChips) suggestionChips = '<div class="text-xs text-gray-500">추천이 곧 제공됩니다.</div>';

    var warningList = insights.warnings && insights.warnings.length
        ? '<ul class="list-disc pl-5 text-xs text-red-600 space-y-1">'+insights.warnings.map(function(w) { return '<li>'+escapeHtml(w)+'</li>'; }).join('')+'</ul>'
        : '<div class="text-xs text-gray-500">경고 없음 — 좋은 상태입니다.</div>';

    var latestHistory = AppState.runHistory.slice(0, 3).map(function(item) {
        return '<div class="flex items-start justify-between gap-3 rounded-lg bg-gray-50 p-2 text-xs">'+
               '<div><div class="font-semibold text-gray-700">'+item.score+'점 · 커버리지 '+item.coverage+'%</div>'+
               '<div class="text-gray-500">'+escapeHtml(item.summary)+'</div></div>'+
               '<div class="text-gray-400 whitespace-nowrap">'+escapeHtml(item.timestamp)+'</div></div>';
    }).join('');
    if (!latestHistory) {
        latestHistory = '<div class="text-xs text-gray-500">아직 실행 이력이 없습니다. 첫 실행을 시도해보세요.</div>';
    }

    var rhythmHtml = MockData.learningRhythm.map(function(day) {
        return '<div class="flex items-center justify-between rounded-xl border p-2 text-sm">'+
               '<div class="flex items-center gap-3">'+
               '<span class="font-semibold">'+day.day+'</span>'+day.mood+
               '</div>'+
               '<div class="text-right">'+
               '<div class="text-gray-700">'+day.focus+'</div>'+
               '<div class="text-xs text-gray-500">집중 시간 '+day.minutes+'분</div>'+
               '</div></div>';
    }).join('');

    return '<div class="grid grid-cols-1 gap-4 lg:grid-cols-3">'+
           createCard('주차별 진도율', 'book-open',
               '<div class="chart-container"><canvas id="progressChart"></canvas></div>'+
               '<div class="mt-3"><button onclick="resetProgress()" class="btn btn-secondary btn-sm">진도 초기화</button></div>',
               'lg:col-span-2')+
           createCard('획득한 뱃지', 'award', '<div class="flex flex-wrap gap-2">'+badges+'</div>')+
           createCard('최적화 시도 기록', 'activity',
               '<div class="chart-container"><canvas id="optimizationChart"></canvas></div>'+
               '<div class="mt-3 text-xs text-gray-500">목표: 25 이하</div>'+
               '<button onclick="addOptimizationRun()" class="btn btn-primary btn-sm mt-2">새 시도 추가</button>',
               'lg:col-span-3')+
           createCard('AI 학습 요약', 'brain',
               '<div class="space-y-3 text-sm">'+
               '<div class="text-gray-600">'+escapeHtml(insights.summary||'실행을 진행하면 AI가 코드 패턴을 분석해드립니다.')+'</div>'+
               '<div class="grid grid-cols-2 md:grid-cols-4 gap-2 text-center text-xs">'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">품질 점수</div><div class="text-lg font-semibold text-gray-800">'+(insights.score!==null?insights.score:'—')+'</div></div>'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">커버리지</div><div class="text-lg font-semibold text-gray-800">'+(insights.coverage||0)+'%</div></div>'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">복잡도</div><div class="text-lg font-semibold text-gray-800">'+insights.complexity+'</div></div>'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">상태</div><div class="text-lg font-semibold text-gray-800">'+(insights.alertLevel||'대기')+'</div></div>'+
               '</div>'+
               '<div><div class="mb-1 text-xs font-medium text-gray-500 uppercase">추천</div><div class="flex flex-wrap gap-2">'+suggestionChips+'</div></div>'+
               '<div><div class="mb-1 text-xs font-medium text-gray-500 uppercase">주의</div>'+warningList+'</div>'+
               '<div><div class="mb-1 text-xs font-medium text-gray-500 uppercase">최근 실행</div><div class="space-y-2">'+latestHistory+'</div></div>'+
               '</div>',
               'lg:col-span-3')+
           createCard('나의 학습 리듬', 'calendar',
               '<div class="space-y-2">'+rhythmHtml+'</div>'+(
                   AppState.lastRunLabel ? '<div class="mt-3 text-xs text-gray-500">최근 실행: '+AppState.lastRunLabel+'</div>' : ''
               ),
               'lg:col-span-3')+
           '</div>';
}

function renderStudentPuzzle() {
    var insights = AppState.aiInsights || {
        summary: '블록을 배치한 뒤 실행하면 AI가 피드백을 제공합니다.',
        suggestions: ['실행 버튼을 눌러 피드백을 확인하세요.'],
        warnings: [],
        score: null,
        coverage: 0,
        complexity: 0,
        expectedOutput: '—',
        recommendedFocus: '기본 구조'
    };

    var summaryText = escapeHtml(insights.summary || '실행 대기 중입니다.');
    var suggestionList = (insights.suggestions || []).map(function(text, index) {
        return '<li class="flex items-start gap-2"><span class="badge badge-primary">'+(index+1)+'</span><span>'+escapeHtml(text)+'</span></li>';
    }).join('');
    if (!suggestionList) suggestionList = '<li class="text-xs text-gray-500">실행 후 추천이 제공됩니다.</li>';

    var warningList = (insights.warnings || []).map(function(text) {
        return '<li class="flex items-start gap-2 text-xs text-red-600"><i data-lucide="alert-triangle" class="h-3 w-3 mt-0.5"></i><span>'+escapeHtml(text)+'</span></li>';
    }).join('');
    if (!warningList) warningList = '<li class="text-xs text-gray-500">위험 요소 없음</li>';

    var metricsHtml = '<div class="grid grid-cols-2 gap-2 text-xs">'+
        '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">품질 점수</div><div class="text-lg font-semibold text-gray-800" id="aiMetricScore">'+(insights.score!==null?insights.score:'—')+'</div></div>'+ 
        '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">커버리지</div><div class="text-lg font-semibold text-gray-800" id="aiMetricCoverage">'+(insights.coverage||0)+'%</div></div>'+ 
        '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">복잡도</div><div class="text-lg font-semibold text-gray-800" id="aiMetricComplexity">'+(insights.complexity||0)+'</div></div>'+ 
        '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">예상 출력</div><div class="text-sm font-semibold text-gray-800" id="aiExpectedOutput">'+escapeHtml(insights.expectedOutput||'—')+'</div></div>'+ 
    '</div>';

    var focusHtml = insights.recommendedFocus ? '<div class="rounded-lg bg-indigo-50 p-3 text-xs text-indigo-700" id="aiFocus">다음 집중 주제: '+escapeHtml(insights.recommendedFocus)+'</div>' : '<div class="rounded-lg bg-indigo-50 p-3 text-xs text-indigo-700" id="aiFocus" style="display:none"></div>';

    var historyList = AppState.runHistory.slice(0, 5).map(function(item) {
        return '<div class="flex items-start justify-between gap-3 rounded-lg border border-gray-100 bg-white p-2 text-xs">'+
               '<div>'+ 
               '<div class="font-semibold text-gray-700">'+item.score+'점 · 커버리지 '+(item.coverage||0)+'%</div>'+ 
               '<div class="text-gray-500">'+escapeHtml(item.summary)+'</div>'+ 
               '<div class="text-gray-400">경고 '+(item.warnings||0)+'건</div>'+ 
               '</div>'+ 
               '<div class="text-gray-400 whitespace-nowrap">'+escapeHtml(item.timestamp)+'</div>'+ 
               '</div>';
    }).join('');
    if (!historyList) historyList = '<div class="text-xs text-gray-500">실행 버튼을 눌러 히스토리를 쌓아보세요.</div>';

    var pythonCode = escapeHtml(getGeneratedCode('python'));
    var jsCode = escapeHtml(getGeneratedCode('javascript'));
    var testResults = (AppState.latestTests || []).map(function(test) {
        return '<div class="flex items-center justify-between rounded-lg bg-gray-50 p-2 text-xs">'+
               '<span class="font-medium">'+escapeHtml(test.name)+'</span>'+
               '<span class="'+(test.passed?'text-green-600':'text-red-600')+'">'+(test.passed?'통과':'실패')+'</span>'+
               '</div>';
    }).join('');
    if (!testResults) testResults = '<div class="text-xs text-gray-500">테스트 결과가 없습니다.</div>';
    var runOutput = AppState.runResult ? escapeHtml(AppState.runResult).replace(/\n/g, '<br>') : '[대기 중]';

    return '<div class="flex flex-col gap-4 xl:flex-row">'+
           '<aside class="w-full xl:w-80 puzzle-sidebar">'+
           '<div class="card entry-palette-card"><div class="card-body" style="max-height:calc(100vh-12rem);overflow-y:auto;">'+
           '<div class="entry-palette-header">'+
           '<div class="flex items-center gap-2">'+
           '<i data-lucide="puzzle" class="h-5 w-5"></i>'+
           '<h3>블록 팔레트</h3>'+
           '</div>'+
           '<span class="text-xs font-semibold uppercase tracking-wide text-white/70">Entry Style</span>'+
           '</div>'+
           '<input id="blockSearch" placeholder="블록 검색" class="entry-search" onkeyup="searchBlocks()">'+
           '<div id="blockPalette" class="block-palette">'+
           '<div class="block-palette-category">'+
           '<div class="block-palette-title">🎬 시작</div>'+
           '<div class="block-stack">'+
           '<div class="block-item block-category-start" draggable="true" ondragstart="dragStart(event)" data-block="start">'+
           '▶ 시작하기 버튼을 클릭했을 때'+
           '</div>'+
           '<div class="block-item block-category-start" draggable="true" ondragstart="dragStart(event)" data-block="repeat-start">'+
           '▶ 무한 반복하기'+
           '</div>'+
           '</div>'+
           '</div>'+
           '<div class="block-palette-category">'+
           '<div class="block-palette-title">🔄 흐름</div>'+
           '<div class="block-stack">'+
           '<div class="block-item block-category-flow" draggable="true" ondragstart="dragStart(event)" data-block="repeat">'+
           '<span class="block-input">10</span> 번 반복하기'+
           '</div>'+
           '<div class="block-item block-category-flow" draggable="true" ondragstart="dragStart(event)" data-block="if">'+
           '만약 <span class="block-input">조건</span> 이라면'+
           '</div>'+
           '<div class="block-item block-category-flow" draggable="true" ondragstart="dragStart(event)" data-block="wait">'+
           '<span class="block-input">1</span> 초 기다리기'+
           '</div>'+
           '</div>'+
           '<div class="block-palette-category">'+
           '<div class="block-palette-title">📐 계산</div>'+
           '<div class="block-stack">'+
           '<div class="block-item block-category-calc" draggable="true" ondragstart="dragStart(event)" data-block="add">'+
           '<span class="block-input">0</span> + <span class="block-input">0</span>'+
           '</div>'+
           '<div class="block-item block-category-calc" draggable="true" ondragstart="dragStart(event)" data-block="compare">'+
           '<span class="block-input">0</span> = <span class="block-input">0</span>'+
           '</div>'+
           '<div class="block-item block-category-calc" draggable="true" ondragstart="dragStart(event)" data-block="random">'+
           '<span class="block-input">1</span> 부터 <span class="block-input">10</span> 사이의 난수'+
           '</div>'+
           '</div>'+
           '<div class="block-palette-category">'+
           '<div class="block-palette-title">📦 변수</div>'+
           '<div class="block-stack">'+
           '<div class="block-item block-category-var" draggable="true" ondragstart="dragStart(event)" data-block="set-var">'+
           '변수 <span class="block-input">이름</span> 을 <span class="block-input">0</span> (으)로 정하기'+
           '</div>'+
           '<div class="block-item block-category-var" draggable="true" ondragstart="dragStart(event)" data-block="change-var">'+
           '변수 <span class="block-input">이름</span> 을 <span class="block-input">1</span> 만큼 바꾸기'+
           '</div>'+
           '</div>'+
           '<div class="block-palette-category">'+
           '<div class="block-palette-title">📺 보이기</div>'+
           '<div class="block-stack">'+
           '<div class="block-item block-category-looks" draggable="true" ondragstart="dragStart(event)" data-block="print">'+
           '<span class="block-input">안녕!</span> 출력하기'+
           '</div>'+
           '<div class="block-item block-category-looks" draggable="true" ondragstart="dragStart(event)" data-block="console">'+
           '콘솔에 <span class="block-input">값</span> 출력하기'+
           '</div>'+
           '</div>'+
           '</div>'+
           '<div class="mt-4 rounded-xl bg-white/15 p-4 text-xs font-medium text-white/80 shadow-inner">'+
           '💡 블록을 드래그하여 작업 공간에 배치하세요'+
           '</div>'+
           '</div></div>'+
           '</aside>'+
           '<div class="flex-1">'+
           '<div class="grid grid-cols-1 gap-4 xl:grid-cols-2 2xl:grid-cols-3 items-start">'+
           '<div class="space-y-4 2xl:col-span-2">'+
           '<div class="card"><div class="card-body">'+
           '<div class="mb-4 flex flex-wrap items-center justify-between gap-3">'+
           '<div class="flex items-center gap-2 text-gray-700">'+
           '<i data-lucide="layers" class="h-5 w-5"></i>'+
           '<h3 class="text-lg font-semibold">작업 공간</h3>'+
           '</div>'+
           '<div class="workspace-toolbar">'+
           '<span class="tag">목표: 25단계 이하</span>'+
           '<button onclick="toggleOptMode()" class="btn btn-secondary">'+
           '<i data-lucide="rocket" class="h-4 w-4"></i>최적화 '+(AppState.optMode?'ON':'OFF')+
           '</button>'+
           '<button onclick="clearWorkspace()" class="btn btn-ghost">'+
           '<i data-lucide="trash-2" class="h-4 w-4"></i>초기화</button>'+
           '<button onclick="runCode()" class="btn btn-primary">'+
           '<i data-lucide="play" class="h-4 w-4"></i>실행</button>'+
           '</div></div>'+
           '<div id="blockWorkspace" class="workspace-area workspace-grid" style="height:24rem;" ondrop="drop(event)" ondragover="allowDrop(event)" ondragenter="workspaceDragEnter(event)" ondragleave="workspaceDragLeave(event)">'+
           '<div class="workspace-overlay"></div>'+
           '<div id="workspaceHint" class="workspace-empty-hint hidden">'+
           '<div class="text-3xl">🎯</div>'+
           '<div class="text-sm">사이드 팔레트에서 블록을 드래그하세요</div>'+
           '</div>'+
           '</div>'+
           '<div class="mt-3 flex items-center justify-between text-xs">'+
           '<div class="text-gray-500">💡 힌트: 반복문으로 코드를 줄여보세요</div>'+
           '<div class="font-semibold text-gray-700">실행 단계: <span id="stepCount">'+AppState.blockCount+'</span></div>'+
           '</div>'+
           '</div></div>'+
           '</div>'+
           '<div class="space-y-4">'+
           createCard('시뮬레이션','activity',
               '<div class="flex items-center justify-center rounded-xl border p-4" style="min-height:16rem;">'+
               '<div class="text-center w-full">'+
               '<div class="text-sm text-gray-500 mb-2">실행 결과</div>'+
               '<div class="output-console" id="runOutput">'+runOutput+'</div>'+
               '<div class="mt-3 space-y-2" id="testResults">'+testResults+'</div>'+
               '<div class="mt-3 text-xs text-gray-500">예상 출력: '+escapeHtml(insights.expectedOutput||'—')+'</div>'+
               '</div></div>')+
           createCard('AI 피드백','sparkles',
               '<div class="space-y-3 text-sm">'+
               '<div class="text-gray-600" id="aiSummary">'+summaryText+'</div>'+metricsHtml+focusHtml+
               '<div><div class="mb-1 text-xs font-medium text-gray-500 uppercase">추천</div><ul class="space-y-2" id="aiSuggestions">'+suggestionList+'</ul></div>'+
               '<div><div class="mb-1 text-xs font-medium text-gray-500 uppercase">주의</div><ul class="space-y-2" id="aiWarnings">'+warningList+'</ul></div>'+
               '<button onclick="getAIHint()" class="btn btn-secondary w-full">'+
               '<i data-lucide="lightbulb" class="h-4 w-4"></i>새 힌트 받기</button>'+
               '</div>')+
           createCard('코드 미리보기','code-2',
               '<div class="space-y-4 text-xs">'+
               '<div><div class="mb-2 flex items-center justify-between text-gray-500 uppercase">Python<span id="codeTimestampPython">'+escapeHtml(AppState.lastRunLabel||'최근 실행 없음')+'</span></div>'+
               '<pre class="code-block" style="max-height:16rem;" id="pythonPreview">'+pythonCode+'</pre>'+ 
               '<div class="mt-2 flex gap-2">'+
               '<button onclick="copyCode(\'python\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="copy" class="h-4 w-4"></i>복사</button>'+ 
               '<button onclick="downloadCode(\'python\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="download" class="h-4 w-4"></i>다운로드</button></div></div>'+ 
               '<div><div class="mb-2 flex items-center justify-between text-gray-500 uppercase">JavaScript<span id="codeTimestampJS">'+escapeHtml(AppState.lastRunLabel||'최근 실행 없음')+'</span></div>'+
               '<pre class="code-block" style="max-height:16rem;" id="javascriptPreview">'+jsCode+'</pre>'+ 
               '<div class="mt-2 flex gap-2">'+
               '<button onclick="copyCode(\'javascript\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="copy" class="h-4 w-4"></i>복사</button>'+ 
               '<button onclick="downloadCode(\'javascript\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="download" class="h-4 w-4"></i>다운로드</button></div></div>'+ 
               '</div>')+
           createCard('실행 히스토리','clock',
               '<div class="space-y-2" id="runHistoryList">'+historyList+'</div>')+
           '</div>'+
           '</div>'+
           '</div>'+
           '</div>';
}

function renderStudentCompare() {
    var pythonCode = escapeHtml(getGeneratedCode('python'));
    var javascriptCode = escapeHtml(getGeneratedCode('javascript'));
    var insights = AppState.aiInsights || {
        score: null,
        coverage: 0,
        complexity: 0,
        summary: '실행을 진행하면 비교 모드에서 AI 분석이 표시됩니다.',
        suggestions: ['블록을 실행하여 데이터를 수집해보세요.'],
        warnings: [],
        alertLevel: '대기',
        expectedOutput: '—'
    };

    var suggestionList = (insights.suggestions || []).map(function(text, index) {
        return '<li class="flex items-start gap-2 text-sm"><span class="badge badge-primary">'+(index+1)+'</span><span>'+escapeHtml(text)+'</span></li>';
    }).join('');
    if (!suggestionList) suggestionList = '<li class="text-xs text-gray-500">실행 후 추천이 제공됩니다.</li>';

    var warningList = (insights.warnings || []).map(function(text) {
        return '<li class="flex items-start gap-2 text-xs text-red-600"><i data-lucide="shield-alert" class="h-3 w-3 mt-0.5"></i><span>'+escapeHtml(text)+'</span></li>';
    }).join('');
    if (!warningList) warningList = '<li class="text-xs text-gray-500">위험 요소 없음</li>';

    var testsData = [
        {name:'기본 로직', passed:(insights.score||0) >= 60},
        {name:'최적화 기준', passed:(insights.coverage||0) >= 55},
        {name:'안정성 체크', passed: (insights.warnings||[]).length === 0}
    ];
    var tests = testsData.map(function(test, idx) {
        return '<div class="rounded-xl border p-3 text-sm bg-gray-50">'+
               '<div class="flex items-center justify-between mb-2">'+
               '<span class="font-medium">테스트 #'+(idx+1)+' · '+test.name+'</span>'+
               '<span class="badge '+(test.passed?'badge-success">통과':'badge-danger">점검 필요')+'</span>'+
               '</div>'+
               '<div class="text-xs text-gray-500">예상 출력: '+escapeHtml(insights.expectedOutput||'—')+'</div>'+
               '</div>';
    }).join('');

    return '<div class="grid grid-cols-1 gap-4 xl:grid-cols-2">'+
           createCard('Python','code-2',
               '<pre class="code-block" style="max-height:24rem;">'+pythonCode+'</pre>'+
               '<div class="mt-3 flex gap-2">'+
               '<button onclick="copyCode(\'python\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="copy" class="h-4 w-4"></i>복사</button>'+
               '<button onclick="downloadCode(\'python\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="download" class="h-4 w-4"></i>다운로드</button>'+
               '</div>')+
           createCard('JavaScript','code-2',
               '<pre class="code-block" style="max-height:24rem;">'+javascriptCode+'</pre>'+
               '<div class="mt-3 flex gap-2">'+
               '<button onclick="copyCode(\'javascript\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="copy" class="h-4 w-4"></i>복사</button>'+
               '<button onclick="downloadCode(\'javascript\')" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="download" class="h-4 w-4"></i>다운로드</button>'+
               '</div>')+
           createCard('AI 진단 지표','brain',
               '<div class="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs">'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">품질 점수</div><div class="text-lg font-semibold text-gray-800">'+(insights.score!==null?insights.score:'—')+'</div></div>'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">커버리지</div><div class="text-lg font-semibold text-gray-800">'+(insights.coverage||0)+'%</div></div>'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">복잡도</div><div class="text-lg font-semibold text-gray-800">'+(insights.complexity||0)+'</div></div>'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">상태</div><div class="text-lg font-semibold text-gray-800">'+escapeHtml(insights.alertLevel||'대기')+'</div></div>'+
               '</div>'+
               '<div class="mt-3 text-sm text-gray-600">'+escapeHtml(insights.summary||'실행 데이터가 필요합니다.')+'</div>'+
               '<div class="mt-3"><div class="mb-1 text-xs font-medium text-gray-500 uppercase">추천</div><ul class="space-y-2">'+suggestionList+'</ul></div>'+
               '<div><div class="mb-1 text-xs font-medium text-gray-500 uppercase">주의</div><ul class="space-y-2">'+warningList+'</ul></div>',
               'xl:col-span-2')+
           createCard('검증 결과','list-checks',
               '<div class="grid grid-cols-1 md:grid-cols-3 gap-3">'+tests+'</div>'+
               '<div class="mt-3 flex justify-end">'+
               '<button onclick="runAllTests()" class="btn btn-primary">'+
               '<i data-lucide="play-circle" class="h-4 w-4"></i>모든 테스트 재실행</button>'+
               '</div>',
               'xl:col-span-2')+
           '</div>';
}

function renderStudentResults() {
    return '<div class="grid grid-cols-1 gap-4 lg:grid-cols-3">'+
           createCard('나의 성취도','award',
               '<div class="chart-container"><canvas id="achievementChart"></canvas></div>'+
               '<div class="mt-3 text-xs text-gray-500">실시간 업데이트</div>'+
               '<div class="mt-3 flex gap-2">'+
               '<button onclick="exportResults()" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="download" class="h-4 w-4"></i>리포트</button>'+
               '<button onclick="shareResults()" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="share-2" class="h-4 w-4"></i>공유</button>'+
               '</div>',
               'lg:col-span-2')+
           createCard('추천 학습','sparkles',
               '<ol class="space-y-3 text-sm">'+
               '<li class="flex items-start gap-2"><span class="badge badge-primary">1</span>'+
               '<span>조건문 심화 — 불리언 대수</span></li>'+
               '<li class="flex items-start gap-2"><span class="badge badge-primary">2</span>'+
               '<span>반복문 최적화 — 인덱스 스킵</span></li>'+
               '<li class="flex items-start gap-2"><span class="badge badge-primary">3</span>'+
               '<span>함수화 — 재사용 블록</span></li>'+
               '</ol>'+
               '<button onclick="startLearningPath()" class="btn btn-primary w-full mt-4">'+
               '<i data-lucide="arrow-right" class="h-4 w-4"></i>학습 시작</button>')+
           '</div>';
}

// ==================== TEACHER PAGES ====================
function renderTeacherClasses() {
    var atRisk = AppState.students.filter(function(s) {
        return s.role === '학생' && s.progress < 70;
    });
    var riskHtml = atRisk.length ? atRisk.map(function(s) {
        return '<li class="flex items-center justify-between rounded-lg border border-amber-100 bg-amber-50 p-2 text-xs">'+
               '<span class="font-medium text-amber-800">'+escapeHtml(s.name)+'</span>'+
               '<span class="text-amber-700">진도 '+s.progress+'%</span>'+
               '</li>';
    }).join('') : '<li class="text-xs text-gray-500">위험 학생 없음 — 안정적인 학습 상태입니다.</li>';

    return '<div class="grid grid-cols-1 gap-4 xl:grid-cols-3">'+
           createCard('반별 현황','users',
               '<div class="chart-container-large"><canvas id="classChart"></canvas></div>'+
               '<div class="mt-3 flex gap-2">'+
               '<button onclick="refreshClassData()" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="refresh-cw" class="h-4 w-4"></i>새로고침</button>'+
               '<button onclick="exportClassData()" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="download" class="h-4 w-4"></i>내보내기</button>'+
               '</div>',
               'xl:col-span-2')+
           createCard('상위 학생','award',
               '<ul class="space-y-3 text-sm">'+
               '<li class="flex justify-between p-2 rounded-lg bg-gray-50 cursor-pointer hover:bg-gray-100" onclick="viewStudentDetail(1)">'+
               '<span class="font-medium">김아름</span><span class="text-gray-500">92%</span></li>'+
               '<li class="flex justify-between p-2 rounded-lg bg-gray-50 cursor-pointer hover:bg-gray-100" onclick="viewStudentDetail(2)">'+
               '<span class="font-medium">이도현</span><span class="text-gray-500">90%</span></li>'+
               '<li class="flex justify-between p-2 rounded-lg bg-gray-50 cursor-pointer hover:bg-gray-100" onclick="viewStudentDetail(3)">'+
               '<span class="font-medium">박서연</span><span class="text-gray-500">88%</span></li>'+
               '</ul>'+
               '<button onclick="viewAllStudents()" class="btn btn-ghost w-full mt-3">전체 보기</button>')+
           createCard('위험 감지','alert-triangle',
               '<div class="space-y-2 text-sm">'+
               '<div class="rounded-lg bg-amber-50 p-3 text-amber-800">집중 케이스: '+atRisk.length+'명</div>'+
               '<ul class="space-y-2">'+riskHtml+'</ul>'+
               '<button onclick="openInterventionPlan()" class="btn btn-secondary btn-sm w-full mt-3">대응 플랜 제안</button>'+
               '</div>')+
           '</div>';
}

function renderTeacherAssignments() {
    var rows = '';
    AppState.assignments.forEach(function(a) {
        var cls = a.status==='진행중'?'badge-primary':a.status==='완료'?'badge-success':'badge-gray';
        rows += '<tr><td>'+a.id+'</td><td>'+a.title+'</td><td>'+a.due+'</td>'+
               '<td>'+a.submissions+'/'+a.total+'</td>'+
               '<td><span class="badge '+cls+'">'+a.status+'</span></td>'+
               '<td>'+
               '<button onclick="editAssignment(\''+a.id+'\')" class="btn btn-ghost btn-sm">'+
               '<i data-lucide="edit-2" class="h-4 w-4"></i></button>'+
               '<button onclick="deleteAssignment(\''+a.id+'\')" class="btn btn-ghost btn-sm text-red-600">'+
               '<i data-lucide="trash-2" class="h-4 w-4"></i></button>'+
               '</td></tr>';
    });
    
    return '<div class="grid grid-cols-1 gap-4 lg:grid-cols-3">'+
           createCard('과제 목록','clipboard-list',
               '<div class="overflow-hidden rounded-xl border">'+
               '<table class="table">'+
               '<thead><tr><th>ID</th><th>제목</th><th>마감</th><th>제출</th><th>상태</th><th>동작</th></tr></thead>'+
               '<tbody>'+rows+'</tbody></table></div>',
               'lg:col-span-2')+
           createCard('과제 생성','rocket',
               '<div class="space-y-3">'+
               '<div><label class="text-xs text-gray-500 mb-1 block">제목</label>'+
               '<input type="text" id="newTitle" placeholder="과제 제목" class="input"></div>'+
               '<div><label class="text-xs text-gray-500 mb-1 block">마감일</label>'+
               '<input type="date" id="newDue" class="input"></div>'+
               '<div><label class="text-xs text-gray-500 mb-1 block">학생 수</label>'+
               '<input type="number" id="newTotal" value="20" class="input"></div>'+
               '<button onclick="addAssignment()" class="btn btn-primary w-full">'+
               '<i data-lucide="plus" class="h-4 w-4"></i>과제 추가</button>'+
               '<div class="text-xs text-gray-500">※ 실시간 저장</div>'+
               '</div>')+
           '</div>';
}

function renderTeacherReports() {
    var insights = AppState.aiInsights || { score: null, coverage: 0, summary: '실행 데이터가 수집되면 보고서를 생성할 수 있습니다.', suggestions: [] };
    var trendSummary = AppState.runHistory.length ? AppState.runHistory[0] : null;
    var suggestionHtml = (insights.suggestions || []).slice(0,3).map(function(text, idx) {
        return '<li class="flex items-start gap-2 text-sm"><span class="badge badge-primary">'+(idx+1)+'</span><span>'+escapeHtml(text)+'</span></li>';
    }).join('');
    if (!suggestionHtml) suggestionHtml = '<li class="text-sm text-gray-500">추가 실행 후 추천 전략이 제공됩니다.</li>';

    return '<div class="grid grid-cols-1 gap-4 lg:grid-cols-2">'+
           createCard('반별 성취도','bar-chart-2',
               '<div class="chart-container"><canvas id="trendChart"></canvas></div>'+
               '<div class="mt-3 flex gap-2">'+
               '<button onclick="generateReport()" class="btn btn-primary">'+
               '<i data-lucide="file-text" class="h-4 w-4"></i>상세 리포트</button>'+
               '<button onclick="scheduleReport()" class="btn btn-secondary">'+
               '<i data-lucide="calendar" class="h-4 w-4"></i>정기 예약</button>'+
               '</div>')+
           createCard('AI 추천 전략','sparkles',
               '<div class="space-y-3 text-sm">'+
               '<div class="rounded-lg bg-blue-50 p-3 text-blue-800">최근 실행 요약: '+escapeHtml(trendSummary ? trendSummary.summary : '데이터 없음')+'</div>'+
               '<div class="grid grid-cols-2 gap-2 text-xs">'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">품질 점수</div><div class="text-lg font-semibold text-gray-800">'+(insights.score!==null?insights.score:'—')+'</div></div>'+
               '<div class="rounded-lg bg-gray-50 p-2"><div class="text-gray-500">커버리지</div><div class="text-lg font-semibold text-gray-800">'+(insights.coverage||0)+'%</div></div>'+
               '</div>'+
               '<div><div class="mb-1 text-xs font-medium text-gray-500 uppercase">권장 액션</div><ul class="space-y-2">'+suggestionHtml+'</ul></div>'+
               '<button onclick="shareInsights()" class="btn btn-secondary btn-sm w-full">팀과 공유</button>'+
               '</div>')+
           '</div>';
}

// ==================== ADMIN PAGES ====================
function renderAdminUsers() {
    var rows = '';
    AppState.students.forEach(function(u) {
        rows += '<tr><td>'+u.name+'</td><td>'+u.role+'</td><td>'+u.clazz+'</td><td>'+u.progress+'%</td>'+
               '<td>'+
               '<button onclick="editUser('+u.id+')" class="btn btn-ghost btn-sm">'+
               '<i data-lucide="edit-2" class="h-4 w-4"></i></button>'+
               '<button onclick="deleteUser('+u.id+')" class="btn btn-ghost btn-sm text-red-600">'+
               '<i data-lucide="trash-2" class="h-4 w-4"></i></button>'+
               '</td></tr>';
    });
    
    return '<div class="grid gap-4">'+
           createCard('사용자 관리','users',
               '<div class="mb-4 flex gap-2">'+
               '<input id="userSearch" placeholder="이름 검색" onkeyup="filterUsers()" class="input flex-1">'+
               '<button onclick="addUser()" class="btn btn-primary">'+
               '<i data-lucide="user-plus" class="h-4 w-4"></i>추가</button>'+
               '</div>'+
               '<div class="overflow-hidden rounded-xl border">'+
               '<table class="table">'+
               '<thead><tr><th>이름</th><th>역할</th><th>반</th><th>진도</th><th>동작</th></tr></thead>'+
               '<tbody id="usersTable">'+rows+'</tbody></table></div>')+
           '</div>';
}

function renderAdminMonitor() {
    var pulse = (MockData.platformPulse || []).map(function(item) {
        return '<div class="flex items-center justify-between rounded-lg border border-gray-100 bg-white p-3 text-sm">'+
               '<div><div class="font-semibold text-gray-800">'+item.label+'</div>'+ 
               '<div class="text-xs text-gray-500">상태: '+item.status+'</div></div>'+
               '<div class="text-right"><div class="text-lg font-bold text-gray-900">'+item.value+'%</div></div>'+
               '</div>';
    }).join('');

    return '<div class="grid gap-4 lg:grid-cols-3">'+
           createCard('서비스 상태','server',
               '<div class="chart-container"><canvas id="serverChart"></canvas></div>'+
               '<div class="mt-3 text-xs text-gray-500">마지막: '+new Date().toLocaleTimeString()+'</div>'+
               '<div class="mt-3 flex gap-2">'+
               '<button onclick="refreshMonitor()" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="refresh-cw" class="h-4 w-4"></i>새로고침</button>'+
               '<button onclick="viewLogs()" class="btn btn-secondary btn-sm">'+
               '<i data-lucide="file-text" class="h-4 w-4"></i>로그</button>'+
               '</div>',
               'lg:col-span-2')+
           createCard('보안 체크','shield-check',
               '<ul class="space-y-2 text-sm">'+
               ['JWT/OAuth2','RBAC','CSP','Rate Limit'].map(function(s,i) {
                   return '<li class="flex gap-2 p-2 rounded-lg bg-green-50 cursor-pointer hover:bg-green-100" onclick="checkSecurity('+(i+1)+')">'+
                          '<i data-lucide="check-circle" class="h-4 w-4 text-green-600"></i><span>'+s+'</span></li>';
               }).join('')+
               '</ul>')+
           createCard('플랫폼 상태 지표','activity',
               '<div class="space-y-2">'+pulse+'</div>'+
               '<button onclick="refreshMonitor()" class="btn btn-secondary btn-sm w-full mt-3">실시간 동기화</button>')+
           '</div>';
}

function renderAdminSettings() {
    return '<div class="grid gap-4">'+
           createCard('환경 설정','settings',
               '<div class="grid gap-4 md:grid-cols-2">'+
               '<div><label class="text-xs text-gray-500 mb-1 block">배포 채널</label>'+
               '<select id="deployChannel" class="input">'+
               '<option>개발</option><option>스테이징</option><option>프로덕션</option>'+
               '</select></div>'+
               '<div><label class="text-xs text-gray-500 mb-1 block">타임아웃(ms)</label>'+
               '<input type="number" id="sandboxTimeout" value="3000" class="input"></div>'+
               '<div><label class="text-xs text-gray-500 mb-1 block">최대 사용자</label>'+
               '<input type="number" id="maxUsers" value="1000" class="input"></div>'+
               '<div><label class="text-xs text-gray-500 mb-1 block">세션(분)</label>'+
               '<input type="number" id="sessionTimeout" value="30" class="input"></div>'+
               '</div>'+
               '<div class="mt-4 flex justify-end gap-2">'+
               '<button onclick="resetSettings()" class="btn btn-ghost">초기화</button>'+
               '<button onclick="saveSettings()" class="btn btn-primary">저장</button>'+
               '</div>')+
           '</div>';
}

// ==================== ACTION HANDLERS ====================
function resetProgress() {
    if (confirm('진도를 초기화하시겠습니까?')) {
        MockData.studentProgress.forEach(function(p) { p.progress = 0; });
        renderContent();
        showToast('진도 초기화됨', 'success');
    }
}

function addOptimizationRun() {
    var steps = Math.floor(Math.random()*10)+20;
    MockData.optimizationRuns.push({
        attempt: MockData.optimizationRuns.length+1,
        steps: steps,
        time: (Math.random()*2+1).toFixed(1)+'s'
    });
    renderContent();
    showToast('새 시도 기록: '+steps+' 단계', 'success');
}

function toggleOptMode() {
    AppState.optMode = !AppState.optMode;
    AppState.blockCount = AppState.optMode ? 27 : 42;
    var el = document.getElementById('stepCount');
    if (el) el.textContent = AppState.blockCount;
    showToast('최적화: '+(AppState.optMode?'ON':'OFF'), 'success');
}

function initBlockly() {
    // 엔트리 스타일의 드래그 앤 드롭 시스템 초기화
    if (!AppState.workspaceBlocks) AppState.workspaceBlocks = [];

    renderWorkspaceBlocks();
}

var draggedBlock = null;
var SNAP_GRID = 24;
var SNAP_THRESHOLD = 28;
var SNAP_GAP = 16;

function dragStart(e) {
    var target = e.currentTarget || e.target;
    var blockType = target && target.dataset ? target.dataset.block : null;
    if (!blockType) return;

    draggedBlock = {
        type: blockType
    };

    // 드래그 이미지 설정
    var dragImage = target.cloneNode(true);
    dragImage.style.opacity = '0.7';
    document.body.appendChild(dragImage);
    e.dataTransfer.setDragImage(dragImage, 0, 0);
    setTimeout(function() {
        document.body.removeChild(dragImage);
    }, 0);

    var handleDragEnd = function() {
        toggleWorkspaceHover(false);
        draggedBlock = null;
        target.removeEventListener('dragend', handleDragEnd);
    };
    target.addEventListener('dragend', handleDragEnd);
}

function allowDrop(e) {
    e.preventDefault();
    toggleWorkspaceHover(true);
}

function workspaceDragEnter(e) {
    allowDrop(e);
}

function workspaceDragLeave(e) {
    if (e && e.currentTarget && e.relatedTarget && e.currentTarget.contains(e.relatedTarget)) {
        return;
    }
    toggleWorkspaceHover(false);
}

function toggleWorkspaceHover(active) {
    var workspace = document.getElementById('blockWorkspace');
    if (!workspace) return;
    if (active) workspace.classList.add('drag-hover');
    else workspace.classList.remove('drag-hover');
}

function createWorkspaceBlockElement(block) {
    var blockElement = document.createElement('div');
    blockElement.id = block.id;
    blockElement.className = 'block-workspace-item ' + getBlockClass(block.type);
    blockElement.dataset.blockType = block.type;
    blockElement.style.left = (block.x || 0) + 'px';
    blockElement.style.top = (block.y || 0) + 'px';
    blockElement.setAttribute('draggable', 'true');

    var markup = block.content || getBlockMarkup(block.type);
    blockElement.innerHTML = '<div class="flex items-center justify-between gap-2">'+
                             '<div class="flex-1">'+ markup +'</div>'+
                             '<button type="button" class="workspace-remove" aria-label="블록 삭제">'+
                             '<i data-lucide="x" class="h-4 w-4"></i>'+
                             '</button>'+
                             '</div>';

    blockElement.addEventListener('dragstart', function(event) { moveBlockStart(event, block.id); });
    blockElement.addEventListener('drag', function(event) { moveBlock(event, block.id); });
    blockElement.addEventListener('dragend', function(event) { moveBlockEnd(event, block.id); });

    var removeButton = blockElement.querySelector('.workspace-remove');
    if (removeButton) {
        removeButton.addEventListener('click', function() { removeBlock(block.id); });
    }

    return blockElement;
}

function getWorkspaceBlockRecord(blockId) {
    if (!AppState.workspaceBlocks) AppState.workspaceBlocks = [];
    for (var i = 0; i < AppState.workspaceBlocks.length; i++) {
        if (AppState.workspaceBlocks[i].id === blockId) return AppState.workspaceBlocks[i];
    }
    return null;
}

function updateWorkspaceState(blockId, payload) {
    if (!AppState.workspaceBlocks) AppState.workspaceBlocks = [];
    var record = getWorkspaceBlockRecord(blockId);
    if (record) {
        for (var key in payload) {
            if (Object.prototype.hasOwnProperty.call(payload, key)) {
                record[key] = payload[key];
            }
        }
    }
}

function snapBlockPosition(blockElement) {
    if (!blockElement) return;
    var workspace = document.getElementById('blockWorkspace');
    if (!workspace) return;

    var left = parseInt(blockElement.style.left) || 0;
    var top = parseInt(blockElement.style.top) || 0;
    var width = blockElement.offsetWidth;
    var height = blockElement.offsetHeight;
    var workspaceWidth = workspace.clientWidth;
    var workspaceHeight = workspace.clientHeight;

    left = Math.round(left / SNAP_GRID) * SNAP_GRID;
    top = Math.round(top / SNAP_GRID) * SNAP_GRID;

    var blocks = Array.prototype.slice.call(workspace.querySelectorAll('.block-workspace-item')).filter(function(node) {
        return node.id !== blockElement.id;
    });

    blocks.forEach(function(other) {
        var otherLeft = parseInt(other.style.left) || 0;
        var otherTop = parseInt(other.style.top) || 0;
        var otherWidth = other.offsetWidth;
        var otherHeight = other.offsetHeight;

        var alignedVertically = Math.abs(otherLeft - left) <= SNAP_THRESHOLD;
        var alignedHorizontally = Math.abs(otherTop - top) <= SNAP_THRESHOLD;

        if (alignedVertically) {
            var snapBelow = otherTop + otherHeight + SNAP_GAP;
            var snapAbove = otherTop - height - SNAP_GAP;
            if (Math.abs(snapBelow - top) <= SNAP_THRESHOLD) {
                top = snapBelow;
                left = otherLeft;
            } else if (Math.abs(snapAbove - top) <= SNAP_THRESHOLD) {
                top = snapAbove;
                left = otherLeft;
            }
        }

        if (alignedHorizontally) {
            var snapRight = otherLeft + otherWidth + SNAP_GAP;
            var snapLeft = otherLeft - width - SNAP_GAP;
            if (Math.abs(snapRight - left) <= SNAP_THRESHOLD) {
                left = snapRight;
                top = otherTop;
            } else if (Math.abs(snapLeft - left) <= SNAP_THRESHOLD) {
                left = snapLeft;
                top = otherTop;
            }
        }
    });

    left = Math.round(left / SNAP_GRID) * SNAP_GRID;
    top = Math.round(top / SNAP_GRID) * SNAP_GRID;

    var iterations = 0;
    var adjusted = true;
    while (adjusted && iterations < 50) {
        adjusted = false;
        blocks.forEach(function(other) {
            var otherLeft = parseInt(other.style.left) || 0;
            var otherTop = parseInt(other.style.top) || 0;
            var otherWidth = other.offsetWidth;
            var otherHeight = other.offsetHeight;

            var overlapX = left < otherLeft + otherWidth && left + width > otherLeft;
            var overlapY = top < otherTop + otherHeight && top + height > otherTop;

            if (overlapX && overlapY) {
                adjusted = true;
                var below = otherTop + otherHeight + SNAP_GAP;
                var above = otherTop - height - SNAP_GAP;
                var right = otherLeft + otherWidth + SNAP_GAP;
                var leftSide = otherLeft - width - SNAP_GAP;

                if (below + height <= workspaceHeight) {
                    left = otherLeft;
                    top = below;
                } else if (above >= 0) {
                    left = otherLeft;
                    top = above;
                } else if (right + width <= workspaceWidth) {
                    left = right;
                    top = otherTop;
                } else if (leftSide >= 0) {
                    left = leftSide;
                    top = otherTop;
                } else {
                    left = Math.max(0, Math.min(left + SNAP_GRID, workspaceWidth - width));
                    top = Math.max(0, Math.min(top + SNAP_GRID, workspaceHeight - height));
                }
            }
        });
        iterations++;
    }

    var maxLeft = Math.max(0, workspaceWidth - width);
    var maxTop = Math.max(0, workspaceHeight - height);

    left = Math.min(Math.max(0, left), maxLeft);
    top = Math.min(Math.max(0, top), maxTop);

    blockElement.classList.add('snapped');
    blockElement.style.left = left + 'px';
    blockElement.style.top = top + 'px';

    setTimeout(function() {
        blockElement.classList.remove('snapped');
    }, 200);

    updateWorkspaceState(blockElement.id, {
        x: left,
        y: top,
        width: width,
        height: height
    });
}

function drop(e) {
    e.preventDefault();

    if (!draggedBlock) return;

    var workspace = document.getElementById('blockWorkspace');
    if (!workspace) return;

    var rect = workspace.getBoundingClientRect();
    var x = e.clientX - rect.left;
    var y = e.clientY - rect.top;

    var blockId = 'block_' + Date.now();
    var blockContent = getBlockMarkup(draggedBlock.type);

    if (!AppState.workspaceBlocks) AppState.workspaceBlocks = [];

    var blockData = {
        id: blockId,
        type: draggedBlock.type,
        x: x,
        y: y,
        content: blockContent
    };

    AppState.workspaceBlocks.push(blockData);

    var blockElement = createWorkspaceBlockElement(blockData);
    workspace.appendChild(blockElement);
    lucide.createIcons();

    requestAnimationFrame(function() {
        snapBlockPosition(blockElement);
        updateBlockCount();
    });

    draggedBlock = null;
    toggleWorkspaceHover(false);

    showToast('블록이 추가되었습니다', 'success');
}

function getBlockClass(type) {
    var map = {
        'start': 'block-category-start',
        'repeat-start': 'block-category-start',
        'repeat': 'block-category-flow',
        'if': 'block-category-flow',
        'wait': 'block-category-flow',
        'add': 'block-category-calc',
        'compare': 'block-category-calc',
        'random': 'block-category-calc',
        'set-var': 'block-category-var',
        'change-var': 'block-category-var',
        'print': 'block-category-looks',
        'console': 'block-category-looks'
    };
    return map[type] || 'block-category-flow';
}

function getBlockMarkup(type) {
    var map = {
        'start': '▶ 시작하기 버튼을 클릭했을 때',
        'repeat-start': '▶ 무한 반복하기',
        'repeat': '<span class="block-input">10</span> 번 반복하기',
        'if': '만약 <span class="block-input">조건</span> 이라면',
        'wait': '<span class="block-input">1</span> 초 기다리기',
        'add': '<span class="block-input">0</span> + <span class="block-input">0</span>',
        'compare': '<span class="block-input">0</span> = <span class="block-input">0</span>',
        'random': '<span class="block-input">1</span> 부터 <span class="block-input">10</span> 사이의 난수',
        'set-var': '변수 <span class="block-input">이름</span> 을 <span class="block-input">0</span> (으)로 정하기',
        'change-var': '변수 <span class="block-input">이름</span> 을 <span class="block-input">1</span> 만큼 바꾸기',
        'print': '<span class="block-input">안녕!</span> 출력하기',
        'console': '콘솔에 <span class="block-input">값</span> 출력하기'
    };
    return map[type] || (type + ' 블록');
}

var movingBlock = null;
var moveStartPos = { x: 0, y: 0 };

function moveBlockStart(e, blockId) {
    movingBlock = document.getElementById(blockId);
    if (!movingBlock) return;

    var rect = movingBlock.getBoundingClientRect();
    var workspace = document.getElementById('blockWorkspace');
    var workspaceRect = workspace.getBoundingClientRect();

    moveStartPos = {
        x: e.clientX - (rect.left - workspaceRect.left),
        y: e.clientY - (rect.top - workspaceRect.top)
    };

    movingBlock.classList.add('dragging');
    toggleWorkspaceHover(true);
}

function moveBlock(e, blockId) {
    if (!movingBlock) return;
    e.preventDefault();
    toggleWorkspaceHover(true);

    var workspace = document.getElementById('blockWorkspace');
    var rect = workspace.getBoundingClientRect();
    
    var x = e.clientX - rect.left - moveStartPos.x;
    var y = e.clientY - rect.top - moveStartPos.y;
    
    // 경계 체크
    x = Math.max(0, Math.min(x, rect.width - movingBlock.offsetWidth));
    y = Math.max(0, Math.min(y, rect.height - movingBlock.offsetHeight));
    
    movingBlock.style.left = x + 'px';
    movingBlock.style.top = y + 'px';
}

function moveBlockEnd(e, blockId) {
    if (movingBlock) {
        movingBlock.classList.remove('dragging');
        snapBlockPosition(movingBlock);
        updateBlockCount();
    }
    movingBlock = null;
    toggleWorkspaceHover(false);
}

function removeBlock(blockId) {
    var block = document.getElementById(blockId);
    if (block) {
        block.remove();
        
        // 배열에서 제거
        if (AppState.workspaceBlocks) {
            AppState.workspaceBlocks = AppState.workspaceBlocks.filter(function(b) {
                return b.id !== blockId;
            });
        }
        
        updateBlockCount();
        showToast('블록이 제거되었습니다', 'success');
    }
}

function updateBlockCount() {
    if (!AppState.workspaceBlocks) AppState.workspaceBlocks = [];
    
    var count = 0;
    AppState.workspaceBlocks.forEach(function(block) {
        // 각 블록 타입별 단계 수 계산
        if (block.type === 'repeat') count += 3;
        else if (block.type === 'if') count += 2;
        else count += 1;
    });
    
    AppState.blockCount = Math.max(count, AppState.workspaceBlocks.length * 2);

    var el = document.getElementById('stepCount');
    if (el) el.textContent = AppState.blockCount;
    updateWorkspaceHint();
}

function updateWorkspaceHint() {
    var hint = document.getElementById('workspaceHint');
    var workspace = document.getElementById('blockWorkspace');
    var hasBlocks = AppState.workspaceBlocks && AppState.workspaceBlocks.length > 0;

    if (hint) {
        if (hasBlocks) hint.classList.add('hidden');
        else hint.classList.remove('hidden');
    }

    if (workspace) {
        if (hasBlocks) workspace.classList.add('workspace-filled');
        else workspace.classList.remove('workspace-filled');
    }
}

function renderWorkspaceBlocks() {
    var workspace = document.getElementById('blockWorkspace');
    if (!workspace) return;

    workspace.querySelectorAll('.block-workspace-item').forEach(function(node) {
        node.remove();
    });

    if (!AppState.workspaceBlocks) AppState.workspaceBlocks = [];

    var fragment = document.createDocumentFragment();

    AppState.workspaceBlocks.forEach(function(block, index) {
        var blockId = block.id || ('block_'+Date.now()+'_'+index);
        block.id = blockId;
        block.content = block.content || getBlockMarkup(block.type);
        block.x = typeof block.x === 'number' ? block.x : 32 * (index % 4);
        block.y = typeof block.y === 'number' ? block.y : 48 * Math.floor(index / 4);

        var element = createWorkspaceBlockElement(block);
        fragment.appendChild(element);
    });

    workspace.appendChild(fragment);
    lucide.createIcons();

    requestAnimationFrame(function() {
        workspace.querySelectorAll('.block-workspace-item').forEach(function(node) {
            snapBlockPosition(node);
        });
        updateBlockCount();
    });
}

function addBlockToWorkspace(type) {
    showToast(type+' 블록 (드래그 앤 드롭 사용)', 'success');
}

function searchBlocks() {
    var q = document.getElementById('blockSearch').value.toLowerCase();
    var items = document.querySelectorAll('#blockPalette .block-item');
    var categories = document.querySelectorAll('#blockPalette .block-palette-category');
    
    items.forEach(function(el) {
        var text = el.textContent.toLowerCase();
        var show = text.indexOf(q) !== -1;
        el.style.display = show ? 'block' : 'none';
    });
    
    // 카테고리 전체가 숨겨졌는지 확인
    categories.forEach(function(cat) {
        var visibleBlocks = cat.querySelectorAll('.block-item:not([style*="display: none"])');
        cat.style.display = visibleBlocks.length > 0 ? 'block' : 'none';
    });
}

function clearWorkspace() {
    if (confirm('작업 공간을 초기화하시겠습니까?')) {
        var workspace = document.getElementById('blockWorkspace');
        if (workspace) {
            // 모든 블록 제거
            var blocks = workspace.querySelectorAll('.block-workspace-item');
            blocks.forEach(function(block) {
                block.remove();
            });
        }
        
        AppState.workspaceBlocks = [];
        AppState.blockCount = 0;
        updateBlockCount();
        showToast('초기화 완료', 'success');
    }
}

function runCode() {
    if (!AppState.workspaceBlocks || AppState.workspaceBlocks.length === 0) {
        showToast('실행할 블록이 없습니다', 'warning');
        return;
    }
    
    // 코드 실행 시뮬레이션
    var output = '실행 중...\n\n';
    var hasStart = false;
    var hasLogic = false;
    
    AppState.workspaceBlocks.forEach(function(block) {
        if (block.type === 'start' || block.type === 'repeat-start') hasStart = true;
        if (block.type === 'repeat' || block.type === 'if' || block.type === 'print') hasLogic = true;
    });
    
    if (!hasStart) {
        output = '⚠️ 시작 블록이 필요합니다';
        document.getElementById('runOutput').textContent = output;
        showToast('시작 블록을 추가해주세요', 'warning');
        return;
    }
    
    if (!hasLogic) {
        output = '⚠️ 실행할 로직 블록이 필요합니다';
        document.getElementById('runOutput').textContent = output;
        showToast('로직 블록을 추가해주세요', 'warning');
        return;
    }
    
    // 성공적인 실행
    setTimeout(function() {
        var analysis = analyzeWorkspace();
        AppState.generatedCode = {
            python: convertBlocksToCode('python'),
            javascript: convertBlocksToCode('javascript')
        };

        var testsData = [
            { name: '기본 로직 검증', passed: (analysis.score || 0) >= 60 },
            { name: '최적화 규칙', passed: (analysis.coverage || 0) >= 55 },
            { name: '안정성 점검', passed: (analysis.warnings || []).length === 0 }
        ];
        AppState.latestTests = testsData;

        AppState.aiInsights = analysis;
        var now = new Date();
        AppState.lastRunLabel = formatTimestamp(now);

        AppState.runHistory.unshift({
            timestamp: AppState.lastRunLabel,
            score: analysis.score,
            coverage: analysis.coverage,
            summary: analysis.summary,
            warnings: (analysis.warnings || []).length
        });
        AppState.runHistory = AppState.runHistory.slice(0, 6);

        var passedCount = testsData.filter(function(t) { return t.passed; }).length;
        var success = passedCount === testsData.length;
        var statusLabel = success ? '✅ 실행 완료' : '⚠️ 일부 테스트 실패';
        AppState.runResult = statusLabel + ' ('+analysis.score+'점)\n예상 출력: '+analysis.expectedOutput;

        saveState(true);
        refreshPuzzleWidgets();
        showToast(success ? '✅ 실행 성공!' : '⚠️ 개선 필요', success ? 'success' : 'warning');
    }, 400);
}

function getAIHint() {
    var hints = (AppState.aiInsights && AppState.aiInsights.suggestions && AppState.aiInsights.suggestions.length)
        ? AppState.aiInsights.suggestions
        : ['반복 패턴을 묶어 최적화하세요.', '조건을 세분화해 정확도를 높이세요.', '변수를 활용해 상태를 명확히 하세요.'];
    var hint = hints[Math.floor(Math.random()*hints.length)];
    showToast('💡 '+hint, 'success');
}

function copyCode(lang) {
    var code = getGeneratedCode(lang);
    navigator.clipboard.writeText(code).then(function() {
        showToast('복사 완료', 'success');
    });
}

function downloadCode(lang) {
    var code = getGeneratedCode(lang);
    var blob = new Blob([code], {type:'text/plain'});
    var url = window.URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = 'code.'+(lang==='python'?'py':'js');
    a.click();
    window.URL.revokeObjectURL(url);
    showToast('다운로드 완료', 'success');
}

function runAllTests() {
    showToast('테스트 실행 중...', 'success');
    setTimeout(function() {
        renderContent();
        showToast('테스트 완료!', 'success');
    }, 1500);
}

function exportResults() {
    showToast('리포트 생성 중...', 'success');
    setTimeout(function() { showToast('리포트 완료', 'success'); }, 1000);
}

function shareResults() {
    showModal(
        '<h2 class="text-xl font-bold mb-4">결과 공유</h2>'+
        '<div class="space-y-3">'+
        '<label class="text-sm font-medium">공유 링크</label>'+
        '<div class="flex gap-2">'+
        '<input type="text" value="https://codeplay.school/share/12345" class="input flex-1" readonly>'+
        '<button onclick="navigator.clipboard.writeText(\'https://codeplay.school/share/12345\');showToast(\'링크 복사됨\',\'success\');closeModal();" class="btn btn-secondary">복사</button>'+
        '</div>'+
        '<button onclick="closeModal()" class="btn btn-ghost w-full">닫기</button>'+
        '</div>'
    );
}

function startLearningPath() {
    showToast('학습 시작!', 'success');
    AppState.page = 's.puzzle';
    renderNav();
    renderContent();
}

function refreshClassData() {
    showToast('새로고침 중...', 'success');
    setTimeout(function() {
        renderContent();
        showToast('업데이트 완료', 'success');
    }, 1000);
}

function exportClassData() {
    showToast('내보내기 중...', 'success');
    setTimeout(function() { showToast('class_data.csv 다운로드', 'success'); }, 1000);
}

function viewStudentDetail(id) {
    showModal(
        '<h2 class="text-xl font-bold mb-4">학생 상세</h2>'+
        '<div class="grid grid-cols-2 gap-3">'+
        '<div><span class="text-sm text-gray-500">이름</span><br><strong>학생 '+id+'</strong></div>'+
        '<div><span class="text-sm text-gray-500">반</span><br><strong>1반</strong></div>'+
        '<div><span class="text-sm text-gray-500">진도</span><br><strong>85%</strong></div>'+
        '<div><span class="text-sm text-gray-500">점수</span><br><strong>92점</strong></div>'+
        '</div>'+
        '<button onclick="closeModal()" class="btn btn-ghost w-full mt-4">닫기</button>'
    );
}

function viewAllStudents() {
    showToast('전체 학생 로드 중...', 'success');
}

function openInterventionPlan() {
    var atRisk = AppState.students.filter(function(s) { return s.role === '학생' && s.progress < 70; });
    var list = atRisk.length ? atRisk.map(function(s) {
        return '<li class="flex justify-between text-sm"><span>'+escapeHtml(s.name)+'</span><span>'+s.progress+'%</span></li>';
    }).join('') : '<li class="text-sm text-gray-500">위험 학생이 없습니다.</li>';

    showModal(
        '<h2 class="text-xl font-bold mb-4">개입 플랜 제안</h2>'+
        '<div class="space-y-3">'+
        '<div class="rounded-lg bg-amber-50 p-3 text-sm text-amber-800">AI가 '+atRisk.length+'명의 학생을 집중 케이스로 분류했습니다.</div>'+
        '<ul class="space-y-2">'+list+'</ul>'+
        '<label class="text-sm font-medium">권장 조치</label>'+
        '<textarea class="input" style="min-height:6rem;">1) 맞춤형 힌트 제공\n2) 추가 실습 과제 배포\n3) 실시간 피드백 세션 안내</textarea>'+
        '<div class="flex gap-2">'+
        '<button onclick="closeModal()" class="btn btn-ghost flex-1">취소</button>'+
        '<button onclick="closeModal();showToast(\'플랜이 저장되었습니다\',\'success\');" class="btn btn-primary flex-1">저장</button>'+
        '</div></div>'
    );
}

function editAssignment(id) {
    showModal(
        '<h2 class="text-xl font-bold mb-4">과제 수정</h2>'+
        '<div class="space-y-3">'+
        '<label class="text-sm font-medium">과제 ID</label>'+
        '<input type="text" value="'+id+'" class="input" readonly>'+
        '<label class="text-sm font-medium">제목</label>'+
        '<input type="text" id="editTitle" value="과제 제목" class="input">'+
        '<label class="text-sm font-medium">마감일</label>'+
        '<input type="date" id="editDue" class="input">'+
        '<div class="flex gap-2">'+
        '<button onclick="closeModal()" class="btn btn-ghost flex-1">취소</button>'+
        '<button onclick="saveEditAssignment(\''+id+'\')" class="btn btn-primary flex-1">저장</button>'+
        '</div></div>'
    );
}

function saveEditAssignment(id) {
    AppState.assignments.forEach(function(a) {
        if (a.id === id) {
            var title = document.getElementById('editTitle');
            var due = document.getElementById('editDue');
            if (title && title.value) a.title = title.value;
            if (due && due.value) a.due = due.value;
        }
    });
    saveState();
    closeModal();
    renderContent();
}

function deleteAssignment(id) {
    if (confirm('과제를 삭제하시겠습니까?')) {
        AppState.assignments = AppState.assignments.filter(function(a) { return a.id !== id; });
        saveState();
        renderContent();
        showToast('삭제 완료', 'success');
    }
}

function addAssignment() {
    var title = document.getElementById('newTitle');
    var due = document.getElementById('newDue');
    var total = document.getElementById('newTotal');
    
    if (!title || !title.value || !due || !due.value) {
        showToast('제목과 마감일 입력 필요', 'warning');
        return;
    }
    
    AppState.assignments.push({
        id: 'A-'+(100+AppState.assignments.length+1),
        title: title.value,
        due: due.value,
        status: '예정',
        submissions: 0,
        total: total ? parseInt(total.value) : 20
    });
    
    title.value = '';
    due.value = '';
    if (total) total.value = '20';
    
    saveState();
    renderContent();
    showToast('과제 추가됨', 'success');
}

function generateReport() {
    showToast('리포트 생성 중...', 'success');
    setTimeout(function() {
        showModal(
            '<h2 class="text-xl font-bold mb-4">📊 상세 리포트</h2>'+
            '<div class="space-y-3 text-sm">'+
            '<div class="p-3 bg-gray-50 rounded-lg">'+
            '<strong>총 학생:</strong> 75명<br>'+
            '<strong>평균 진도:</strong> 78%<br>'+
            '<strong>평균 성취도:</strong> 85점'+
            '</div>'+
            '<div class="p-3 bg-blue-50 rounded-lg">'+
            '<strong>우수:</strong> 23명 (30%)<br>'+
            '<strong>보통:</strong> 45명 (60%)<br>'+
            '<strong>관심 필요:</strong> 7명 (10%)'+
            '</div>'+
            '<button onclick="closeModal()" class="btn btn-primary w-full">닫기</button>'+
            '</div>'
        );
    }, 1500);
}

function scheduleReport() {
    showModal(
        '<h2 class="text-xl font-bold mb-4">정기 리포트 예약</h2>'+
        '<div class="space-y-3">'+
        '<label class="text-sm font-medium">발송 주기</label>'+
        '<select class="input">'+
        '<option>매주 월요일</option>'+
        '<option>매월 1일</option>'+
        '<option>학기말</option>'+
        '</select>'+
        '<label class="text-sm font-medium">이메일</label>'+
        '<input type="email" placeholder="email@example.com" class="input">'+
        '<div class="flex gap-2">'+
        '<button onclick="closeModal()" class="btn btn-ghost flex-1">취소</button>'+
        '<button onclick="closeModal();showToast(\'예약 완료\',\'success\');" class="btn btn-primary flex-1">예약</button>'+
        '</div></div>'
    );
}

function shareInsights() {
    showToast('팀 공유 링크가 생성되었습니다', 'success');
}

function addUser() {
    showModal(
        '<h2 class="text-xl font-bold mb-4">사용자 추가</h2>'+
        '<div class="space-y-3">'+
        '<label class="text-sm font-medium">이름</label>'+
        '<input type="text" id="newUserName" class="input">'+
        '<label class="text-sm font-medium">역할</label>'+
        '<select id="newUserRole" class="input">'+
        '<option>학생</option><option>교사</option><option>관리자</option>'+
        '</select>'+
        '<label class="text-sm font-medium">반</label>'+
        '<input type="text" id="newUserClass" class="input" placeholder="1반">'+
        '<div class="flex gap-2">'+
        '<button onclick="closeModal()" class="btn btn-ghost flex-1">취소</button>'+
        '<button onclick="saveNewUser()" class="btn btn-primary flex-1">추가</button>'+
        '</div></div>'
    );
}

function saveNewUser() {
    var name = document.getElementById('newUserName');
    var role = document.getElementById('newUserRole');
    var clazz = document.getElementById('newUserClass');
    
    if (!name || !name.value.trim()) {
        showToast('이름 입력 필요', 'warning');
        return;
    }
    
    AppState.students.push({
        id: AppState.students.length+1,
        name: name.value.trim(),
        role: role ? role.value : '학생',
        clazz: clazz ? clazz.value : '—',
        progress: 0,
        score: 0
    });
    
    saveState();
    closeModal();
    renderContent();
    showToast('사용자 추가됨', 'success');
}

function editUser(id) {
    var user = null;
    AppState.students.forEach(function(u) {
        if (u.id === id) user = u;
    });
    if (!user) return;
    
    showModal(
        '<h2 class="text-xl font-bold mb-4">사용자 수정</h2>'+
        '<div class="space-y-3">'+
        '<label class="text-sm font-medium">이름</label>'+
        '<input type="text" id="editUserName" value="'+user.name+'" class="input">'+
        '<label class="text-sm font-medium">역할</label>'+
        '<select id="editUserRole" class="input">'+
        '<option '+(user.role==='학생'?'selected':'')+'>학생</option>'+
        '<option '+(user.role==='교사'?'selected':'')+'>교사</option>'+
        '<option '+(user.role==='관리자'?'selected':'')+'>관리자</option>'+
        '</select>'+
        '<div class="flex gap-2">'+
        '<button onclick="closeModal()" class="btn btn-ghost flex-1">취소</button>'+
        '<button onclick="saveEditUser('+id+')" class="btn btn-primary flex-1">저장</button>'+
        '</div></div>'
    );
}

function saveEditUser(id) {
    var name = document.getElementById('editUserName');
    var role = document.getElementById('editUserRole');
    
    AppState.students.forEach(function(u) {
        if (u.id === id) {
            if (name && name.value) u.name = name.value;
            if (role && role.value) u.role = role.value;
        }
    });
    
    saveState();
    closeModal();
    renderContent();
    showToast('수정 완료', 'success');
}

function deleteUser(id) {
    if (confirm('사용자를 삭제하시겠습니까?')) {
        AppState.students = AppState.students.filter(function(u) { return u.id !== id; });
        saveState();
        renderContent();
        showToast('삭제 완료', 'success');
    }
}

function filterUsers() {
    var q = document.getElementById('userSearch').value.toLowerCase();
    var filtered = AppState.students.filter(function(u) {
        return u.name.toLowerCase().indexOf(q) !== -1;
    });
    
    var tbody = document.getElementById('usersTable');
    if (tbody) {
        var html = '';
        filtered.forEach(function(u) {
            html += '<tr><td>'+u.name+'</td><td>'+u.role+'</td><td>'+u.clazz+'</td><td>'+u.progress+'%</td>'+
                   '<td>'+
                   '<button onclick="editUser('+u.id+')" class="btn btn-ghost btn-sm">'+
                   '<i data-lucide="edit-2" class="h-4 w-4"></i></button>'+
                   '<button onclick="deleteUser('+u.id+')" class="btn btn-ghost btn-sm text-red-600">'+
                   '<i data-lucide="trash-2" class="h-4 w-4"></i></button>'+
                   '</td></tr>';
        });
        tbody.innerHTML = html;
        lucide.createIcons();
    }
}

function refreshMonitor() {
    showToast('새로고침 중...', 'success');
    setTimeout(function() {
        renderContent();
        showToast('업데이트 완료', 'success');
    }, 1000);
}

function viewLogs() {
    showModal(
        '<h2 class="text-xl font-bold mb-4">시스템 로그</h2>'+
        '<div class="space-y-2 text-sm max-h-96 overflow-y-auto">'+
        '<div class="p-2 bg-gray-50 rounded">2025-10-13 14:23:45 - User login</div>'+
        '<div class="p-2 bg-gray-50 rounded">2025-10-13 14:22:10 - Assignment created</div>'+
        '<div class="p-2 bg-gray-50 rounded">2025-10-13 14:20:33 - Code execution</div>'+
        '<div class="p-2 bg-gray-50 rounded">2025-10-13 14:18:22 - DB backup</div>'+
        '<div class="p-2 bg-gray-50 rounded">2025-10-13 14:15:01 - Health check OK</div>'+
        '</div>'+
        '<button onclick="closeModal()" class="btn btn-primary w-full mt-4">닫기</button>'
    );
}

function checkSecurity(id) {
    showToast('보안 항목 #'+id+' 확인 완료', 'success');
}

function resetSettings() {
    if (confirm('설정을 초기화하시겠습니까?')) {
        document.getElementById('deployChannel').value = '개발';
        document.getElementById('sandboxTimeout').value = '3000';
        document.getElementById('maxUsers').value = '1000';
        document.getElementById('sessionTimeout').value = '30';
        showToast('초기화 완료', 'success');
    }
}

function saveSettings() {
    showToast('저장 중...', 'success');
    setTimeout(function() { showToast('설정 저장 완료', 'success'); }, 500);
}

// ==================== CHARTS ====================
function initStudentDashboardCharts() {
    var pc = document.getElementById('progressChart');
    if (pc) {
        AppState.charts.progress = new Chart(pc, {
            type: 'line',
            data: {
                labels: MockData.studentProgress.map(function(d) { return d.week; }),
                datasets: [{
                    label: '진도율 (%)',
                    data: MockData.studentProgress.map(function(d) { return d.progress; }),
                    borderColor: 'rgb(91,140,255)',
                    backgroundColor: 'rgba(91,140,255,0.1)',
                    tension: 0.4,
                    fill: true,
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio: 2,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, max: 100 } }
            }
        });
    }
    
    var oc = document.getElementById('optimizationChart');
    if (oc) {
        AppState.charts.optimization = new Chart(oc, {
            type: 'bar',
            data: {
                labels: MockData.optimizationRuns.map(function(d) { return '시도 '+d.attempt; }),
                datasets: [{
                    label: '단계',
                    data: MockData.optimizationRuns.map(function(d) { return d.steps; }),
                    backgroundColor: 'rgb(91,140,255)',
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio: 2,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true } }
            }
        });
    }
}

function initResultsCharts() {
    var c = document.getElementById('achievementChart');
    if (c) {
        AppState.charts.achievement = new Chart(c, {
            type: 'doughnut',
            data: {
                labels: ['정확도','신속성','일관성','재시도율'],
                datasets: [{
                    data: [92,85,88,78],
                    backgroundColor: ['rgb(91,140,255)','rgb(97,221,170)','rgb(101,120,155)','rgb(246,189,22)'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio: 1.5,
                plugins: { legend: { position: 'bottom' } }
            }
        });
    }
}

function initClassCharts() {
    var c = document.getElementById('classChart');
    if (c) {
        AppState.charts.classChart = new Chart(c, {
            type: 'bar',
            data: {
                labels: MockData.classStats.map(function(d) { return d.name; }),
                datasets: [
                    {
                        label: '정확도 (%)',
                        data: MockData.classStats.map(function(d) { return d.accuracy; }),
                        backgroundColor: 'rgb(91,140,255)',
                        borderRadius: 8
                    },
                    {
                        label: '신속성 (%)',
                        data: MockData.classStats.map(function(d) { return d.speed; }),
                        backgroundColor: 'rgb(97,221,170)',
                        borderRadius: 8
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio: 1.5,
                plugins: { legend: { position: 'top' } },
                scales: { y: { beginAtZero: true, max: 100 } }
            }
        });
    }
}

function initReportsCharts() {
    var c = document.getElementById('trendChart');
    if (c) {
        var trend = [];
        for (var i = 0; i < 8; i++) {
            trend.push({ w: 'W'+(i+1), score: Math.round(60+Math.random()*40) });
        }
        
        AppState.charts.trend = new Chart(c, {
            type: 'line',
            data: {
                labels: trend.map(function(d) { return d.w; }),
                datasets: [{
                    label: '성취도',
                    data: trend.map(function(d) { return d.score; }),
                    borderColor: 'rgb(91,140,255)',
                    backgroundColor: 'rgba(91,140,255,0.1)',
                    tension: 0.4,
                    fill: true,
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio: 2,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, max: 100 } }
            }
        });
    }
}

function initMonitorCharts() {
    var c = document.getElementById('serverChart');
    if (c) {
        AppState.charts.server = new Chart(c, {
            type: 'doughnut',
            data: {
                labels: ['API','DB','Queue','AI'],
                datasets: [{
                    data: [97,92,88,90],
                    backgroundColor: ['rgb(91,140,255)','rgb(97,221,170)','rgb(101,120,155)','rgb(246,189,22)'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio: 1.5,
                plugins: { legend: { position: 'bottom' } }
            }
        });
    }
}

// ==================== INIT ====================
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 CodePlay School 초기화...');
    loadState();
    initDemoData();
    renderNav();
    renderContent();
    console.log('✅ 초기화 완료!');
    showToast('CodePlay School에 오신 것을 환영합니다!', 'success');
    
    document.getElementById('modal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });
});

setInterval(function() {
    if (AppState.assignments.length > 0 || AppState.students.length > 0) {
        saveState();
    }
}, 30000);
</script>

</body>
</html>