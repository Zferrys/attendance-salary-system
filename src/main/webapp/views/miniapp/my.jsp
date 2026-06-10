<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>我的 - 小程序</title>
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
            --danger: #ef4444;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: linear-gradient(135deg, var(--bg-start) 0%, var(--bg-mid) 50%, var(--bg-end) 100%);
            color: var(--text);
            min-height: 100vh;
            padding-bottom: 80px;
            -webkit-tap-highlight-color: transparent;
        }

        .profile-card {
            background: linear-gradient(135deg, #7c3aed 0%, #6d28d9 30%, #3b82f6 100%);
            color: #fff;
            padding: 32px 24px;
            text-align: center;
            position: relative;
            overflow: hidden;
            padding-top: max(32px, env(safe-area-inset-top) + 16px);
        }
        .profile-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle at 30% 50%, rgba(255,255,255,0.08) 0%, transparent 50%),
                        radial-gradient(circle at 70% 20%, rgba(255,255,255,0.06) 0%, transparent 40%);
            pointer-events: none;
        }
        .profile-card .avatar {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            margin: 0 auto 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            border: 3px solid rgba(255,255,255,0.3);
            position: relative;
            z-index: 1;
        }
        .profile-card .name {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 4px;
            position: relative;
            z-index: 1;
        }
        .profile-card .info-row {
            display: flex;
            justify-content: center;
            gap: 20px;
            font-size: 13px;
            opacity: 0.8;
            margin-top: 8px;
            position: relative;
            z-index: 1;
        }

        .container {
            max-width: 480px;
            margin: 0 auto;
            padding: 16px;
        }

        .menu-list {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            margin-bottom: 16px;
        }
        .menu-item {
            display: flex;
            align-items: center;
            padding: 16px 20px;
            border-bottom: 1px solid var(--border);
            text-decoration: none;
            color: var(--text);
            font-size: 15px;
            transition: all 0.2s;
            gap: 14px;
        }
        .menu-item:last-child { border-bottom: none; }
        .menu-item:active { background: rgba(124,58,237,0.04); }
        .menu-item .menu-icon {
            font-size: 22px;
            width: 28px;
            text-align: center;
        }
        .menu-item .menu-arrow {
            margin-left: auto;
            color: #cbd5e1;
            font-size: 16px;
        }
        .menu-item .menu-badge {
            margin-left: auto;
            margin-right: 4px;
            font-size: 13px;
            color: var(--text-secondary);
        }

        .logout-section {
            padding: 0 16px;
        }
        .logout-btn {
            width: 100%;
            padding: 14px;
            border: 1px solid rgba(239,68,68,0.2);
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            color: var(--danger);
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .logout-btn:active {
            background: rgba(239,68,68,0.06);
            transform: scale(0.98);
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
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }

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
    </style>
</head>
<body>

<div class="profile-card">
    <div class="avatar">👤</div>
    <div class="name">${user.name}</div>
    <div class="info-row">
        <span>工号：${user.empNo}</span>
        <span>${user.position}</span>
    </div>
</div>

<div class="container">
    <div class="menu-list">
        <a href="${pageContext.request.contextPath}/miniapp?action=records" class="menu-item">
            <span class="menu-icon">📋</span>
            <span>考勤记录</span>
            <span class="menu-arrow">›</span>
        </a>
        <a href="${pageContext.request.contextPath}/miniapp?action=leaveApply" class="menu-item">
            <span class="menu-icon">📝</span>
            <span>请假申请</span>
            <span class="menu-arrow">›</span>
        </a>
        <a href="${pageContext.request.contextPath}/miniapp?action=salary" class="menu-item">
            <span class="menu-icon">💰</span>
            <span>薪资查询</span>
            <span class="menu-arrow">›</span>
        </a>
    </div>

    <div class="logout-section">
        <button class="logout-btn" onclick="doLogout()">
            🚪 退出登录
        </button>
    </div>
</div>

<div class="bottom-nav">
    <a href="${pageContext.request.contextPath}/miniapp?action=clock" class="nav-item">
        <span class="nav-icon">🏠</span>
        打卡
    </a>
    <a href="${pageContext.request.contextPath}/miniapp?action=records" class="nav-item">
        <span class="nav-icon">📋</span>
        记录
    </a>
    <a href="${pageContext.request.contextPath}/miniapp?action=my" class="nav-item active">
        <span class="nav-icon">👤</span>
        我的
    </a>
</div>

<script>
    const ctxPath = '${pageContext.request.contextPath}';
    
    function doLogout() {
        if (confirm('确定要退出登录吗？')) {
            localStorage.removeItem('miniapp_empNo');
            localStorage.removeItem('miniapp_password');
            window.location.replace(ctxPath + '/miniapp?action=logout&from=logout');
        }
    }
</script>
</body>
</html>
