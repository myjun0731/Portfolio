(function(global) {
    document.addEventListener('DOMContentLoaded', function() {
        console.log('🚀 CodePlay School 초기화...');
        global.loadState();
        global.initDemoData();
        global.renderNav();
        global.renderContent();
        console.log('✅ 초기화 완료!');
        global.showToast('CodePlay School에 오신 것을 환영합니다!', 'success');

        var modal = document.getElementById('modal');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === modal) global.closeModal();
            });
        }
    });

    setInterval(function() {
        if (global.AppState.assignments.length > 0 || global.AppState.students.length > 0) {
            global.saveState();
        }
    }, 30000);
})(window);
