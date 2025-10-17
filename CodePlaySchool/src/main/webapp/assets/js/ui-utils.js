(function(global) {
    function showToast(msg, type) {
        var toast = document.getElementById('toast');
        if (!toast) return;
        toast.textContent = msg;
        toast.className = 'toast show ' + (type || '');
        setTimeout(function() { toast.classList.remove('show'); }, 3000);
    }

    function showModal(content) {
        var modal = document.getElementById('modal');
        if (!modal) return;
        document.getElementById('modalContent').innerHTML = content;
        modal.classList.add('show');
        if (global.lucide && global.lucide.createIcons) {
            global.lucide.createIcons();
        }
    }

    function closeModal() {
        var modal = document.getElementById('modal');
        if (modal) {
            modal.classList.remove('show');
        }
    }

    function createCard(title, icon, content, className) {
        return '<div class="card card-hover '+(className||'')+'"><div class="card-body">'+
               '<div class="section-title"><i data-lucide="'+icon+'" class="h-5 w-5"></i><h3>'+title+'</h3></div>'+
               content+'</div></div>';
    }

    function destroyCharts() {
        for (var k in global.AppState.charts) {
            if (Object.prototype.hasOwnProperty.call(global.AppState.charts, k)) {
                var chart = global.AppState.charts[k];
                if (chart && typeof chart.destroy === 'function') {
                    chart.destroy();
                }
            }
        }
        global.AppState.charts = {};
    }

    global.showToast = showToast;
    global.showModal = showModal;
    global.closeModal = closeModal;
    global.createCard = createCard;
    global.destroyCharts = destroyCharts;
})(window);
