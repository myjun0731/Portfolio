(function(global) {
    var initialState = global.__INITIAL_STATE__ || {};

    global.AppState = {
        role: initialState.role || 'student',
        page: initialState.page || 's.dashboard',
        optMode: true,
        runResult: '',
        blockCount: 0,
        assignments: [],
        students: [],
        charts: {},
        workspaceBlocks: []
    };

    global.MockData = {
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
        ]
    };

    global.NavItems = {
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
})(window);
