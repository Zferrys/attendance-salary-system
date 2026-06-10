<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <title>考勤打卡 - 小程序</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --primary: #7c3aed;
            --primary-dark: #6d28d9;
            --primary-light: #8b5cf6;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --info: #3b82f6;
            --bg-start: #f0f4ff;
            --bg-mid: #faf5ff;
            --bg-end: #f0f9ff;
            --card-bg: rgba(255,255,255,0.92);
            --card-border: rgba(124,58,237,0.08);
            --text: #1e293b;
            --text-secondary: #64748b;
            --text-muted: #94a3b8;
            --radius: 16px;
            --radius-sm: 12px;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: linear-gradient(135deg, var(--bg-start) 0%, var(--bg-mid) 50%, var(--bg-end) 100%);
            color: var(--text);
            min-height: 100vh;
            padding-bottom: 80px;
            -webkit-tap-highlight-color: transparent;
            user-select: none;
            -webkit-user-select: none;
        }

        .header {
            background: rgba(255,255,255,0.88);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            color: var(--text);
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
            border-bottom: 1px solid rgba(124,58,237,0.08);
            padding-top: max(16px, env(safe-area-inset-top));
        }
        .header .title {
            font-size: 17px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text);
        }
        .header .user-badge {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--text-secondary);
        }
        .header .logout-btn {
            background: rgba(124,58,237,0.06);
            border: 1px solid rgba(124,58,237,0.15);
            color: var(--primary);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }
        .header .logout-btn:active { background: rgba(124,58,237,0.12); }

        .container { max-width: 480px; margin: 0 auto; padding: 16px; }

        .clock-card {
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 32px 24px;
            text-align: center;
            box-shadow: 0 4px 24px rgba(99,102,241,0.06), 0 0 40px rgba(124,58,237,0.04);
            margin-bottom: 16px;
            border: 1px solid var(--card-border);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }
        .clock-card .live-time {
            font-size: 56px;
            font-weight: 700;
            color: var(--text);
            font-family: 'SF Mono', 'Menlo', 'Courier New', monospace;
            letter-spacing: 2px;
            line-height: 1.1;
        }
        .clock-card .live-date {
            font-size: 15px;
            color: var(--text-secondary);
            margin-top: 8px;
        }
        .clock-card .greeting {
            font-size: 14px;
            color: var(--text-muted);
            margin-top: 4px;
        }

        .clock-status { display: flex; gap: 12px; margin-bottom: 16px; }
        .clock-status .status-item {
            flex: 1;
            background: var(--card-bg);
            border-radius: var(--radius-sm);
            padding: 16px;
            text-align: center;
            box-shadow: 0 2px 12px rgba(99,102,241,0.04);
            border: 1px solid var(--card-border);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }
        .status-item .status-icon { font-size: 28px; margin-bottom: 6px; }
        .status-item .status-label { font-size: 12px; color: var(--text-secondary); margin-bottom: 4px; }
        .status-item .status-time { font-size: 15px; font-weight: 600; color: var(--text); }
        .status-item.done {
            border-color: rgba(16,185,129,0.3);
            background: rgba(16,185,129,0.05);
        }
        .status-item.pending { border-color: var(--card-border); }

        .clock-buttons { display: flex; gap: 12px; margin-bottom: 16px; }
        .clock-btn {
            flex: 1;
            padding: 20px;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            color: #fff;
            transition: all 0.25s;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            position: relative;
            overflow: hidden;
        }
        .clock-btn::after {
            content: '';
            position: absolute;
            inset: 0;
            background: rgba(255,255,255,0);
            transition: background 0.25s;
        }
        .clock-btn:active::after { background: rgba(255,255,255,0.15); }
        .clock-btn:active { transform: scale(0.96); }
        .clock-btn .btn-icon { font-size: 32px; }
        .clock-btn .btn-label { font-size: 13px; opacity: 0.9; }
        .clock-btn.in-btn {
            background: linear-gradient(135deg, #7c3aed, #3b82f6);
            box-shadow: 0 4px 16px rgba(124,58,237,0.3);
        }
        .clock-btn.out-btn {
            background: linear-gradient(135deg, #10b981, #059669);
            box-shadow: 0 4px 16px rgba(16,185,129,0.3);
        }
        .clock-btn:disabled {
            background: #cbd5e1 !important;
            box-shadow: none !important;
            cursor: not-allowed;
            opacity: 0.6;
        }
        .clock-btn.loading { pointer-events: none; opacity: 0.7; }
        .clock-btn .spinner {
            display: none;
            width: 24px; height: 24px;
            border: 3px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
        }
        .clock-btn.loading .spinner { display: block; }
        .clock-btn.loading .btn-icon { display: none; }
        .clock-btn.loading .btn-label { display: none; }

        .stats-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 16px; }
        .stat-mini {
            background: var(--card-bg);
            border-radius: var(--radius-sm);
            padding: 16px 12px;
            text-align: center;
            box-shadow: 0 2px 12px rgba(99,102,241,0.04);
            border: 1px solid var(--card-border);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }
        .stat-mini .stat-num { font-size: 26px; font-weight: 700; line-height: 1; }
        .stat-mini .stat-num.green { color: var(--success); }
        .stat-mini .stat-num.amber { color: var(--warning); }
        .stat-mini .stat-num.red { color: var(--danger); }
        .stat-mini .stat-text { font-size: 12px; color: var(--text-secondary); margin-top: 4px; }

        .action-links { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 16px; }
        .action-link {
            background: var(--card-bg);
            border-radius: var(--radius-sm);
            padding: 16px 10px;
            text-align: center;
            text-decoration: none;
            color: var(--text);
            box-shadow: 0 2px 12px rgba(99,102,241,0.04);
            border: 1px solid var(--card-border);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            transition: all 0.2s;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 500;
        }
        .action-link:active {
            transform: scale(0.95);
            background: rgba(124,58,237,0.05);
            border-color: rgba(124,58,237,0.25);
        }

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
            max-width: 90vw;
            text-align: center;
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }
        .toast.warning { background: var(--warning); color: #1e293b; }
        .toast.info { background: var(--info); }

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
            width: 48px; height: 48px;
            border: 4px solid rgba(124,58,237,0.15);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        .bottom-nav {
            position: fixed;
            bottom: 0; left: 0; right: 0;
            background: rgba(255,255,255,0.9);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            display: flex;
            border-top: 1px solid rgba(124,58,237,0.08);
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
            color: var(--text-muted);
            font-size: 11px;
            transition: all 0.2s;
            gap: 4px;
        }
        .bottom-nav .nav-item.active { color: var(--primary); }
        .bottom-nav .nav-item .nav-icon { font-size: 22px; }

        @keyframes successPulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.08); }
            100% { transform: scale(1); }
        }
        .clock-card.success-anim {
            animation: successPulse 0.5s ease;
            background: rgba(16,185,129,0.06);
            border-color: rgba(16,185,129,0.25);
        }

        @media (max-width: 360px) {
            .clock-card .live-time { font-size: 44px; }
            .clock-btn { padding: 16px; font-size: 16px; }
            .clock-btn .btn-icon { font-size: 26px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="title">&#9201;&#65039; 考勤打卡</div>
    <div class="user-badge">
        <span id="headerUserName">${user.name}</span>
        <button class="logout-btn" onclick="doLogout()">退出</button>
    </div>
</div>

<div class="toast" id="toast"></div>
<div class="overlay" id="overlay"><div class="loader"></div></div>

<div class="container">
    <div class="clock-card" id="clockCard">
        <div class="live-time" id="liveTime">00:00:00</div>
        <div class="live-date" id="liveDate">--</div>
        <div class="greeting" id="greeting">--</div>
    </div>

    <div class="clock-status">
        <div class="status-item pending" id="statusIn">
            <div class="status-icon">&#127748;</div>
            <div class="status-label">上班打卡</div>
            <div class="status-time" id="inTime">未打卡</div>
        </div>
        <div class="status-item pending" id="statusOut">
            <div class="status-icon">&#127751;</div>
            <div class="status-label">下班打卡</div>
            <div class="status-time" id="outTime">未打卡</div>
        </div>
    </div>

    <div class="clock-buttons">
        <button class="clock-btn in-btn" id="btnClockIn" onclick="clockIn()">
            <span class="btn-icon">&#9728;&#65039;</span><span class="btn-label">上班打卡</span><span class="spinner"></span>
        </button>
        <button class="clock-btn out-btn" id="btnClockOut" onclick="clockOut()">
            <span class="btn-icon">&#127769;</span><span class="btn-label">下班打卡</span><span class="spinner"></span>
        </button>
    </div>

    <div class="stats-row" id="monthStats">
        <div class="stat-mini"><div class="stat-num green" id="statNormal">0</div><div class="stat-text">正常出勤</div></div>
        <div class="stat-mini"><div class="stat-num amber" id="statLate">0</div><div class="stat-text">迟到/早退</div></div>
        <div class="stat-mini"><div class="stat-num red" id="statAbsent">0</div><div class="stat-text">缺勤</div></div>
    </div>

    <div class="action-links">
        <a href="${pageContext.request.contextPath}/miniapp?action=records" class="action-link"><span class="link-icon">&#128203;</span>考勤记录</a>
        <a href="${pageContext.request.contextPath}/miniapp?action=leaveApply" class="action-link"><span class="link-icon">&#128221;</span>请假申请</a>
        <a href="${pageContext.request.contextPath}/miniapp?action=salary" class="action-link"><span class="link-icon">&#128176;</span>薪资查询</a>
    </div>
</div>

<div class="bottom-nav">
    <a href="${pageContext.request.contextPath}/miniapp?action=clock" class="nav-item active"><span class="nav-icon">&#127968;</span>打卡</a>
    <a href="${pageContext.request.contextPath}/miniapp?action=records" class="nav-item"><span class="nav-icon">&#128203;</span>记录</a>
    <a href="${pageContext.request.contextPath}/miniapp?action=my" class="nav-item"><span class="nav-icon">&#128100;</span>我的</a>
</div>

<script>
    const ctxPath = '${pageContext.request.contextPath}';
    let todayStatus = { hasCheckedIn: false, hasCheckedOut: false };

    function updateClock() {
        const now = new Date();
        document.getElementById('liveTime').textContent =
            String(now.getHours()).padStart(2, '0') + ':' +
            String(now.getMinutes()).padStart(2, '0') + ':' +
            String(now.getSeconds()).padStart(2, '0');
        const weekdays = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
        document.getElementById('liveDate').textContent =
            now.getFullYear() + '年' + (now.getMonth()+1) + '月' + now.getDate() + '日 ' + weekdays[now.getDay()];
        const hour = now.getHours();
        document.getElementById('greeting').innerHTML =
            hour < 6 ? '夜深了，注意休息 🌙' :
            hour < 9 ? '早上好！新的一天 ☀️' :
            hour < 12 ? '上午好！工作顺利 📊' :
            hour < 14 ? '中午好！记得休息 🍜' :
            hour < 18 ? '下午好！继续加油 💪' :
            hour < 21 ? '晚上好！辛苦了 🌇' : '夜深了，早点休息 🌙';
        updateButtonStates();
    }

    function updateButtonStates() {
        const btnIn = document.getElementById('btnClockIn');
        const btnOut = document.getElementById('btnClockOut');
        if (todayStatus.hasCheckedIn && todayStatus.hasCheckedOut) {
            btnIn.disabled = true; btnOut.disabled = true;
            btnIn.innerHTML = '<span class="btn-icon">&#9989;</span><span class="btn-label">已完成</span><span class="spinner"></span>';
            btnOut.innerHTML = '<span class="btn-icon">&#9989;</span><span class="btn-label">已完成</span><span class="spinner"></span>';
        } else if (todayStatus.hasCheckedIn) {
            btnIn.disabled = true;
            btnIn.innerHTML = '<span class="btn-icon">&#9989;</span><span class="btn-label">已打卡</span><span class="spinner"></span>';
            btnOut.disabled = false;
        } else {
            btnIn.disabled = false; btnOut.disabled = false;
        }
    }

    setInterval(updateClock, 1000);
    updateClock();

    let toastTimer;
    function showToast(msg, type) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.className = 'toast ' + (type || 'info');
        clearTimeout(toastTimer);
        requestAnimationFrame(() => toast.classList.add('show'));
        toastTimer = setTimeout(() => toast.classList.remove('show'), 2500);
    }

    function showLoading() { document.getElementById('overlay').classList.add('show'); }
    function hideLoading() { document.getElementById('overlay').classList.remove('show'); }

    function loadTodayStatus() {
        fetch(ctxPath + '/miniapp?action=todayStatus')
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    todayStatus = data;
                    const statusIn = document.getElementById('statusIn');
                    const inTime = document.getElementById('inTime');
                    if (data.hasCheckedIn) {
                        statusIn.className = 'status-item done';
                        inTime.textContent = data.checkInTime || '已打卡';
                    } else {
                        statusIn.className = 'status-item pending';
                        inTime.textContent = '未打卡';
                    }
                    const statusOut = document.getElementById('statusOut');
                    const outTime = document.getElementById('outTime');
                    if (data.hasCheckedOut) {
                        statusOut.className = 'status-item done';
                        outTime.textContent = data.checkOutTime || '已打卡';
                    } else {
                        statusOut.className = 'status-item pending';
                        outTime.textContent = '未打卡';
                    }
                    updateButtonStates();
                } else if (data.needLogin) {
                    window.location.href = ctxPath + '/miniapp';
                }
            });
    }

    function loadMonthStats() {
        const now = new Date();
        const ym = now.getFullYear() + '-' + String(now.getMonth()+1).padStart(2, '0');
        fetch(ctxPath + '/miniapp?action=monthRecords&yearMonth=' + ym)
            .then(r => r.json())
            .then(data => {
                if (data.success && data.stats) {
                    const s = data.stats;
                    document.getElementById('statNormal').textContent = s.normalDays || 0;
                    document.getElementById('statLate').textContent = (parseInt(s.lateDays)||0) + (parseInt(s.earlyDays)||0);
                    document.getElementById('statAbsent').textContent = s.absentDays || 0;
                }
            });
    }

    function clockIn() {
        const btn = document.getElementById('btnClockIn');
        if (btn.disabled) return;
        btn.classList.add('loading'); showLoading();
        fetch(ctxPath + '/miniapp?action=clockIn', { method: 'POST' })
            .then(r => r.json())
            .then(data => {
                hideLoading(); btn.classList.remove('loading');
                if (data.needLogin) { window.location.href = ctxPath + '/miniapp'; return; }
                if (data.success) {
                    showToast(data.message, data.isLate ? 'warning' : 'success');
                    const card = document.getElementById('clockCard');
                    card.classList.add('success-anim');
                    setTimeout(() => card.classList.remove('success-anim'), 500);
                    loadTodayStatus(); loadMonthStats();
                } else { showToast(data.message, 'error'); }
            }).catch(() => { hideLoading(); btn.classList.remove('loading'); showToast('网络错误，请重试', 'error'); });
    }

    function clockOut() {
        const btn = document.getElementById('btnClockOut');
        if (btn.disabled) return;
        btn.classList.add('loading'); showLoading();
        fetch(ctxPath + '/miniapp?action=clockOut', { method: 'POST' })
            .then(r => r.json())
            .then(data => {
                hideLoading(); btn.classList.remove('loading');
                if (data.needLogin) { window.location.href = ctxPath + '/miniapp'; return; }
                if (data.success) {
                    showToast(data.message, data.isEarly ? 'warning' : 'success');
                    const card = document.getElementById('clockCard');
                    card.classList.add('success-anim');
                    setTimeout(() => card.classList.remove('success-anim'), 500);
                    loadTodayStatus(); loadMonthStats();
                } else { showToast(data.message, 'error'); }
            }).catch(() => { hideLoading(); btn.classList.remove('loading'); showToast('网络错误，请重试', 'error'); });
    }

    function doLogout() {
        if (confirm('确定要退出登录吗？')) window.location.href = ctxPath + '/miniapp?action=logout';
    }

    document.addEventListener('DOMContentLoaded', function() {
        loadTodayStatus(); loadMonthStats();
        setInterval(loadTodayStatus, 30000);
    });
</script>
</body>
</html>
