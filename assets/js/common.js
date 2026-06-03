/**
 * 全局交互脚本 - 考勤薪资管理系统
 * 功能：加载动画、弹窗、Toast提示、表单验证、表格交互等
 */

// ===== 页面加载完成后初始化 =====
document.addEventListener('DOMContentLoaded', function() {
    initLoadingForms();
    initAutoHideAlerts();
    initTableExpandable();
    initTooltips();
    initConfirmButtons();
});

// ===== 加载动画：自动给所有 form 添加提交加载效果 =====
function initLoadingForms() {
    var forms = document.querySelectorAll('form');
    forms.forEach(function(form) {
        // 跳过搜索类表单（不需要加载动画）
        if (form.method && form.method.toLowerCase() === 'get') return;
        
        form.addEventListener('submit', function(e) {
            // 如果有 onclick 返回 false 的确认框，先不显示加载
            var btn = form.querySelector('button[type="submit"]');
            if (btn && btn.dataset.confirmed === 'false') return;
            
            showLoading('正在处理，请稍候...');
        });
    });
}

// ===== 自动隐藏提示消息 =====
function initAutoHideAlerts() {
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            alert.style.transition = 'opacity 0.5s, transform 0.5s';
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-10px)';
            setTimeout(function() {
                alert.style.display = 'none';
            }, 500);
        }, 4000);
    });
}

// ===== 表格可展开行 =====
function initTableExpandable() {
    var rows = document.querySelectorAll('.expandable-row');
    rows.forEach(function(row) {
        row.addEventListener('click', function() {
            var targetId = this.dataset.target;
            var detailRow = document.getElementById(targetId);
            if (detailRow) {
                this.classList.toggle('expanded');
                detailRow.classList.toggle('show');
            }
        });
    });
}

// ===== 工具提示初始化 =====
function initTooltips() {
    var tips = document.querySelectorAll('[data-tip]');
    tips.forEach(function(el) {
        el.classList.add('tooltip');
    });
}

// ===== 确认按钮增强 =====
function initConfirmButtons() {
    var btns = document.querySelectorAll('[data-confirm]');
    btns.forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            var msg = this.dataset.confirm;
            if (!confirm(msg)) {
                e.preventDefault();
                e.stopPropagation();
                this.dataset.confirmed = 'false';
            } else {
                this.dataset.confirmed = 'true';
            }
        });
    });
}

// ===== 显示全屏加载遮罩 =====
function showLoading(text) {
    text = text || '加载中...';
    var overlay = document.createElement('div');
    overlay.className = 'loading-overlay active';
    overlay.id = 'globalLoading';
    overlay.innerHTML = 
        '<div style="text-align:center;">' +
        '<div class="loading-spinner"></div>' +
        '<p style="margin-top:16px;color:#6b7280;font-size:14px;">' + text + '</p>' +
        '</div>';
    document.body.appendChild(overlay);
}

// ===== 隐藏加载遮罩 =====
function hideLoading() {
    var overlay = document.getElementById('globalLoading');
    if (overlay) {
        overlay.classList.remove('active');
        setTimeout(function() {
            if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
        }, 300);
    }
}

// ===== 显示 Toast 提示 =====
function showToast(message, type) {
    type = type || 'success';
    var container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }
    
    var icons = { success: '\2713', error: '\2717', warning: '\26A0', info: '\2139' };
    var toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.innerHTML = '<span style="font-size:18px;">' + (icons[type] || '') + '</span>' + message;
    container.appendChild(toast);
    
    setTimeout(function() {
        toast.style.transition = 'opacity 0.4s, transform 0.4s';
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(100%)';
        setTimeout(function() {
            if (toast.parentNode) toast.parentNode.removeChild(toast);
        }, 400);
    }, 3000);
}

// ===== 显示确认弹窗 =====
function showModal(title, message, onConfirm, onCancel) {
    var overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.id = 'confirmModal';
    overlay.innerHTML = 
        '<div class="modal-box">' +
        '<h3>' + (title || '\u786e\u8ba4\u64cd\u4f5c') + '</h3>' +
        '<p>' + message + '</p>' +
        '<div class="modal-actions">' +
        '<button class="btn btn-outline" id="modalCancel">\u53d6\u6d88</button>' +
        '<button class="btn btn-primary" id="modalConfirm">\u786e\u8ba4</button>' +
        '</div></div>';
    document.body.appendChild(overlay);
    
    document.getElementById('modalConfirm').addEventListener('click', function() {
        closeModal();
        if (onConfirm) onConfirm();
    });
    document.getElementById('modalCancel').addEventListener('click', function() {
        closeModal();
        if (onCancel) onCancel();
    });
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) {
            closeModal();
            if (onCancel) onCancel();
        }
    });
}

function closeModal() {
    var modal = document.getElementById('confirmModal');
    if (modal) {
        modal.classList.remove('active');
        setTimeout(function() {
            if (modal.parentNode) modal.parentNode.removeChild(modal);
        }, 300);
    }
}

// ===== 打印薪资条 =====
function printSalarySlip() {
    window.print();
}

// ===== 标签页切换 =====
function switchTab(tabId, paneId) {
    var tabs = document.querySelectorAll('.tab-nav .tab-item');
    tabs.forEach(function(t) { t.classList.remove('active'); });
    document.querySelector('[data-tab="' + tabId + '"]').classList.add('active');
    
    var panes = document.querySelectorAll('.tab-content .tab-pane');
    panes.forEach(function(p) { p.classList.remove('active'); });
    document.getElementById(paneId).classList.add('active');
}

// ===== 导出表格为 CSV =====
function exportTableToCSV(tableSelector, filename) {
    var table = document.querySelector(tableSelector);
    if (!table) return;
    
    var rows = table.querySelectorAll('tr');
    var csv = [];
    rows.forEach(function(row) {
        var cols = row.querySelectorAll('td, th');
        var rowData = [];
        cols.forEach(function(col) {
            rowData.push('"' + col.innerText.replace(/"/g, '""') + '"');
        });
        csv.push(rowData.join(','));
    });
    
    var blob = new Blob(['\ufeff' + csv.join('\n')], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename || 'export.csv';
    link.click();
}
