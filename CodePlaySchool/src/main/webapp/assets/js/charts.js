(function(global) {
    function initStudentDashboardCharts() {
        var pc = document.getElementById('progressChart');
        if (pc) {
            global.AppState.charts.progress = new Chart(pc, {
                type: 'line',
                data: {
                    labels: global.MockData.studentProgress.map(function(d) { return d.week; }),
                    datasets: [{
                        label: '진도율 (%)',
                        data: global.MockData.studentProgress.map(function(d) { return d.progress; }),
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
            global.AppState.charts.optimization = new Chart(oc, {
                type: 'bar',
                data: {
                    labels: global.MockData.optimizationRuns.map(function(d) { return '시도 '+d.attempt; }),
                    datasets: [{
                        label: '단계',
                        data: global.MockData.optimizationRuns.map(function(d) { return d.steps; }),
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
            global.AppState.charts.achievement = new Chart(c, {
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
            global.AppState.charts.classChart = new Chart(c, {
                type: 'bar',
                data: {
                    labels: global.MockData.classStats.map(function(d) { return d.name; }),
                    datasets: [
                        {
                            label: '정확도 (%)',
                            data: global.MockData.classStats.map(function(d) { return d.accuracy; }),
                            backgroundColor: 'rgb(91,140,255)',
                            borderRadius: 8
                        },
                        {
                            label: '신속성 (%)',
                            data: global.MockData.classStats.map(function(d) { return d.speed; }),
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

            global.AppState.charts.trend = new Chart(c, {
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
            global.AppState.charts.server = new Chart(c, {
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

    global.initStudentDashboardCharts = initStudentDashboardCharts;
    global.initResultsCharts = initResultsCharts;
    global.initClassCharts = initClassCharts;
    global.initReportsCharts = initReportsCharts;
    global.initMonitorCharts = initMonitorCharts;
})(window);
