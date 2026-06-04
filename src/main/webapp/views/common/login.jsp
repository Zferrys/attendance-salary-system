<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>员工考勤与薪资管理系统 - 登录</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
    <style>
        .login-bg-animation {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            overflow: hidden;
            pointer-events: none;
        }
        .login-bg-animation .circle {
            position: absolute;
            border-radius: 50%;
            background: rgba(255,255,255,0.03);
            animation: float 8s ease-in-out infinite;
        }
        .login-bg-animation .circle:nth-child(1) { width: 300px; height: 300px; top: 10%; left: 10%; animation-delay: 0s; }
        .login-bg-animation .circle:nth-child(2) { width: 200px; height: 200px; top: 60%; left: 70%; animation-delay: 2s; }
        .login-bg-animation .circle:nth-child(3) { width: 150px; height: 150px; top: 30%; left: 80%; animation-delay: 4s; }
        @keyframes float {
            0%, 100% { transform: translateY(0) scale(1); }
            50% { transform: translateY(-20px) scale(1.05); }
        }
        .login-card .form-control {
            transition: all 0.3s;
        }
        .login-card .form-control:focus {
            transform: translateY(-1px);
        }
        .role-selector {
            display: flex;
            gap: 8px;
            margin-bottom: 20px;
        }
        .role-selector .role-btn {
            flex: 1;
            padding: 10px;
            border: 1.5px solid #d1d5db;
            border-radius: 8px;
            background: #fff;
            cursor: pointer;
            text-align: center;
            font-size: 13px;
            font-weight: 500;
            color: #6b7280;
            transition: all 0.25s;
        }
        .role-selector .role-btn:hover {
            border-color: #1a73e8;
            color: #1a73e8;
        }
        .role-selector .role-btn.active {
            border-color: #1a73e8;
            background: #eff6ff;
            color: #1a73e8;
        }
    </style>
</head>
<body class="login-page">
    <div class="login-bg-animation">
        <div class="circle"></div>
        <div class="circle"></div>
        <div class="circle"></div>
    </div>
    
    <div class="login-card">
        <h2>员工考勤与薪资管理系统</h2>
        <p class="login-subtitle">考勤打卡 · 请假审批 · 薪资管理</p>

        <!-- 错误消息提示 -->
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger">${errorMsg}</div>
        </c:if>

        <!-- 快捷角色选择 -->
        <div class="role-selector">
            <div class="role-btn" onclick="selectRole(this)">管理员</div>
            <div class="role-btn" onclick="selectRole(this)">主管</div>
            <div class="role-btn" onclick="selectRole(this)">员工</div>
        </div>

        <!-- 登录表单 -->
        <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm">
            <input type="hidden" name="action" value="login">

            <div class="form-group">
                <label for="empNo">工号</label>
                <input type="text" id="empNo" name="empNo" class="form-control"
                       placeholder="请输入工号（如 E001、M001、A001）"
                       value="" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">密码</label>
                <input type="password" id="password" name="password" class="form-control"
                       placeholder="请输入密码（默认 123456）"
                       value="" required>
            </div>

            <button type="submit" class="btn btn-primary" id="loginBtn">
                <span id="btnText">&#128274; 登 录 系 统</span>
            </button>
        </form>

        <!-- 测试账号提示 -->
        <div class="test-accounts">
            <strong>&#128203; 测试账号（密码均为 123456）：</strong>
            A001 — 管理员 | M001 — 陈主管 | E001 ~ E005 — 员工
        </div>
    </div>

    <script>
        function selectRole(btn) {
            // 仅高亮当前选中的角色，不自动填充账号密码
            document.querySelectorAll('.role-selector .role-btn').forEach(function(b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
        }
        
        // 登录按钮加载动画
        document.getElementById('loginForm').addEventListener('submit', function() {
            var btn = document.getElementById('loginBtn');
            var txt = document.getElementById('btnText');
            btn.disabled = true;
            txt.innerHTML = '<span style="display:inline-block;width:16px;height:16px;border:2px solid #fff;border-top-color:transparent;border-radius:50%;animation:spin 0.8s linear infinite;vertical-align:middle;margin-right:6px;"></span>登录中...';
        });
    </script>
</body>
</html>
