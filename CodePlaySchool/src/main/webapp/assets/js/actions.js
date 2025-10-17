(function(global) {
    function resetProgress() {
        if (confirm('진도를 초기화하시겠습니까?')) {
            global.MockData.studentProgress.forEach(function(p) { p.progress = 0; });
            global.renderContent();
            global.showToast('진도 초기화됨', 'success');
        }
    }

    function addOptimizationRun() {
        var steps = Math.floor(Math.random()*10)+20;
        global.MockData.optimizationRuns.push({
            attempt: global.MockData.optimizationRuns.length+1,
            steps: steps,
            time: (Math.random()*2+1).toFixed(1)+'s'
        });
        global.renderContent();
        global.showToast('새 시도 기록: '+steps+' 단계', 'success');
    }

    function toggleOptMode() {
        global.AppState.optMode = !global.AppState.optMode;
        global.AppState.blockCount = global.AppState.optMode ? 27 : 42;
        var el = document.getElementById('stepCount');
        if (el) el.textContent = global.AppState.blockCount;
        global.showToast('최적화: '+(global.AppState.optMode?'ON':'OFF'), 'success');
    }

    function runCode() {
        if (!global.AppState.workspaceBlocks || global.AppState.workspaceBlocks.length === 0) {
            global.showToast('실행할 블록이 없습니다', 'warning');
            return;
        }

        var output = '실행 중...\n\n';
        var hasStart = false;
        var hasLogic = false;

        global.AppState.workspaceBlocks.forEach(function(block) {
            if (block.type === 'start' || block.type === 'repeat-start') hasStart = true;
            if (block.type === 'repeat' || block.type === 'if' || block.type === 'print') hasLogic = true;
        });

        if (!hasStart) {
            output = '⚠️ 시작 블록이 필요합니다';
            var outStart = document.getElementById('runOutput');
            if (outStart) outStart.textContent = output;
            global.showToast('시작 블록을 추가해주세요', 'warning');
            return;
        }

        if (!hasLogic) {
            output = '⚠️ 실행할 로직 블록이 필요합니다';
            var outLogic = document.getElementById('runOutput');
            if (outLogic) outLogic.textContent = output;
            global.showToast('로직 블록을 추가해주세요', 'warning');
            return;
        }

        setTimeout(function() {
            var ok = Math.random() > 0.25;
            global.AppState.runResult = ok ? '✅ 실행 완료!\n\n출력: 30\n\n모든 테스트 통과' : '❌ 실행 오류\n\n테스트 #2 실패\n(예상: 30, 실제: 28)';
            var out = document.getElementById('runOutput');
            if (out) out.textContent = global.AppState.runResult;

            var results = document.getElementById('testResults');
            if (results) {
                var html = '<div class="space-y-1 text-xs">';
                for (var i = 1; i <= 3; i++) {
                    var pass = ok || Math.random() > 0.3;
                    html += '<div class="flex justify-between p-2 rounded '+(pass?'bg-green-50 text-green-700':'bg-red-50 text-red-700')+'">'+
                           '<span>테스트 #'+i+'</span><span>'+(pass?'✓ 통과':'✗ 실패')+'</span></div>';
                }
                html += '</div>';
                results.innerHTML = html;
            }
            global.showToast(ok ? '✅ 실행 성공!' : '⚠️ 일부 실패', ok ? 'success' : 'warning');
        }, 500);
    }

    function getAIHint() {
        var hints = ['변수명을 명확하게','함수로 분리','반복 줄이기','조건문 단순화'];
        global.showToast('💡 '+hints[Math.floor(Math.random()*hints.length)], 'success');
    }

    function copyCode(lang) {
        var code = lang==='python' ?
            'total = 0\nfor i in range(1, 11):\n    if i % 2 == 0:\n        total += i\nprint(total)' :
            'let total = 0;\nfor (let i = 1; i <= 10; i++) {\n  if (i % 2 === 0) {\n    total += i;\n  }\n}\nconsole.log(total);';
        navigator.clipboard.writeText(code).then(function() {
            global.showToast('복사 완료', 'success');
        });
    }

    function downloadCode(lang) {
        var code = lang==='python' ?
            'total = 0\nfor i in range(1, 11):\n    if i % 2 == 0:\n        total += i\nprint(total)' :
            'let total = 0;\nfor (let i = 1; i <= 10; i++) {\n  if (i % 2 === 0) {\n    total += i;\n  }\n}\nconsole.log(total);';
        var blob = new Blob([code], {type:'text/plain'});
        var url = window.URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = 'code.'+(lang==='python'?'py':'js');
        a.click();
        window.URL.revokeObjectURL(url);
        global.showToast('다운로드 완료', 'success');
    }

    function runAllTests() {
        global.showToast('테스트 실행 중...', 'success');
        setTimeout(function() {
            global.renderContent();
            global.showToast('테스트 완료!', 'success');
        }, 1500);
    }

    function exportResults() {
        global.showToast('리포트 생성 중...', 'success');
        setTimeout(function() { global.showToast('리포트 완료', 'success'); }, 1000);
    }

    function shareResults() {
        global.showModal(
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
        global.showToast('학습 시작!', 'success');
        global.AppState.page = 's.puzzle';
        global.renderNav();
        global.renderContent();
    }

    function refreshClassData() {
        global.showToast('새로고침 중...', 'success');
        setTimeout(function() {
            global.renderContent();
            global.showToast('업데이트 완료', 'success');
        }, 1000);
    }

    function exportClassData() {
        global.showToast('내보내기 중...', 'success');
        setTimeout(function() { global.showToast('class_data.csv 다운로드', 'success'); }, 1000);
    }

    function viewStudentDetail(id) {
        global.showModal(
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
        global.showToast('전체 학생 로드 중...', 'success');
    }

    function editAssignment(id) {
        global.showModal(
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
        global.AppState.assignments.forEach(function(a) {
            if (a.id === id) {
                var title = document.getElementById('editTitle');
                var due = document.getElementById('editDue');
                if (title && title.value) a.title = title.value;
                if (due && due.value) a.due = due.value;
            }
        });
        global.saveState();
        global.closeModal();
        global.renderContent();
    }

    function deleteAssignment(id) {
        if (confirm('과제를 삭제하시겠습니까?')) {
            global.AppState.assignments = global.AppState.assignments.filter(function(a) { return a.id !== id; });
            global.saveState();
            global.renderContent();
            global.showToast('삭제 완료', 'success');
        }
    }

    function addAssignment() {
        var title = document.getElementById('newTitle');
        var due = document.getElementById('newDue');
        var total = document.getElementById('newTotal');

        if (!title || !title.value || !due || !due.value) {
            global.showToast('제목과 마감일 입력 필요', 'warning');
            return;
        }

        global.AppState.assignments.push({
            id: 'A-'+(100+global.AppState.assignments.length+1),
            title: title.value,
            due: due.value,
            status: '예정',
            submissions: 0,
            total: total ? parseInt(total.value, 10) : 20
        });

        title.value = '';
        due.value = '';
        if (total) total.value = '20';

        global.saveState();
        global.renderContent();
        global.showToast('과제 추가됨', 'success');
    }

    function generateReport() {
        global.showToast('리포트 생성 중...', 'success');
        setTimeout(function() {
            global.showModal(
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
        global.showModal(
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

    function addUser() {
        global.showModal(
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
            global.showToast('이름 입력 필요', 'warning');
            return;
        }

        global.AppState.students.push({
            id: global.AppState.students.length+1,
            name: name.value.trim(),
            role: role ? role.value : '학생',
            clazz: clazz ? clazz.value : '—',
            progress: 0,
            score: 0
        });

        global.saveState();
        global.closeModal();
        global.renderContent();
        global.showToast('사용자 추가됨', 'success');
    }

    function editUser(id) {
        var user = null;
        global.AppState.students.forEach(function(u) {
            if (u.id === id) user = u;
        });
        if (!user) return;

        global.showModal(
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

        global.AppState.students.forEach(function(u) {
            if (u.id === id) {
                if (name && name.value) u.name = name.value;
                if (role && role.value) u.role = role.value;
            }
        });

        global.saveState();
        global.closeModal();
        global.renderContent();
        global.showToast('수정 완료', 'success');
    }

    function deleteUser(id) {
        if (confirm('사용자를 삭제하시겠습니까?')) {
            global.AppState.students = global.AppState.students.filter(function(u) { return u.id !== id; });
            global.saveState();
            global.renderContent();
            global.showToast('삭제 완료', 'success');
        }
    }

    function filterUsers() {
        var input = document.getElementById('userSearch');
        if (!input) return;
        var q = input.value.toLowerCase();
        var filtered = global.AppState.students.filter(function(u) {
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
            if (global.lucide && global.lucide.createIcons) {
                global.lucide.createIcons();
            }
        }
    }

    function refreshMonitor() {
        global.showToast('새로고침 중...', 'success');
        setTimeout(function() {
            global.renderContent();
            global.showToast('업데이트 완료', 'success');
        }, 1000);
    }

    function viewLogs() {
        global.showModal(
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
        global.showToast('보안 항목 #'+id+' 확인 완료', 'success');
    }

    function resetSettings() {
        if (confirm('설정을 초기화하시겠습니까?')) {
            var deploy = document.getElementById('deployChannel');
            var timeout = document.getElementById('sandboxTimeout');
            var maxUsers = document.getElementById('maxUsers');
            var session = document.getElementById('sessionTimeout');
            if (deploy) deploy.value = '개발';
            if (timeout) timeout.value = '3000';
            if (maxUsers) maxUsers.value = '1000';
            if (session) session.value = '30';
            global.showToast('초기화 완료', 'success');
        }
    }

    function saveSettings() {
        global.showToast('저장 중...', 'success');
        setTimeout(function() { global.showToast('설정 저장 완료', 'success'); }, 500);
    }

    global.resetProgress = resetProgress;
    global.addOptimizationRun = addOptimizationRun;
    global.toggleOptMode = toggleOptMode;
    global.runCode = runCode;
    global.getAIHint = getAIHint;
    global.copyCode = copyCode;
    global.downloadCode = downloadCode;
    global.runAllTests = runAllTests;
    global.exportResults = exportResults;
    global.shareResults = shareResults;
    global.startLearningPath = startLearningPath;
    global.refreshClassData = refreshClassData;
    global.exportClassData = exportClassData;
    global.viewStudentDetail = viewStudentDetail;
    global.viewAllStudents = viewAllStudents;
    global.editAssignment = editAssignment;
    global.saveEditAssignment = saveEditAssignment;
    global.deleteAssignment = deleteAssignment;
    global.addAssignment = addAssignment;
    global.generateReport = generateReport;
    global.scheduleReport = scheduleReport;
    global.addUser = addUser;
    global.saveNewUser = saveNewUser;
    global.editUser = editUser;
    global.saveEditUser = saveEditUser;
    global.deleteUser = deleteUser;
    global.filterUsers = filterUsers;
    global.refreshMonitor = refreshMonitor;
    global.viewLogs = viewLogs;
    global.checkSecurity = checkSecurity;
    global.resetSettings = resetSettings;
    global.saveSettings = saveSettings;
})(window);
