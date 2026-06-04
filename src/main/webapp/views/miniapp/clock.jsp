<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <title>考勤打卡 - 小程序</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --primary: #1a73e8;
            --primary-dark: #1557b0;
            --success: #0d9e6c;
            --warning: #f0a020;
            --danger: #dc3545;
            --bg: #f0f2f5;
            --card-bg: #ffffff;
            --text: #1f2937;
            --text-secondary: #6b7280;
            --border: #e5e7eb;
            --radius: 16px;
            --radius-sm: 12px;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            padding-bottom: 80px;
            -webkit-tap-highlight-color: transparent;
            user-select: none;
            -webkit-user-select: none;
        }

        /* 顶部导航 */
        .header {
            background: linear-gradient(135deg, #1e3a5f 0%, #2980b9 100%);
            color: #fff;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
            padding-top: max(16px, env(safe-area-inset-top));
        }
        .header .title {
            font-size: 17px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .header .user-badge {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            opacity: 0.9;
        }
        .header .logout-btn {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            color: #fff;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .header .logout-btn:active {
            background: rgba(255,255,255,0.3);
        }

        /* 主容器 */
        .container {
            max-width: 480px;
            margin: 0 auto;
            padding: 16px;
        }

        /* 时钟卡片 */
        .clock-card {
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 32px 24px;
            text-align: center;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            margin-bottom: 16px;
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
            color: var(--text-secondary);
            margin-top: 4px;
        }

        /* 打卡状态 */
        .clock-status {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
        }
        .clock-status .status-item {
            flex: 1;
            background: var(--card-bg);
            border-radius: var(--radius-sm);
            padding: 16px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .status-item .status-icon {
            font-size: 28px;
            margin-bottom: 6px;
        }
        .status-item .status-label {
            font-size: 12px;
            color: var(--text-secondary);
            margin-bottom: 4px;
        }
        .status-item .status-time {
            font-size: 15px;
            font-weight: 600;
            color: var(--text);
        }
        .status-item.done {
            border: 1.5px solid var(--success);
            background: #f0fdf6;
        }
        .status-item.pending {
            border: 1.5px solid var(--border);
        }

        /* 打卡按钮 */
        .clock-buttons {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
        }
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
        .clock-btn:active::after {
            background: rgba(255,255,255,0.15);
        }
        .clock-btn:active {
            transform: scale(0.96);
        }
        .clock-btn .btn-icon {
            font-size: 32px;
        }
        .clock-btn .btn-label {
            font-size: 13px;
            opacity: 0.9;
        }
        .clock-btn.in-btn {
            background: linear-gradient(135deg, #1a73e8, #4a90d9);
            box-shadow: 0 4px 16px rgba(26,115,232,0.3);
        }
        .clock-btn.out-btn {
            background: linear-gradient(135deg, #0d9e6c, #34d399);
            box-shadow: 0 4px 16px rgba(13,158,108,0.3);
        }
        .clock-btn:disabled {
            background: #cbd5e0 !important;
            box-shadow: none !important;
            cursor: not-allowed;
            opacity: 0.6;
        }
        .clock-btn.loading {
            pointer-events: none;
            opacity: 0.7;
        }
        .clock-btn .spinner {
            display: none;
            width: 24px;
            height: 24px;
            border: 3px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
        }
        .clock-btn.loading .spinner { display: block; }
        .clock-btn.loading .btn-icon { display: none; }
        .clock-btn.loading .btn-label { display: none; }

        /* 统计卡片 */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 16px;
        }
        .stat-mini {
            background: var(--card-bg);
            border-radius: var(--radius-sm);
            padding: 16px 12px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .stat-mini .stat-num {
            font-size: 26px;
            font-weight: 700;
            line-height: 1;
        }
        .stat-mini .stat-num.green { color: var(--success); }
        .stat-mini .stat-num.amber { color: var(--warning); }
        .stat-mini .stat-num.red { color: var(--danger); }
        .stat-mini .stat-text {
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 4px;
        }

        /* 操作入口 */
        .action-links {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 16px;
        }
        .action-link {
            background: var(--card-bg);
            border-radius: var(--radius-sm);
            padding: 16px 10px;
            text-align: center;
            text-decoration: none;
            color: var(--text);
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
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
            background: #f0f2f5;
        }
        .action-link .link-icon {
            font-size: 26px;
        }

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
            max-width: 90vw;
            text-align: center;
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }
        .toast.warning { background: var(--warning); }
        .toast.info { background: var(--primary); }

        /* 加载遮罩 */
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

        @keyframes spin {
            to { transform: rotate(360deg); }
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
        .bottom-nav .nav-item.active {
            color: var(--primary);
        }
        .bottom-nav .nav-item .nav-icon {
            font-size: 22px;
        }

        /* 打卡成功动画 */
        @keyframes successPulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.08); }
            100% { transform: scale(1); }
        }
        .clock-card.success-anim {
            animation: successPulse 0.5s ease;
            background: linear-gradient(135deg, #f0fdf6, #d1fae5);
        }

        /* 响应式 */
        @media (max-width: 360px) {
            .clock-card .live-time { font-size: 44px; }
            .clock-btn { padding: 16px; font-size: 16px; }
            .clock-btn .btn-icon { font-size: 26px; }
        }
    </style>
</head>
<body>

<!-- 顶部导航 -->
<div class="header">
    <div class="title">⏱️ 考勤打卡</div>
    <div class="user-badge">
        <span id="headerUserName">${user.name}</span>
        <button class="logout-btn" onclick="doLogout()">退出</button>
    </div>
</div>

<!-- Toast -->
<div class="toast" id="toast"></div>

<!-- 加载遮罩 -->
<div class="overlay" id="overlay">
    <div class="loader"></div>
</div>

<div class="container">
    <!-- 实时时钟 -->
    <div class="clock-card" id="clockCard">
        <div class="live-time" id="liveTime">00:00:00</div>
        <div class="live-date" id="liveDate">--</div>
        <div class="greeting" id="greeting">--</div>
    </div>

    <!-- 打卡状态 -->
    <div class="clock-status">
        <div class="status-item pending" id="statusIn">
            <div class="status-icon">🌅</div>
            <div class="status-label">上班打卡</div>
            <div class="status-time" id="inTime">未打卡</div>
        </div>
        <div class="status-item pending" id="statusOut">
            <div class="status-icon">🌇</div>
            <div class="status-label">下班打卡</div>
            <div class="status-time" id="outTime">未打卡</div>
        </div>
    </div>

    <!-- 打卡按钮 -->
    <div class="clock-buttons">
        <button class="clock-btn in-btn" id="btnClockIn" onclick="clockIn()">
            <span class="btn-icon">☀️</span>
            <span class="btn-label">上班打卡</span>
            <span class="spinner"></span>
        </button>
        <button class="clock-btn out-btn" id="btnClockOut" onclick="clockOut()">
            <span class="btn-icon">🌙</span>
            <span class="btn-label">下班打卡</span>
            <span class="spinner"></span>
        </button>
    </div>

    <!-- 本月统计 -->
    <div class="stats-row" id="monthStats">
        <div class="stat-mini">
            <div class="stat-num green" id="statNormal">0</div>
            <div class="stat-text">正常出勤</div>
        </div>
        <div class="stat-mini">
            <div class="stat-num amber" id="statLate">0</div>
            <div class="stat-text">迟到/早退</div>
        </div>
        <div class="stat-mini">
            <div class="stat-num red" id="statAbsent">0</div>
            <div class="stat-text">缺勤</div>
        </div>
    </div>

    <!-- 快捷入口 -->
    <div class="action-links">
        <a href="${pageContext.request.contextPath}/miniapp?action=records" class="action-link">
            <span class="link-icon">📋</span>
            考勤记录
        </a>
        <a href="${pageContext.request.contextPath}/employee?action=applyLeave" class="action-link">
            <span class="link-icon">📝</span>
            请假申请
        </a>
        <a href="${pageContext.request.contextPath}/employee?action=salaryView" class="action-link">
            <span class="link-icon">💰</span>
            薪资查询
        </a>
    </div>
</div>

<!-- 底部导航 -->
<div class="bottom-nav">
    <a href="${pageContext.request.contextPath}/miniapp?action=clock" class="nav-item active">
        <span class="nav-icon">🏠</span>
        打卡
    </a>
    <a href="${pageContext.request.contextPath}/miniapp?action=records" class="nav-item">
        <span class="nav-icon">📋</span>
        记录
    </a>
    <a href="${pageContext.request.contextPath}/employee?action=dashboard" class="nav-item">
        <span class="nav-icon">👤</span>
        我的
    </a>
</div>

<script>
    const ctxPath = '${pageContext.request.contextPath}';
    let todayStatus = { hasCheckedIn: false, hasCheckedOut: false };
    
    // ===== 实时时钟 =====
    function updateClock() {
        const now = new Date();
        const h = String(now.getHours()).padStart(2, '0');
        const m = String(now.getMinutes()).padStart(2, '0');
        const s = String(now.getSeconds()).padStart(2, '0');
        document.getElementById('liveTime').textContent = h + ':' + m + ':' + s;
        
        const weekdays = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
        document.getElementById('liveDate').textContent = 
            now.getFullYear() + '年' + (now.getMonth()+1) + '月' + now.getDate() + '日 ' + weekdays[now.getDay()];
        
        // 问候语
        const hour = now.getHours();
        let greeting = hour < 6 ? '夜深了，注意休息 🌙' :
                       hour < 9 ? '早上好！新的一天 ☀️' :
                       hour < 12 ? '上午好！工作顺利 📊' :
                       hour < 14 ? '中午好！记得休息 🍜' :
                       hour < 18 ? '下午好！继续加油 💪' :
                       hour < 21 ? '晚上好！辛苦了 🌆' :
                       '夜深了，早点休息 🌙';
        document.getElementById('greeting').textContent = greeting;
        
        // 按钮状态
        updateButtonStates();
    }
    
    function updateButtonStates() {
        const now = new Date();
        const hour = now.getHours();
        const btnIn = document.getElementById('btnClockIn');
        const btnOut = document.getElementById('btnClockOut');
        
        // 根据打卡状态和当前时间控制按钮
        if (todayStatus.hasCheckedIn && todayStatus.hasCheckedOut) {
            btnIn.disabled = true;
            btnOut.disabled = true;
            btnIn.innerHTML = '<span class="btn-icon">✅</span><span class="btn-label">已完成</span><span class="spinner"></span>';
            btnOut.innerHTML = '<span class="btn-icon">✅</span><span class="btn-label">已完成</span><span class="spinner"></span>';
        } else if (todayStatus.hasCheckedIn) {
            btnIn.disabled = true;
            btnIn.innerHTML = '<span class="btn-icon">✅</span><span class="btn-label">已打卡</span><span class="spinner"></span>';
            btnOut.disabled = false;
        } else {
            btnIn.disabled = false;
            btnOut.disabled = false;
        }
    }
    
    setInterval(updateClock, 1000);
    updateClock();
    
    // ===== Toast =====
    let toastTimer;
    function showToast(msg, type) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.className = 'toast ' + (type || 'info');
        clearTimeout(toastTimer);
        requestAnimationFrame(() => {
            toast.classList.add('show');
        });
        toastTimer = setTimeout(() => {
            toast.classList.remove('show');
        }, 2500);
    }
    
    // ===== 加载 =====
    function showLoading() {
        document.getElementById('overlay').classList.add('show');
    }
    function hideLoading() {
        document.getElementById('overlay').classList.remove('show');
    }
    
    // ===== 查询今日状态 =====
    function loadTodayStatus() {
        fetch(ctxPath + '/miniapp?action=todayStatus')
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    todayStatus = data;
                    // 更新上班状态
                    const statusIn = document.getElementById('statusIn');
                    const inTime = document.getElementById('inTime');
                    if (data.hasCheckedIn) {
                        statusIn.className = 'status-item done';
                        inTime.textContent = data.checkInTime || '已打卡';
                    } else {
                        statusIn.className = 'status-item pending';
                        inTime.textContent = '未打卡';
                    }
                    // 更新下班状态
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
            })
            .catch(err => {
                console.error('获取状态失败:', err);
            });
    }
    
    // ===== 加载月度统计 =====
    function loadMonthStats() {
        const now = new Date();
        const ym = now.getFullYear() + '-' + String(now.getMonth()+1).padStart(2, '0');
        fetch(ctxPath + '/miniapp?action=monthRecords&yearMonth=' + ym)
            .then(r => r.json())
            .then(data => {
                if (data.success && data.stats) {
                    const s = data.stats;
                    const normalDays = (parseInt(s.normalDays) || 0);
                    const lateDays = (parseInt(s.lateDays) || 0) + (parseInt(s.earlyDays) || 0);
                    const absentDays = (parseInt(s.absentDays) || 0);
                    
                    document.getElementById('statNormal').textContent = normalDays;
                    document.getElementById('statLate').textContent = lateDays;
                    document.getElementById('statAbsent').textContent = absentDays;
                }
            })
            .catch(err => console.error('获取统计失败:', err));
    }
    
    // ===== 上班打卡 =====
    function clockIn() {
        const btn = document.getElementById('btnClockIn');
        if (btn.disabled) return;
        
        btn.classList.add('loading');
        showLoading();
        
        fetch(ctxPath + '/miniapp?action=clockIn', { method: 'POST' })
            .then(r => r.json())
            .then(data => {
                hideLoading();
                btn.classList.remove('loading');
                
                if (data.needLogin) {
                    window.location.href = ctxPath + '/miniapp';
                    return;
                }
                
                if (data.success) {
                    showToast(data.message, data.isLate ? 'warning' : 'success');
                    // 成功动画
                    const card = document.getElementById('clockCard');
                    card.classList.add('success-anim');
                    setTimeout(() => card.classList.remove('success-anim'), 500);
                    
                    loadTodayStatus();
                    loadMonthStats();
                } else {
                    showToast(data.message, 'error');
                }
            })
            .catch(err => {
                hideLoading();
                btn.classList.remove('loading');
                showToast('网络错误，请重试', 'error');
            });
    }
    
    // ===== 下班打卡 =====
    function clockOut() {
        const btn = document.getElementById('btnClockOut');
        if (btn.disabled) return;
        
        btn.classList.add('loading');
        showLoading();
        
        fetch(ctxPath + '/miniapp?action=clockOut', { method: 'POST' })
            .then(r => r.json())
            .then(data => {
                hideLoading();
                btn.classList.remove('loading');
                
                if (data.needLogin) {
                    window.location.href = ctxPath + '/miniapp';
                    return;
                }
                
                if (data.success) {
                    showToast(data.message, data.isEarly ? 'warning' : 'success');
                    const card = document.getElementById('clockCard');
                    card.classList.add('success-anim');
                    setTimeout(() => card.classList.remove('success-anim'), 500);
                    
                    loadTodayStatus();
                    loadMonthStats();
                } else {
                    showToast(data.message, 'error');
                }
            })
            .catch(err => {
                hideLoading();
                btn.classList.remove('loading');
                showToast('网络错误，请重试', 'error');
            });
    }
    
    // ===== 退出登录 =====
    function doLogout() {
        if (confirm('确定要退出登录吗？')) {
            window.location.href = ctxPath + '/miniapp?action=logout';
        }
    }
    
    // ===== 页面初始化 =====
    document.addEventListener('DOMContentLoaded', function() {
        loadTodayStatus();
        loadMonthStats();
        
        // 每30秒自动刷新状态
        setInterval(loadTodayStatus, 30000);
    });
</script>
</body>
</html>
