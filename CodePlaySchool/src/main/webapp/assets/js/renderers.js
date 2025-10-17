(function(global) {
    function renderContent() {
        global.destroyCharts();
        var content = document.getElementById('contentArea');
        if (!content) return;
        content.className = 'fade-in';
        var html = '';

        switch(global.AppState.page) {
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
        if (global.lucide && global.lucide.createIcons) {
            global.lucide.createIcons();
        }

        setTimeout(function() {
            if (global.AppState.page === 's.dashboard') global.initStudentDashboardCharts();
            else if (global.AppState.page === 's.puzzle') global.initBlockly();
            else if (global.AppState.page === 's.results') global.initResultsCharts();
            else if (global.AppState.page === 't.classes') global.initClassCharts();
            else if (global.AppState.page === 't.reports') global.initReportsCharts();
            else if (global.AppState.page === 'a.monitor') global.initMonitorCharts();
        }, 100);
    }

    function renderStudentDashboard() {
        var badges = '';
        for (var i = 0; i < global.MockData.badges.length; i++) {
            var b = global.MockData.badges[i];
            var cls = b.earned ? 'bg-yellow-50 border-yellow-300' : 'bg-gray-50 opacity-50';
            badges += '<div class="flex flex-col items-start rounded-xl border p-3 '+cls+'">'+
                     '<div class="flex items-center gap-2 font-semibold text-sm">'+
                     '<i data-lucide="award" class="h-4 w-4"></i>'+b.name+'</div>'+
                     '<div class="text-xs text-gray-500 mt-1">'+b.desc+'</div>'+
                     (b.earned ? '<div class="mt-2 badge badge-success">획득!</div>' : '')+'</div>';
        }

        return '<div class="grid grid-cols-1 gap-4 lg:grid-cols-3">'+
               global.createCard('주차별 진도율', 'book-open',
                   '<div class="chart-container"><canvas id="progressChart"></canvas></div>'+ 
                   '<div class="mt-3"><button onclick="resetProgress()" class="btn btn-secondary btn-sm">진도 초기화</button></div>',
                   'lg:col-span-2')+
               global.createCard('획득한 뱃지', 'award', '<div class="flex flex-wrap gap-2">'+badges+'</div>')+
               global.createCard('최적화 시도 기록', 'activity',
                   '<div class="chart-container"><canvas id="optimizationChart"></canvas></div>'+ 
                   '<div class="mt-3 text-xs text-gray-500">목표: 25 이하</div>'+ 
                   '<button onclick="addOptimizationRun()" class="btn btn-primary btn-sm mt-2">새 시도 추가</button>',
                   'lg:col-span-3')+
               '</div>';
    }

    function renderStudentPuzzle() {
        return '<div class="grid grid-cols-1 gap-4 xl:grid-cols-12">'+
               '<div class="xl:col-span-3">'+
               '<div class="card"><div class="card-body" style="max-height:calc(100vh-12rem);overflow-y:auto;">'+
               '<div class="mb-3 flex items-center gap-2">'+
               '<i data-lucide="puzzle" class="h-5 w-5"></i>'+
               '<h3 class="text-lg font-semibold">블록 팔레트</h3>'+
               '</div>'+
               '<input id="blockSearch" placeholder="블록 검색" class="input mb-3" onkeyup="searchBlocks()">'+
               '<div id="blockPalette">'+
               '<div class="block-palette-category">'+
               '<div class="block-palette-title">🎬 시작</div>'+
               '<div class="block-item block-category-start mb-2" draggable="true" ondragstart="dragStart(event)" data-block="start">'+
               '▶ 시작하기 버튼을 클릭했을 때'+
               '</div>'+
               '<div class="block-item block-category-start mb-2" draggable="true" ondragstart="dragStart(event)" data-block="repeat-start">'+
               '▶ 무한 반복하기'+
               '</div>'+
               '</div>'+
               '<div class="block-palette-category">'+
               '<div class="block-palette-title">🔄 흐름</div>'+
               '<div class="block-item block-category-flow mb-2" draggable="true" ondragstart="dragStart(event)" data-block="repeat">'+
               '<span class="block-input">10</span> 번 반복하기'+
               '</div>'+
               '<div class="block-item block-category-flow mb-2" draggable="true" ondragstart="dragStart(event)" data-block="if">'+
               '만약 <span class="block-input">조건</span> 이라면'+
               '</div>'+
               '<div class="block-item block-category-flow mb-2" draggable="true" ondragstart="dragStart(event)" data-block="wait">'+
               '<span class="block-input">1</span> 초 기다리기'+
               '</div>'+
               '</div>'+
               '<div class="block-palette-category">'+
               '<div class="block-palette-title">📐 계산</div>'+
               '<div class="block-item block-category-calc mb-2" draggable="true" ondragstart="dragStart(event)" data-block="add">'+
               '<span class="block-input">0</span> + <span class="block-input">0</span>'+
               '</div>'+
               '<div class="block-item block-category-calc mb-2" draggable="true" ondragstart="dragStart(event)" data-block="compare">'+
               '<span class="block-input">0</span> = <span class="block-input">0</span>'+
               '</div>'+
               '<div class="block-item block-category-calc mb-2" draggable="true" ondragstart="dragStart(event)" data-block="random">'+
               '<span class="block-input">1</span> 부터 <span class="block-input">10</span> 사이의 난수'+
               '</div>'+
               '</div>'+
               '<div class="block-palette-category">'+
               '<div class="block-palette-title">📦 변수</div>'+
               '<div class="block-item block-category-var mb-2" draggable="true" ondragstart="dragStart(event)" data-block="set-var">'+
               '변수 <span class="block-input">이름</span> 을 <span class="block-input">0</span> (으)로 정하기'+
               '</div>'+
               '<div class="block-item block-category-var mb-2" draggable="true" ondragstart="dragStart(event)" data-block="change-var">'+
               '변수 <span class="block-input">이름</span> 을 <span class="block-input">1</span> 만큼 바꾸기'+
               '</div>'+
               '</div>'+
               '<div class="block-palette-category">'+
               '<div class="block-palette-title">📺 보이기</div>'+
               '<div class="block-item block-category-looks mb-2" draggable="true" ondragstart="dragStart(event)" data-block="print">'+
               '<span class="block-input">안녕!</span> 출력하기'+
               '</div>'+
               '<div class="block-item block-category-looks mb-2" draggable="true" ondragstart="dragStart(event)" data-block="console">'+
               '콘솔에 <span class="block-input">값</span> 출력하기'+
               '</div>'+
               '</div>'+
               '</div>'+
               '<div class="mt-3 text-xs text-gray-500 p-3 border border-dashed rounded-xl">'+
               '💡 블록을 드래그하여 작업 공간에 배치하세요'+
               '</div>'+
               '</div></div>'+
               '</div>'+
               '<div class="xl:col-span-6">'+
               '<div class="card"><div class="card-body">'+
               '<div class="mb-3 flex items-center justify-between flex-wrap gap-2">'+
               '<div class="flex items-center gap-2">'+
               '<i data-lucide="layers" class="h-5 w-5"></i>'+
               '<h3 class="text-lg font-semibold">작업 공간</h3>'+
               '</div>'+
               '<div class="flex gap-2 flex-wrap">'+
               '<span class="tag">목표: 25단계 이하</span>'+
               '<button onclick="toggleOptMode()" class="btn btn-secondary">'+
               '<i data-lucide="rocket" class="h-4 w-4"></i>최적화 '+(global.AppState.optMode?'ON':'OFF')+
               '</button>'+
               '<button onclick="clearWorkspace()" class="btn btn-ghost">'+
               '<i data-lucide="trash-2" class="h-4 w-4"></i>초기화</button>'+
               '<button onclick="runCode()" class="btn btn-primary">'+
               '<i data-lucide="play" class="h-4 w-4"></i>실행</button>'+
               '</div></div>'+
               '<div id="blockWorkspace" class="workspace-area" style="height:24rem;" '+
               'ondrop="drop(event)" ondragover="allowDrop(event)" ondragenter="workspaceDragEnter(event)" ondragleave="workspaceDragLeave(event)">'+
               '<div id="workspaceHint" class="workspace-hint">'+
               '<div><div class="text-3xl mb-2">🎯</div><div>팔레트에서 블록을 드래그하여 놓아보세요</div></div>'+
               '</div>'+
               '</div>'+
               '<div class="mt-3 flex items-center justify-between text-xs">'+
               '<div class="text-gray-500">💡 힌트: 반복문으로 코드를 줄여보세요</div>'+
               '<div class="font-semibold text-gray-700">실행 단계: <span id="stepCount">'+global.AppState.blockCount+'</span></div>'+
               '</div>'+
               '</div></div>'+
               '</div>'+
               '<div class="xl:col-span-3 space-y-4">'+
               global.createCard('시뮬레이션','activity',
                   '<div class="flex items-center justify-center rounded-xl border p-4" style="min-height:16rem;">'+
                   '<div class="text-center w-full">'+
                   '<div class="text-sm text-gray-500 mb-2">실행 결과</div>'+
                   '<div class="output-console" id="runOutput">'+(global.AppState.runResult||'[대기 중]')+'</div>'+
                   '<div id="testResults" class="mt-3"></div>'+
                   '</div></div>')+
               global.createCard('AI 도우미','sparkles',
                   '<ul class="list-disc pl-5 text-sm space-y-2 text-gray-700">'+
                   '<li>조건문 중첩 대신 조기 반환</li>'+
                   '<li>반복문 내 변수 재사용</li>'+
                   '<li>불필요한 비교 연산 제거</li>'+
                   '</ul>'+
                   '<button onclick="getAIHint()" class="btn btn-secondary w-full mt-3">'+
                   '<i data-lucide="lightbulb" class="h-4 w-4"></i>새 힌트 받기</button>')+
               '</div>'+
               '</div>';
    }

    function renderStudentCompare() {
        var py = 'total = 0\nfor i in range(1, 11):\n    if i % 2 == 0:\n        total += i\nprint(total)';
        var js = 'let total = 0;\nfor (let i = 1; i <= 10; i++) {\n  if (i % 2 === 0) {\n    total += i;\n  }\n}\nconsole.log(total);';

        var tests = '';
        for (var i = 1; i <= 3; i++) {
            var ok = Math.random() > 0.2;
            tests += '<div class="rounded-xl border p-3 text-sm bg-gray-50">'+
                    '<div class="flex items-center justify-between mb-2">'+
                    '<span class="font-medium">테스트 #'+i+'</span>'+
                    '<span class="badge '+(ok?'badge-success">통과':'badge-danger">실패')+'</span>'+
                    '</div>'+
                    '<div class="text-xs text-gray-500">입력: N=10 / 출력: '+(ok?'30':'28')+'</div>'+
                    '</div>';
        }

        return '<div class="grid grid-cols-1 gap-4 xl:grid-cols-2">'+
               global.createCard('Python','code-2',
                   '<pre class="code-block" style="max-height:24rem;">'+py+'</pre>'+
                   '<div class="mt-3 flex gap-2">'+
                   '<button onclick="copyCode(\'python\')" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="copy" class="h-4 w-4"></i>복사</button>'+
                   '<button onclick="downloadCode(\'python\')" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="download" class="h-4 w-4"></i>다운로드</button>'+
                   '</div>')+
               global.createCard('JavaScript','code-2',
                   '<pre class="code-block" style="max-height:24rem;">'+js+'</pre>'+
                   '<div class="mt-3 flex gap-2">'+
                   '<button onclick="copyCode(\'javascript\')" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="copy" class="h-4 w-4"></i>복사</button>'+
                   '<button onclick="downloadCode(\'javascript\')" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="download" class="h-4 w-4"></i>다운로드</button>'+
                   '</div>')+
               global.createCard('검증 결과','list-checks',
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
               global.createCard('나의 성취도','award',
                   '<div class="chart-container"><canvas id="achievementChart"></canvas></div>'+
                   '<div class="mt-3 text-xs text-gray-500">실시간 업데이트</div>'+
                   '<div class="mt-3 flex gap-2">'+
                   '<button onclick="exportResults()" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="download" class="h-4 w-4"></i>리포트</button>'+
                   '<button onclick="shareResults()" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="share-2" class="h-4 w-4"></i>공유</button>'+
                   '</div>',
                   'lg:col-span-2')+
               global.createCard('추천 학습','sparkles',
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

    function renderTeacherClasses() {
        return '<div class="grid grid-cols-1 gap-4 xl:grid-cols-3">'+
               global.createCard('반별 현황','users',
                   '<div class="chart-container-large"><canvas id="classChart"></canvas></div>'+
                   '<div class="mt-3 flex gap-2">'+
                   '<button onclick="refreshClassData()" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="refresh-cw" class="h-4 w-4"></i>새로고침</button>'+
                   '<button onclick="exportClassData()" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="download" class="h-4 w-4"></i>내보내기</button>'+
                   '</div>',
                   'xl:col-span-2')+
               global.createCard('상위 학생','award',
                   '<ul class="space-y-3 text-sm">'+
                   '<li class="flex justify-between p-2 rounded-lg bg-gray-50 cursor-pointer hover:bg-gray-100" onclick="viewStudentDetail(1)">'+
                   '<span class="font-medium">김아름</span><span class="text-gray-500">92%</span></li>'+
                   '<li class="flex justify-between p-2 rounded-lg bg-gray-50 cursor-pointer hover:bg-gray-100" onclick="viewStudentDetail(2)">'+
                   '<span class="font-medium">이도현</span><span class="text-gray-500">90%</span></li>'+
                   '<li class="flex justify-between p-2 rounded-lg bg-gray-50 cursor-pointer hover:bg-gray-100" onclick="viewStudentDetail(3)">'+
                   '<span class="font-medium">박서연</span><span class="text-gray-500">88%</span></li>'+
                   '</ul>'+
                   '<button onclick="viewAllStudents()" class="btn btn-ghost w-full mt-3">전체 보기</button>')+
               '</div>';
    }

    function renderTeacherAssignments() {
        var rows = '';
        global.AppState.assignments.forEach(function(a) {
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
               global.createCard('과제 목록','clipboard-list',
                   '<div class="overflow-hidden rounded-xl border">'+
                   '<table class="table">'+
                   '<thead><tr><th>ID</th><th>제목</th><th>마감</th><th>제출</th><th>상태</th><th>동작</th></tr></thead>'+
                   '<tbody>'+rows+'</tbody></table></div>',
                   'lg:col-span-2')+
               global.createCard('과제 생성','rocket',
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
        return '<div class="grid grid-cols-1 gap-4">'+
               global.createCard('반별 성취도','bar-chart-2',
                   '<div class="chart-container"><canvas id="trendChart"></canvas></div>'+
                   '<div class="mt-3 flex gap-2">'+
                   '<button onclick="generateReport()" class="btn btn-primary">'+
                   '<i data-lucide="file-text" class="h-4 w-4"></i>상세 리포트</button>'+
                   '<button onclick="scheduleReport()" class="btn btn-secondary">'+
                   '<i data-lucide="calendar" class="h-4 w-4"></i>정기 예약</button>'+
                   '</div>')+
               '</div>';
    }

    function renderAdminUsers() {
        var rows = '';
        global.AppState.students.forEach(function(u) {
            rows += '<tr><td>'+u.name+'</td><td>'+u.role+'</td><td>'+u.clazz+'</td><td>'+u.progress+'%</td>'+
                   '<td>'+
                   '<button onclick="editUser('+u.id+')" class="btn btn-ghost btn-sm">'+
                   '<i data-lucide="edit-2" class="h-4 w-4"></i></button>'+
                   '<button onclick="deleteUser('+u.id+')" class="btn btn-ghost btn-sm text-red-600">'+
                   '<i data-lucide="trash-2" class="h-4 w-4"></i></button>'+
                   '</td></tr>';
        });

        return '<div class="grid gap-4">'+
               global.createCard('사용자 관리','users',
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
        return '<div class="grid gap-4 lg:grid-cols-3">'+
               global.createCard('서비스 상태','server',
                   '<div class="chart-container"><canvas id="serverChart"></canvas></div>'+
                   '<div class="mt-3 text-xs text-gray-500">마지막: '+new Date().toLocaleTimeString()+'</div>'+
                   '<div class="mt-3 flex gap-2">'+
                   '<button onclick="refreshMonitor()" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="refresh-cw" class="h-4 w-4"></i>새로고침</button>'+
                   '<button onclick="viewLogs()" class="btn btn-secondary btn-sm">'+
                   '<i data-lucide="file-text" class="h-4 w-4"></i>로그</button>'+
                   '</div>',
                   'lg:col-span-2')+
               global.createCard('보안 체크','shield-check',
                   '<ul class="space-y-2 text-sm">'+
                   ['JWT/OAuth2','RBAC','CSP','Rate Limit'].map(function(s,i) {
                       return '<li class="flex gap-2 p-2 rounded-lg bg-green-50 cursor-pointer hover:bg-green-100" onclick="checkSecurity('+(i+1)+')">'+
                              '<i data-lucide="check-circle" class="h-4 w-4 text-green-600"></i><span>'+s+'</span></li>';
                   }).join('')+
                   '</ul>')+
               '</div>';
    }

    function renderAdminSettings() {
        return '<div class="grid gap-4">'+
               global.createCard('환경 설정','settings',
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

    global.renderContent = renderContent;
    global.renderStudentDashboard = renderStudentDashboard;
    global.renderStudentPuzzle = renderStudentPuzzle;
    global.renderStudentCompare = renderStudentCompare;
    global.renderStudentResults = renderStudentResults;
    global.renderTeacherClasses = renderTeacherClasses;
    global.renderTeacherAssignments = renderTeacherAssignments;
    global.renderTeacherReports = renderTeacherReports;
    global.renderAdminUsers = renderAdminUsers;
    global.renderAdminMonitor = renderAdminMonitor;
    global.renderAdminSettings = renderAdminSettings;
})(window);
