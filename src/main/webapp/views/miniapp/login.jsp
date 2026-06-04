<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <title>考勤打卡 - 登录</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            min-height: 100vh;
            background: linear-gradient(135deg, #0f1b33 0%, #1a3a5c 40%, #1a5276 70%, #2980b9 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            -webkit-tap-highlight-color: transparent;
        }

        .login-box {
            background: #fff;
            border-radius: 20px;
            padding: 40px 28px 32px;
            width: 100%;
            max-width: 380px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .login-box .logo {
            text-align: center;
            margin-bottom: 8px;
            font-size: 48px;
        }

        .login-box h2 {
            text-align: center;
            font-size: 22px;
            color: #1f2937;
            font-weight: 700;
            margin-bottom: 6px;
        }

        .login-box .subtitle {
            text-align: center;
            color: #6b7280;
            font-size: 14px;
            margin-bottom: 28px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #4b5563;
            margin-bottom: 6px;
        }

        .form-group input {
            width: 100%;
            padding: 14px 16px;
            border: 1.5px solid #d1d5db;
            border-radius: 12px;
            font-size: 16px;
            color: #1f2937;
            outline: none;
            transition: all 0.25s;
            background: #f9fafb;
        }

        .form-group input:focus {
            border-color: #1a73e8;
            box-shadow: 0 0 0 3px rgba(26,115,232,0.12);
            background: #fff;
        }

        .login-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #1a73e8, #4a90d9);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 17px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.25s;
            margin-top: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .login-btn:active {
            transform: scale(0.97);
            opacity: 0.9;
        }

        .login-btn.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .login-btn .spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 2.5px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
        }

        .login-btn.loading .spinner { display: inline-block; }
        .login-btn.loading .btn-text { display: none; }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        .error-msg {
            padding: 12px 16px;
            background: #fef2f2;
            color: #991b1b;
            border-radius: 10px;
            font-size: 13px;
            margin-bottom: 16px;
            display: none;
            text-align: center;
            font-weight: 500;
        }

        .error-msg.show { display: block; animation: shake 0.4s ease; }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-8px); }
            75% { transform: translateX(8px); }
        }

        .tips {
            margin-top: 20px;
            padding: 14px 16px;
            background: #f8fafc;
            border-radius: 10px;
            border: 1px dashed #d1d5db;
        }

        .tips strong {
            display: block;
            font-size: 13px;
            color: #4b5563;
            margin-bottom: 6px;
        }

        .tips p {
            font-size: 12px;
            color: #6b7280;
            line-height: 1.8;
        }

        .pc-link {
            display: block;
            text-align: center;
            margin-top: 18px;
            color: #1a73e8;
            font-size: 13px;
            text-decoration: none;
            font-weight: 500;
        }

        .pc-link:active {
            opacity: 0.7;
        }

        .remember-hint {
            font-size: 12px;
            color: #9ca3af;
            text-align: center;
            margin-top: 8px;
        }
    </style>
</head>
<body>

<div class="login-box">
    <div class="logo">⏱️</div>
    <h2>考勤打卡</h2>
    <div class="subtitle">移动端快速打卡</div>

    <div class="error-msg" id="errorMsg"></div>

    <form id="loginForm" onsubmit="handleLogin(event)">
        <div class="form-group">
            <label for="empNo">工号</label>
            <input type="text" id="empNo" name="empNo" 
                   placeholder="请输入工号（如 E001）"
                   autocomplete="username"
                   required autofocus>
        </div>

        <div class="form-group">
            <label for="password">密码</label>
            <input type="password" id="password" name="password" 
                   placeholder="请输入密码"
                   autocomplete="current-password"
                   required>
        </div>

        <button type="submit" class="login-btn" id="loginBtn">
            <span class="btn-text">🔐 登录打卡</span>
            <span class="spinner"></span>
        </button>
    </form>

    <div class="remember-hint" id="rememberHint" style="display:none;">
        ✅ 已记住登录，下次自动进入
    </div>

    <div class="tips">
        <strong>📌 测试账号（密码均为 123456）：</strong>
        <p>
            管理员：A001 &nbsp;|&nbsp; 主管：M001<br>
            员工：E001 ~ E005
        </p>
    </div>

    <a href="${pageContext.request.contextPath}/views/common/login.jsp" class="pc-link">
        💻 切换到 PC 版登录
    </a>
</div>

<script>
    const ctxPath = '${pageContext.request.contextPath}';

    // 页面加载时尝试自动登录
    document.addEventListener('DOMContentLoaded', function() {
        const savedEmpNo = localStorage.getItem('miniapp_empNo');
        const savedPwd = localStorage.getItem('miniapp_password');
        
        if (savedEmpNo && savedPwd) {
            document.getElementById('empNo').value = savedEmpNo;
            document.getElementById('password').value = savedPwd;
            document.getElementById('rememberHint').style.display = 'block';
            // 自动登录
            autoLogin(savedEmpNo, savedPwd);
        }
    });

    function autoLogin(empNo, password) {
        const btn = document.getElementById('loginBtn');
        btn.classList.add('loading');
        
        fetch(ctxPath + '/miniapp?action=login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'empNo=' + encodeURIComponent(empNo) + '&password=' + encodeURIComponent(password)
        })
        .then(r => r.json())
        .then(data => {
            btn.classList.remove('loading');
            if (data.success) {
                // 记住登录信息
                localStorage.setItem('miniapp_empNo', empNo);
                localStorage.setItem('miniapp_password', password);
                window.location.href = ctxPath + '/miniapp?action=clock';
            } else {
                // 自动登录失败，清除存储的密码
                localStorage.removeItem('miniapp_password');
                document.getElementById('rememberHint').style.display = 'none';
                showError(data.message || '自动登录失败，请手动输入');
            }
        })
        .catch(err => {
            btn.classList.remove('loading');
            showError('网络错误，请检查连接');
        });
    }

    function handleLogin(e) {
        e.preventDefault();
        
        const empNo = document.getElementById('empNo').value.trim();
        const password = document.getElementById('password').value.trim();
        const btn = document.getElementById('loginBtn');
        
        if (!empNo || !password) {
            showError('请输入工号和密码！');
            return;
        }
        
        btn.classList.add('loading');
        hideError();
        
        fetch(ctxPath + '/miniapp?action=login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'empNo=' + encodeURIComponent(empNo) + '&password=' + encodeURIComponent(password)
        })
        .then(r => r.json())
        .then(data => {
            btn.classList.remove('loading');
            if (data.success) {
                // 记住登录信息
                localStorage.setItem('miniapp_empNo', empNo);
                localStorage.setItem('miniapp_password', password);
                window.location.href = ctxPath + '/miniapp?action=clock';
            } else {
                showError(data.message || '登录失败');
            }
        })
        .catch(err => {
            btn.classList.remove('loading');
            showError('网络错误，请检查连接');
        });
    }

    function showError(msg) {
        const el = document.getElementById('errorMsg');
        el.textContent = msg;
        el.classList.add('show');
    }

    function hideError() {
        document.getElementById('errorMsg').classList.remove('show');
    }
</script>
</body>
</html>
