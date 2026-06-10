<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.attendance.utils.CsrfUtil" %>
<%
  String csrfToken = CsrfUtil.getToken(request);
  pageContext.setAttribute("csrfToken", csrfToken);
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="_csrf" content="${csrfToken}">
  <title>考勤薪资管理系统 - 登录</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
  <style>
    .login-bg-dots {
      position: absolute; inset: 0;
      background-image: radial-gradient(rgba(124,58,237,0.04) 1px, transparent 1px);
      background-size: 32px 32px;
      pointer-events: none;
    }
    .login-card .input-group {
      position: relative;
    }
    .login-card .input-group .icon {
      position: absolute;
      left: 13px; top: 50%;
      transform: translateY(-50%);
      color: var(--ink-muted);
      font-size: 0.95rem;
      pointer-events: none;
      z-index: 1;
    }
    .login-card .input-group input {
      padding-left: 38px;
    }
    .login-error {
      background: var(--danger-soft);
      color: var(--danger);
      padding: 10px 14px;
      border-radius: var(--radius);
      font-size: 0.82rem;
      margin-bottom: 18px;
      display: flex;
      align-items: center;
      gap: 8px;
      border: 1px solid var(--danger-border);
      animation: slideDown 0.3s ease;
    }
    .login-error::before { content: '\26A0'; font-size: 1rem; }
    .login-divider {
      display: flex;
      align-items: center;
      margin: 24px 0 16px;
      color: var(--ink-muted);
      font-size: 0.78rem;
    }
    .login-divider::before, .login-divider::after {
      content: '';
      flex: 1;
      height: 1px;
      background: var(--border);
    }
    .login-divider span { padding: 0 14px; }
    .btn-miniapp {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      width: 100%;
      padding: 11px;
      border-radius: var(--radius);
      border: 1.5px solid var(--primary-border);
      background: var(--primary-soft);
      color: var(--primary);
      font-size: 0.88rem;
      font-weight: 600;
      cursor: pointer;
      text-decoration: none;
      transition: all var(--transition);
    }
    .btn-miniapp:hover {
      background: rgba(124,58,237,0.12);
      border-color: var(--primary);
      color: var(--primary);
      box-shadow: 0 0 20px rgba(124,58,237,0.12);
      transform: translateY(-1px);
    }
    .login-back {
      text-align: center;
      margin-top: 16px;
    }
    .login-back a {
      color: var(--ink-muted);
      font-size: 0.78rem;
      text-decoration: none;
      transition: color var(--transition-fast);
    }
    .login-back a:hover { color: var(--primary); }
  </style>
</head>
<body class="login-page">
  <div class="login-bg-dots"></div>

  <div class="login-card">
    <div class="login-logo">
      <div class="logo-icon">
        <img src="${pageContext.request.contextPath}/assets/images/logo.svg" alt="Logo" width="28" height="28">
      </div>
    </div>
    <h2>考勤薪资管理系统</h2>
    <p class="login-subtitle">员工考勤 &middot; 薪资管理 &middot; 数据分析</p>

    <c:if test="${not empty errorMsg}">
      <div class="login-error">${errorMsg}</div>
    </c:if>

    <!-- PC 端登录表单 -->
    <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm" autocomplete="off">
      <input type="hidden" name="action" value="login">
      <input type="hidden" name="_csrf" value="${csrfToken}">

      <div class="form-group">
        <label for="empNo">工号</label>
        <div class="input-group">
          <span class="icon">&#128100;</span>
          <input type="text" id="empNo" name="empNo" class="form-control"
                 placeholder="请输入工号" value="${empNo}" required autofocus autocomplete="off">
        </div>
      </div>

      <div class="form-group">
        <label for="password">密码</label>
        <div class="input-group">
          <span class="icon">&#128274;</span>
          <input type="password" id="password" name="password" class="form-control"
                 placeholder="请输入密码" required autocomplete="off">
        </div>
      </div>

      <button type="submit" class="btn btn-login" id="loginBtn">
        <span id="btnText">登 录</span>
      </button>
    </form>

    <!-- 小程序入口 -->
    <div class="login-divider"><span>或</span></div>
    <a href="${pageContext.request.contextPath}/views/miniapp/login.jsp" class="btn btn-miniapp">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <rect x="5" y="2" width="14" height="20" rx="2"/>
        <line x1="12" y1="18" x2="12.01" y2="18"/>
      </svg>
      小程序移动打卡
    </a>

    <div class="login-footer">
      <span>安全登录 &middot; 数据加密传输</span>
    </div>
  </div>

  <div class="login-back">
    <a href="${pageContext.request.contextPath}/views/common/landing.jsp">&larr; 返回首页</a>
  </div>

  <script>
    document.getElementById('loginForm').addEventListener('submit', function () {
      var btn = document.getElementById('loginBtn');
      var txt = document.getElementById('btnText');
      if (btn.disabled) return false;
      btn.disabled = true;
      btn.classList.add('loading');
      txt.innerHTML = '<div class="loading-spinner" style="width:16px;height:16px;border-width:2px;border-top-color:#fff;margin-right:6px;display:inline-block;vertical-align:middle;"></div>登录中...';
    });
  </script>
</body>
</html>
