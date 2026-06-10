<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>500 - 服务器错误</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body style="display:flex;align-items:center;justify-content:center;min-height:100vh;background:var(--bg);">
<div style="text-align:center;padding:40px;">
  <div style="font-size:5rem;font-weight:800;color:var(--danger);line-height:1;margin-bottom:8px;">500</div>
  <p style="font-size:1.05rem;color:var(--ink-secondary);margin-bottom:20px;">服务器内部错误，请联系管理员</p>
  <a href="${pageContext.request.contextPath}/views/common/login.jsp" class="btn btn-primary">返回登录页</a>
</div></body></html>
