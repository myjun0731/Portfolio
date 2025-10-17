(function(global) {
    function loadState() {
        try {
            var saved = localStorage.getItem('codeplay_state');
            if (saved) {
                var parsed = JSON.parse(saved);
                global.AppState.assignments = parsed.assignments || [];
                global.AppState.students = parsed.students || [];
            }
        } catch (e) {
            console.error('Load failed:', e);
        }
    }

    function saveState() {
        try {
            localStorage.setItem('codeplay_state', JSON.stringify({
                assignments: global.AppState.assignments,
                students: global.AppState.students
            }));
            global.showToast && global.showToast('데이터 저장됨', 'success');
        } catch (e) {
            global.showToast && global.showToast('저장 실패', 'error');
        }
    }

    function initDemoData() {
        if (global.AppState.assignments.length === 0) {
            global.AppState.assignments = [
                {id:'A-101',title:'변수 기초',due:'2025-10-20',status:'진행중',submissions:15,total:20},
                {id:'A-102',title:'조건문 챌린지',due:'2025-10-27',status:'예정',submissions:0,total:20},
                {id:'A-103',title:'반복문 퍼즐',due:'2025-11-03',status:'예정',submissions:0,total:20}
            ];
        }
        if (global.AppState.students.length === 0) {
            global.AppState.students = [
                {id:1,name:'강지민',role:'학생',clazz:'1반',progress:85,score:92},
                {id:2,name:'최도윤',role:'학생',clazz:'2반',progress:78,score:88},
                {id:3,name:'박서연',role:'학생',clazz:'1반',progress:92,score:95},
                {id:4,name:'한서우',role:'교사',clazz:'—',progress:100,score:100}
            ];
        }
    }

    global.loadState = loadState;
    global.saveState = saveState;
    global.initDemoData = initDemoData;
})(window);
