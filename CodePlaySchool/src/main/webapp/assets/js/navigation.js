(function(global) {
    function renderNav() {
        var nav = document.getElementById('navMenu');
        if (!nav) return;
        var items = global.NavItems[global.AppState.role] || [];
        var html = '';
        for (var i = 0; i < items.length; i++) {
            var it = items[i];
            var active = global.AppState.page === it.key ? 'active' : '';
            html += '<button onclick="changePage(\''+it.key+'\')" '+
                    'class="nav-item '+active+' flex w-full items-center gap-3 rounded-xl px-3 py-2 text-left text-sm">'+
                    '<i data-lucide="'+it.icon+'" class="h-4 w-4"></i>'+it.label+'</button>';
        }
        nav.innerHTML = html;
        if (global.lucide && global.lucide.createIcons) {
            global.lucide.createIcons();
        }
    }

    function changeRole(newRole) {
        global.AppState.role = newRole;
        var btns = document.querySelectorAll('.role-btn');
        for (var i = 0; i < btns.length; i++) {
            if (btns[i].dataset.role === newRole) btns[i].classList.add('active');
            else btns[i].classList.remove('active');
        }
        if (newRole === 'student') global.AppState.page = 's.dashboard';
        else if (newRole === 'teacher') global.AppState.page = 't.classes';
        else global.AppState.page = 'a.monitor';
        renderNav();
        global.renderContent();
        global.showToast('역할: ' + newRole, 'success');
    }

    function changePage(newPage) {
        global.AppState.page = newPage;
        renderNav();
        global.renderContent();
    }

    global.renderNav = renderNav;
    global.changeRole = changeRole;
    global.changePage = changePage;
})(window);
