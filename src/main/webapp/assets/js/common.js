/**
 * 全局交互脚本 v3.0 - 考勤薪资管理系统
 *
 * 功能: 加载动画、弹窗、Toast提示、表单验证、
 *       CSRF自动注入、表格交互、导出、打印薪资条、
 *       Landing Page 交互
 */
(function () {
  'use strict';

  // ====== DOM Ready ======
  document.addEventListener('DOMContentLoaded', function () {
    initCsrfTokens();
    initLoadingForms();
    initAutoHideAlerts();
    initTableExpandable();
    initTooltips();
    initConfirmButtons();
    initDateDisplays();
  });

  // ====== CSRF Token 自动注入 ======
  function initCsrfTokens() {
    var token = getCsrfTokenFromMeta();
    if (!token) return;

    var forms = document.querySelectorAll('form[method="post"], form[method="POST"]');
    forms.forEach(function (form) {
      if (form.querySelector('input[name="_csrf"]')) return;
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = '_csrf';
      input.value = token;
      form.appendChild(input);
    });

    var origOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function () {
      origOpen.apply(this, arguments);
      this.setRequestHeader('X-CSRF-TOKEN', token);
    };
  }

  function getCsrfTokenFromMeta() {
    var meta = document.querySelector('meta[name="_csrf"]');
    return meta ? meta.getAttribute('content') : null;
  }

  // ====== 加载动画 ======
  function initLoadingForms() {
    var forms = document.querySelectorAll('form');
    forms.forEach(function (form) {
      if (form.method && form.method.toLowerCase() === 'get') return;
      if (form.id === 'searchForm') return;
      form.addEventListener('submit', function () {
        var btn = form.querySelector('button[type="submit"]');
        if (btn && btn.dataset.confirmed === 'false') return;
        showLoading('正在处理...');
      });
    });
  }

  // ====== 自动隐藏提示 ======
  function initAutoHideAlerts() {
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function (alert) {
      setTimeout(function () {
        alert.style.transition = 'opacity 0.4s, transform 0.4s';
        alert.style.opacity = '0';
        alert.style.transform = 'translateY(-8px)';
        setTimeout(function () {
          if (alert.parentNode) alert.style.display = 'none';
        }, 400);
      }, 5000);
    });
  }

  // ====== 日期显示 ======
  function initDateDisplays() {
    var el = document.getElementById('todayDate');
    if (!el) return;
    var now = new Date();
    var weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    el.textContent = now.getFullYear() + '年' + (now.getMonth() + 1) + '月' + now.getDate() + '日 ' + weekdays[now.getDay()];
  }

  // ====== 表格展开行 ======
  function initTableExpandable() {
    var rows = document.querySelectorAll('.expandable-row');
    rows.forEach(function (row) {
      row.addEventListener('click', function () {
        var targetId = this.dataset.target;
        var detailRow = document.getElementById(targetId);
        if (detailRow) {
          this.classList.toggle('expanded');
          detailRow.classList.toggle('show');
        }
      });
    });
  }

  // ====== 工具提示 ======
  function initTooltips() {
    var tips = document.querySelectorAll('[data-tip]');
    tips.forEach(function (el) { el.classList.add('tooltip'); });
  }

  // ====== 确认按钮 ======
  function initConfirmButtons() {
    var btns = document.querySelectorAll('[data-confirm]');
    btns.forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        if (!confirm(this.dataset.confirm)) {
          e.preventDefault();
          e.stopPropagation();
          this.dataset.confirmed = 'false';
        } else {
          this.dataset.confirmed = 'true';
        }
      });
    });
  }

  // ====== 加载遮罩 ======
  window.showLoading = function (text) {
    text = text || '加载中...';
    var existing = document.getElementById('globalLoading');
    if (existing) return;
    var overlay = document.createElement('div');
    overlay.className = 'loading-overlay active';
    overlay.id = 'globalLoading';
    overlay.innerHTML =
      '<div style="text-align:center;">' +
      '<div class="loading-spinner"></div>' +
      '<p style="margin-top:14px;color:#94a3b8;font-size:0.84rem;">' + text + '</p>' +
      '</div>';
    document.body.appendChild(overlay);
  };

  window.hideLoading = function () {
    var overlay = document.getElementById('globalLoading');
    if (!overlay) return;
    overlay.classList.remove('active');
    setTimeout(function () {
      if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
    }, 250);
  };

  // ====== Toast 提示 ======
  window.showToast = function (message, type) {
    type = type || 'success';
    var container = document.querySelector('.toast-container');
    if (!container) {
      container = document.createElement('div');
      container.className = 'toast-container';
      document.body.appendChild(container);
    }
    var icons = { success: '\u2713', error: '\u2717', warning: '\u26A0', info: '\u2139' };
    var toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.innerHTML = '<span style="font-size:1rem;">' + (icons[type] || '') + '</span>' + message;
    container.appendChild(toast);
    setTimeout(function () {
      toast.style.transition = 'opacity 0.35s, transform 0.35s';
      toast.style.opacity = '0';
      toast.style.transform = 'translateX(100%)';
      setTimeout(function () { if (toast.parentNode) toast.parentNode.removeChild(toast); }, 350);
    }, 3500);
  };

  // ====== 确认弹窗 ======
  window.showModal = function (title, message, onConfirm, onCancel) {
    var overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.id = 'confirmModal';
    overlay.innerHTML =
      '<div class="modal-box">' +
      '<h3>' + (title || '确认操作') + '</h3>' +
      '<p>' + message + '</p>' +
      '<div class="modal-actions">' +
      '<button class="btn btn-outline" id="modalCancel">取消</button>' +
      '<button class="btn btn-primary" id="modalConfirm">确认</button>' +
      '</div></div>';
    document.body.appendChild(overlay);
    document.getElementById('modalConfirm').addEventListener('click', function () {
      closeModal();
      if (onConfirm) onConfirm();
    });
    document.getElementById('modalCancel').addEventListener('click', function () {
      closeModal();
      if (onCancel) onCancel();
    });
    overlay.addEventListener('click', function (e) {
      if (e.target === overlay) { closeModal(); if (onCancel) onCancel(); }
    });
  };

  function closeModal() {
    var modal = document.getElementById('confirmModal');
    if (!modal) return;
    modal.classList.remove('active');
    setTimeout(function () { if (modal.parentNode) modal.parentNode.removeChild(modal); }, 250);
  }

  // ====== 打印薪资条 ======
  window.printSalarySlip = function () {
    var content = document.getElementById('slipContent');
    if (!content) { window.print(); return; }
    var win = window.open('', '_blank', 'width=600,height=600');
    win.document.write('<html><head><meta charset="UTF-8"><title>薪资条</title>');
    win.document.write('<style>');
    win.document.write('*{margin:0;padding:0;box-sizing:border-box}');
    win.document.write('body{font-family:"PingFang SC","Microsoft YaHei",sans-serif;padding:20px;color:#0f172a}');
    win.document.write('.salary-slip{max-width:500px;margin:0 auto;border:2px solid #38bdf8;border-radius:12px;overflow:hidden}');
    win.document.write('.salary-slip-header{background:linear-gradient(135deg,#3b82f6,#06b6d4);color:#fff;padding:24px;text-align:center}');
    win.document.write('.salary-slip-header h2{font-size:20px;margin-bottom:4px}');
    win.document.write('.salary-slip-header p{font-size:13px;opacity:.8}');
    win.document.write('.salary-slip-body{padding:24px}');
    win.document.write('.salary-slip-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px dashed #e2e8f0;font-size:14px}');
    win.document.write('.salary-slip-row .label{color:#475569}');
    win.document.write('.salary-slip-row .value{font-weight:600}');
    win.document.write('.salary-slip-row.total{border-bottom:none;border-top:2px solid #38bdf8;margin-top:8px;padding-top:14px}');
    win.document.write('.salary-slip-row.total .value{font-size:18px;color:#059669}');
    win.document.write('.salary-slip-footer{text-align:center;padding:14px;background:#f8fafc;font-size:12px;color:#94a3b8}');
    win.document.write('@page{size:auto;margin:0}');
    win.document.write('</style></head><body>');
    win.document.write(content.innerHTML);
    win.document.write('</body></html>');
    win.document.close();
    win.focus();
    setTimeout(function () { win.print(); win.close(); }, 500);
  };

  // ====== Tab 切换 ======
  window.switchTab = function (tabId, paneId) {
    var tabs = document.querySelectorAll('.tab-nav .tab-item');
    tabs.forEach(function (t) { t.classList.remove('active'); });
    var tabEl = document.querySelector('[data-tab="' + tabId + '"]');
    if (tabEl) tabEl.classList.add('active');
    var panes = document.querySelectorAll('.tab-content .tab-pane');
    panes.forEach(function (p) { p.classList.remove('active'); });
    var paneEl = document.getElementById(paneId);
    if (paneEl) paneEl.classList.add('active');
  };

  // ====== 导出 CSV ======
  window.exportTableToCSV = function (tableSelector, filename) {
    var table = document.querySelector(tableSelector);
    if (!table) return;
    var rows = table.querySelectorAll('tr');
    var csv = [];
    rows.forEach(function (row) {
      var cols = row.querySelectorAll('td, th');
      var rowData = [];
      cols.forEach(function (col) {
        rowData.push('"' + col.innerText.replace(/"/g, '""') + '"');
      });
      csv.push(rowData.join(','));
    });
    var blob = new Blob(['\ufeff' + csv.join('\n')], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename || 'export.csv';
    link.click();
  };
})();
