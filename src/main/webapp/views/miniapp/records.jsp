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
            --primary: #1a73e8;
            --success: #0d9e6c;
            --warning: #f0a020;
            --danger: #dc3545;
            --bg: #f0f2f5;
            --card-bg: #ffffff;
            --text: #1f2937;
            --text-secondary: #6b7280;
            --border: #e5e7eb;
            --radius: 16px;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            padding-bottom: 80px;
            -webkit-tap-highlight-color: transparent;
        }

        .header {
            background: linear-gradient(135deg, #1e3a5f 0%, #2980b9 100%);
            color: #fff;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
            padding-top: max(16px, env(safe-area-inset-top));
        }
        .header .back-btn {
            color: #fff;
            text-decoration: none;
            font-size: 22px;
            padding: 4px 8px;
            border-radius: 8px;
        }
        .header .back-btn:active { background: rgba(255,255,255,0.15); }
        .header .title {
            font-size: 17px;
            font-weight: 700;
        }

        .container {
            max-width: 480px;
            margin: 0 auto;
            padding: 16px;
        }

        /* 月份选择器 */
        .month-picker {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 14px 20px;
            margin-bottom: 16px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .month-picker .arrow-btn {
            width: 36px;
            height: 36px;
            border: 1.5px solid var(--border);
            background: #fff;
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
            background: #f0f2f5;
            border-color: var(--primary);
        }
        .month-picker .month-label {
            font-size: 18px;
            font-weight: 700;
            min-width: 120px;
            text-align: center;
        }

        /* 统计 */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 8px;
            margin-bottom: 16px;
        }
        .stat-mini {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 14px 8px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .stat-mini .stat-num {
            font-size: 22px;
            font-weight: 700;
            line-height: 1;
        }
        .stat-mini .stat-num.green { color: var(--success); }
        .stat-mini .stat-num.amber { color: var(--warning); }
        .stat-mini .stat-num.red { color: var(--danger); }
        .stat-mini .stat-num.blue { color: var(--primary); }
        .stat-mini .stat-text {
            font-size: 11px;
            color: var(--text-secondary);
            margin-top: 4px;
        }

        /* 记录列表 */
        .record-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .record-item {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 16px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
            display: flex;
            align-items: center;
            gap: 14px;
            transition: all 0.2s;
        }
        .record-item:active { background: #f8fafc; }
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
        .date-badge.normal { background: #d1fae5; color: #065f46; }
        .date-badge.late { background: #fef3c7; color: #92400e; }
        .date-badge.early { background: #fef3c7; color: #92400e; }
        .date-badge.absent { background: #fee2e2; color: #991b1b; }
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
        .status-tag.normal { background: #d1fae5; color: #065f46; }
        .status-tag.late { background: #fef3c7; color: #92400e; }
        .status-tag.early { background: #fde68a; color: #92400e; }
        .status-tag.absent { background: #fee2e2; color: #991b1b; }

        .empty-state {
            text-align: center;
            padding: 48px 20px;
            color: #9ca3af;
        }
        .empty-state .empty-icon { font-size: 48px; margin-bottom: 12px; }
        .empty-state p { font-size: 15px; }

        /* 分页导航 */
        .page-nav {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            padding: 20px 0;
        }
        .page-nav .page-btn {
            padding: 10px 20px;
            border: 1.5px solid var(--border);
            background: var(--card-bg);
            border-radius: 24px;
            font-size: 14px;
            font-weight: 600;
            color: var(--primary);
            cursor: pointer;
            transition: all 0.2s;
        }
        .page-nav .page-btn:active {
            background: #e8f0fe;
            border-color: var(--primary);
        }
        .page-nav .page-btn:disabled {
            color: #c0c4cc;
            border-color: #e5e7eb;
            background: #f8f9fa;
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

        /* 底部导航 */
        .bottom-nav {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: var(--card-bg);
            display: flex;
            border-top: 1px solid var(--border);
            z-index: 99;
            padding-bottom: env(safe-area-inset-bottom);
            box-shadow: 0 -2px 12px rgba(0,0,0,0.04);
        }
        .bottom-nav .nav-item {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 10px 0;
            text-decoration: none;
            color: var(--text-secondary);
            font-size: 11px;
            transition: all 0.2s;
            gap: 4px;
        }
        .bottom-nav .nav-item.active { color: var(--primary); }
        .bottom-nav .nav-item .nav-icon { font-size: 22px; }

        /* Toast */
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
            border: 4px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
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
    <!-- 月份选择 -->
    <div class="month-picker">
        <button class="arrow-btn" onclick="prevMonth()">◀</button>
        <div class="month-label" id="monthLabel">2026年6月</div>
        <button class="arrow-btn" onclick="nextMonth()">▶</button>
    </div>

    <!-- 统计 -->
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

    <!-- 记录列表 -->
    <div class="record-list" id="recordList">
        <div class="empty-state">
            <div class="empty-icon">📋</div>
            <p>加载中...</p>
        </div>
    </div>

    <!-- 分页导航 -->
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
        // 更新统计
        const s = data.stats || {};
        document.getElementById('statNormal').textContent = s.normalDays || 0;
        document.getElementById('statLate').textContent = s.lateDays || 0;
        document.getElementById('statEarly').textContent = s.earlyDays || 0;
        document.getElementById('statAbsent').textContent = s.absentDays || 0;

        // 渲染列表
        const list = document.getElementById('recordList');
        const records = data.records || [];

        if (records.length === 0) {
            list.innerHTML = '<div class="empty-state"><div class="empty-icon">📭</div><p>该月暂无考勤记录</p></div>';
            // 无记录时也隐藏分页
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

            // 处理打卡时间：只接受字符串格式的时间，其他值显示为 '--:--:--'
            var inTime = r.checkInTime;
            var outTime = r.checkOutTime;
            if (typeof inTime !== 'string' || inTime === 'false' || inTime === 'null') inTime = '--:--:--';
            if (typeof outTime !== 'string' || outTime === 'false' || outTime === 'null') outTime = '--:--:--';

            // 处理工时
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

        // 渲染分页导航
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

    // 初始化
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
