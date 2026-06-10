<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>考勤记录 - 小程序</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --bg-start: #f0f4ff;
            --bg-mid: #faf5ff;
            --bg-end: #f0f9ff;
            --card-bg: rgba(255,255,255,0.92);
            --text: #1e293b;
            --text-secondary: #64748b;
            --border: rgba(124,58,237,0.08);
            --brand: #7c3aed;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --radius: 16px;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: linear-gradient(135deg, var(--bg-start) 0%, var(--bg-mid) 50%, var(--bg-end) 100%);
            color: var(--text);
            min-height: 100vh;
            padding-bottom: 80px;
            -webkit-tap-highlight-color: transparent;
        }

        .header {
            background: rgba(255,255,255,0.88);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: 1px solid var(--border);
            color: var(--text);
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            position: sticky;
            top: 0;
            z-index: 100;
            padding-top: max(16px, env(safe-area-inset-top));
        }
        .header .back-btn {
            color: var(--brand);
            text-decoration: none;
            font-size: 22px;
            padding: 4px 8px;
            border-radius: 8px;
        }
        .header .back-btn:active { background: rgba(124,58,237,0.06); }
        .header .title {
            font-size: 17px;
            font-weight: 700;
            color: var(--text);
        }

        .container {
            max-width: 480px;
            margin: 0 auto;
            padding: 16px;
        }

        .month-picker {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 14px 20px;
            margin-bottom: 16px;
        }
        .month-picker .arrow-btn {
            width: 36px;
            height: 36px;
            border: 1px solid rgba(124,58,237,0.15);
            background: rgba(124,58,237,0.04);
            border-radius: 50%;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text);
            transition: all 0.2s;
        }
        .month-picker .arrow-btn:active {
            background: rgba(124,58,237,0.1);
            border-color: var(--brand);
        }
        .month-picker .month-label {
            font-size: 18px;
            font-weight: 700;
            min-width: 120px;
            text-align: center;
            color: var(--text);
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 8px;
            margin-bottom: 16px;
        }
        .stat-mini {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 8px;
            text-align: center;
        }
        .stat-mini .stat-num {
            font-size: 22px;
            font-weight: 700;
            line-height: 1;
        }
        .stat-mini .stat-num.green { color: var(--success); }
        .stat-mini .stat-num.amber { color: var(--warning); }
        .stat-mini .stat-num.red { color: var(--danger); }
        .stat-mini .stat-num.blue { color: #3b82f6; }
        .stat-mini .stat-text {
            font-size: 11px;
            color: var(--text-secondary);
            margin-top: 4px;
        }

        .record-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .record-item {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: all 0.2s;
        }
        .record-item:active { background: rgba(124,58,237,0.04); }
        .record-item .date-badge {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-weight: 700;
        }
        .date-badge.normal { background: rgba(16,185,129,0.12); color: #059669; }
        .date-badge.late { background: rgba(245,158,11,0.12); color: #d97706; }
        .date-badge.early { background: rgba(245,158,11,0.12); color: #d97706; }
        .date-badge.absent { background: rgba(239,68,68,0.12); color: #dc2626; }
        .date-badge .date-day {
            font-size: 20px;
            line-height: 1;
        }
        .date-badge .date-week {
            font-size: 10px;
            opacity: 0.7;
        }
        .record-info {
            flex: 1;
            min-width: 0;
        }
        .record-info .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 13px;
            margin-bottom: 3px;
        }
        .record-info .info-label {
            color: var(--text-secondary);
            font-size: 12px;
        }
        .record-info .info-value {
            font-weight: 600;
            font-size: 13px;
            color: var(--text);
        }
        .record-info .info-value.time {
            font-family: 'SF Mono', 'Menlo', monospace;
        }
        .status-tag {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        .status-tag.normal { background: rgba(16,185,129,0.1); color: #059669; }
        .status-tag.late { background: rgba(245,158,11,0.1); color: #d97706; }
        .status-tag.early { background: rgba(251,191,36,0.1); color: #b45309; }
        .status-tag.absent { background: rgba(239,68,68,0.1); color: #dc2626; }

        .empty-state {
            text-align: center;
            padding: 48px 20px;
            color: var(--text-secondary);
        }
        .empty-state .empty-icon { font-size: 48px; margin-bottom: 12px; }
        .empty-state p { font-size: 15px; }

        .page-nav {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            padding: 20px 0;
        }
        .page-nav .page-btn {
            padding: 10px 20px;
            border: 1px solid var(--border);
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-radius: 24px;
            font-size: 14px;
            font-weight: 600;
            color: var(--brand);
            cursor: pointer;
            transition: all 0.2s;
        }
        .page-nav .page-btn:active {
            background: rgba(124,58,237,0.08);
            border-color: var(--brand);
        }
        .page-nav .page-btn:disabled {
            color: #94a3b8;
            border-color: rgba(124,58,237,0.04);
            background: rgba(255,255,255,0.5);
            cursor: not-allowed;
        }
        .page-nav .page-info {
            font-size: 13px;
            color: var(--text-secondary);
            font-weight: 500;
        }
        .page-nav .page-info strong {
            color: var(--text);
        }

        .bottom-nav {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(255,255,255,0.9);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            display: flex;
            border-top: 1px solid var(--border);
            z-index: 99;
            padding-bottom: env(safe-area-inset-bottom);
        }
        .bottom-nav .nav-item {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 10px 0;
            text-decoration: none;
            color: #94a3b8;
            font-size: 11px;
            transition: all 0.2s;
            gap: 4px;
        }
        .bottom-nav .nav-item.active { color: var(--brand); }
        .bottom-nav .nav-item .nav-icon { font-size: 22px; }

        .toast {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%) translateY(-120px);
            padding: 14px 28px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            color: #fff;
            z-index: 9999;
            transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
            white-space: nowrap;
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }

        .overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9998;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s;
        }
        .overlay.show { opacity: 1; pointer-events: all; }
        .overlay .loader {
            width: 48px;
            height: 48px;
            border: 3px solid rgba(124,58,237,0.15);
            border-top-color: var(--brand);
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>

<div class="header">
    <a href="${pageContext.request.contextPath}/miniapp?action=clock" class="back-btn">←</a>
    <div class="title">📋 考勤记录</div>
</div>

<div class="toast" id="toast"></div>
<div class="overlay" id="overlay"><div class="loader"></div></div>

<div class="container">
    <div class="month-picker">
        <button class="arrow-btn" onclick="prevMonth()">◀</button>
        <div class="month-label" id="monthLabel">2026年6月</div>
        <button class="arrow-btn" onclick="nextMonth()">▶</button>
    </div>

    <div class="stats-row">
        <div class="stat-mini">
            <div class="stat-num green" id="statNormal">0</div>
            <div class="stat-text">正常</div>
        </div>
        <div class="stat-mini">
            <div class="stat-num amber" id="statLate">0</div>
            <div class="stat-text">迟到</div>
        </div>
        <div class="stat-mini">
            <div class="stat-num amber" id="statEarly">0</div>
            <div class="stat-text">早退</div>
        </div>
        <div class="stat-mini">
            <div class="stat-num red" id="statAbsent">0</div>
            <div class="stat-text">缺勤</div>
        </div>
    </div>

    <div class="record-list" id="recordList">
        <div class="empty-state">
            <div class="empty-icon">📋</div>
            <p>加载中...</p>
        </div>
    </div>

    <div class="page-nav" id="pageNav" style="display:none;">
        <button class="page-btn" id="prevBtn" onclick="goPage(currentPage - 1)">上一页</button>
        <span class="page-info" id="pageInfo"></span>
        <button class="page-btn" id="nextBtn" onclick="goPage(currentPage + 1)">下一页</button>
    </div>
</div>

<div class="bottom-nav">
    <a href="${pageContext.request.contextPath}/miniapp?action=clock" class="nav-item">
        <span class="nav-icon">🏠</span>
        打卡
    </a>
    <a href="${pageContext.request.contextPath}/miniapp?action=records" class="nav-item active">
        <span class="nav-icon">📋</span>
        记录
    </a>
    <a href="${pageContext.request.contextPath}/miniapp?action=my" class="nav-item">
        <span class="nav-icon">👤</span>
        我的
    </a>
</div>

<script>
    const ctxPath = '${pageContext.request.contextPath}';
    let currentYearMonth = '';
    let currentPage = 1;
    let totalPages = 1;
    const weekdays = ['日','一','二','三','四','五','六'];

    function showToast(msg, type) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.className = 'toast ' + (type || 'info');
        requestAnimationFrame(() => toast.classList.add('show'));
        setTimeout(() => toast.classList.remove('show'), 2500);
    }

    function showLoading() { document.getElementById('overlay').classList.add('show'); }
    function hideLoading() { document.getElementById('overlay').classList.remove('show'); }

    function loadRecords(yearMonth, page) {
        showLoading();
        page = page || 1;
        fetch(ctxPath + '/miniapp?action=monthRecords&yearMonth=' + yearMonth + '&page=' + page)
            .then(r => r.json())
            .then(data => {
                hideLoading();
                if (data.needLogin) {
                    window.location.href = ctxPath + '/miniapp';
                    return;
                }
                if (data.success) {
                    currentPage = data.currentPage || 1;
                    totalPages = data.totalPages || 1;
                    renderRecords(data);
                } else {
                    showToast('加载失败', 'error');
                }
            })
            .catch(err => {
                hideLoading();
                showToast('网络错误', 'error');
            });
    }

    function renderRecords(data) {
        const s = data.stats || {};
        document.getElementById('statNormal').textContent = s.normalDays || 0;
        document.getElementById('statLate').textContent = s.lateDays || 0;
        document.getElementById('statEarly').textContent = s.earlyDays || 0;
        document.getElementById('statAbsent').textContent = s.absentDays || 0;

        const list = document.getElementById('recordList');
        const records = data.records || [];

        if (records.length === 0) {
            list.innerHTML = '<div class="empty-state"><div class="empty-icon">📭</div><p>该月暂无考勤记录</p></div>';
            document.getElementById('pageNav').style.display = 'none';
            return;
        }

        let html = '';
        records.forEach(r => {
            var date = new Date(r.workDate + 'T00:00:00');
            var day = date.getDate();
            var week = weekdays[date.getDay()];
            var status = r.status || '正常';
            var statusClass = status === '正常' ? 'normal' :
                              status === '迟到' ? 'late' :
                              status === '早退' ? 'early' : 'absent';

            var inTime = r.checkInTime;
            var outTime = r.checkOutTime;
            if (typeof inTime !== 'string' || inTime === 'false' || inTime === 'null') inTime = '--:--:--';
            if (typeof outTime !== 'string' || outTime === 'false' || outTime === 'null') outTime = '--:--:--';

            var hours = r.workHours;
            var hoursStr = '--';
            if (hours != null && hours !== '' && hours !== false && hours !== 'false') {
                hoursStr = hours + 'h';
            }

            html += '<div class="record-item">' +
                '<div class="date-badge ' + statusClass + '">' +
                    '<span class="date-day">' + day + '</span>' +
                    '<span class="date-week">周' + week + '</span>' +
                '</div>' +
                '<div class="record-info">' +
                    '<div class="info-row">' +
                        '<span class="info-label">上班</span>' +
                        '<span class="info-value time">' + inTime + '</span>' +
                    '</div>' +
                    '<div class="info-row">' +
                        '<span class="info-label">下班</span>' +
                        '<span class="info-value time">' + outTime + '</span>' +
                    '</div>' +
                    '<div class="info-row">' +
                        '<span class="info-label">工时</span>' +
                        '<span class="info-value">' + hoursStr + '</span>' +
                        '<span class="status-tag ' + statusClass + '">' + status + '</span>' +
                    '</div>' +
                '</div>' +
            '</div>';
        });
        list.innerHTML = html;
        renderPageNav(data);
    }

    function renderPageNav(data) {
        var nav = document.getElementById('pageNav');
        if (totalPages <= 1) {
            nav.style.display = 'none';
            return;
        }
        nav.style.display = 'flex';
        document.getElementById('pageInfo').innerHTML = '共 <strong>' + (data.totalCount || 0) + '</strong> 条，第 <strong>' + currentPage + '</strong>/<strong>' + totalPages + '</strong> 页';
        document.getElementById('prevBtn').disabled = (currentPage <= 1);
        document.getElementById('nextBtn').disabled = (currentPage >= totalPages);
    }

    function goPage(p) {
        if (p < 1 || p > totalPages) return;
        loadRecords(currentYearMonth, p);
    }

    function prevMonth() {
        const parts = currentYearMonth.split('-');
        let y = parseInt(parts[0]);
        let m = parseInt(parts[1]) - 1;
        if (m < 1) { m = 12; y--; }
        currentYearMonth = y + '-' + String(m).padStart(2, '0');
        currentPage = 1;
        updateMonthLabel();
        loadRecords(currentYearMonth, 1);
    }

    function nextMonth() {
        const parts = currentYearMonth.split('-');
        let y = parseInt(parts[0]);
        let m = parseInt(parts[1]) + 1;
        if (m > 12) { m = 1; y++; }
        currentYearMonth = y + '-' + String(m).padStart(2, '0');
        currentPage = 1;
        updateMonthLabel();
        loadRecords(currentYearMonth, 1);
    }

    function updateMonthLabel() {
        const parts = currentYearMonth.split('-');
        document.getElementById('monthLabel').textContent = parts[0] + '年' + parseInt(parts[1]) + '月';
    }

    document.addEventListener('DOMContentLoaded', function() {
        const now = new Date();
        currentYearMonth = now.getFullYear() + '-' + String(now.getMonth()+1).padStart(2, '0');
        currentPage = 1;
        updateMonthLabel();
        loadRecords(currentYearMonth, 1);
    });
</script>
</body>
</html>
