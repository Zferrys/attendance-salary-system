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
            --primary: #1a73e8;
            --success: #0d9e6c;
            --danger: #dc3545;
            --bg: #f0f2f5;
            --card-bg: #ffffff;
            --text: #1f2937;
            --text-secondary: #6b7280;
            --border: #e5e7eb;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            padding-bottom: 80px;
            -webkit-tap-highlight-color: transparent;
        }

        /* 个人信息卡片 */
        .profile-card {
            background: linear-gradient(135deg, #1e3a5f 0%, #2980b9 100%);
            color: #fff;
            padding: 32px 24px;
            text-align: center;
            padding-top: max(32px, env(safe-area-inset-top) + 16px);
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
            border: 3px solid rgba(255,255,255,0.4);
        }
        .profile-card .name {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 4px;
        }
        .profile-card .info-row {
            display: flex;
            justify-content: center;
            gap: 20px;
            font-size: 13px;
            opacity: 0.85;
            margin-top: 8px;
        }

        .container {
            max-width: 480px;
            margin: 0 auto;
            padding: 16px;
        }

        /* 菜单列表 */
        .menu-list {
            background: var(--card-bg);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
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
        .menu-item:active { background: #f8fafc; }
        .menu-item .menu-icon {
            font-size: 22px;
            width: 28px;
            text-align: center;
        }
        .menu-item .menu-arrow {
            margin-left: auto;
            color: #cbd5e0;
            font-size: 16px;
        }
        .menu-item .menu-badge {
            margin-left: auto;
            margin-right: 4px;
            font-size: 13px;
            color: var(--text-secondary);
        }

        /* 退出按钮 */
        .logout-section {
            padding: 0 16px;
        }
        .logout-btn {
            width: 100%;
            padding: 14px;
            border: 1.5px solid var(--danger);
            background: #fff;
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
            background: #fef2f2;
            transform: scale(0.98);
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
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }

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
    </style>
</head>
<body>

<!-- 个人信息 -->
<div class="profile-card">
    <div class="avatar">👤</div>
    <div class="name">${user.name}</div>
    <div class="info-row">
        <span>工号：${user.empNo}</span>
        <span>${user.position}</span>
    </div>
</div>

<div class="container">
    <!-- 功能菜单 -->
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

    <!-- 退出登录 -->
    <div class="logout-section">
        <button class="logout-btn" onclick="doLogout()">
            🚪 退出登录
        </button>
    </div>
</div>

<!-- 底部导航 -->
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
            // 先清除本地存储
            localStorage.removeItem('miniapp_empNo');
            localStorage.removeItem('miniapp_password');
            // 跳转到服务端退出（会清除 session），带 logout 参数防止登录页自动填充
            window.location.replace(ctxPath + '/miniapp?action=logout&from=logout');
        }
    }
</script>
</body>
</html>
