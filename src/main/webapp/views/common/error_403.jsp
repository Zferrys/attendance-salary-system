<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><title>访问被拒绝</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css"></head>
<body style="display:flex;align-items:center;justify-content:center;min-height:100vh;background:#f4f6f9;">
<div style="text-align:center;">
    <h1 style="font-size:80px;color:#e67e22;margin:0;">403</h1>
    <p style="color:#7f8c8d;font-size:18px;">抱歉，您没有权限访问该页面</p>
    <a href="${pageContext.request.contextPath}/views/common/login.jsp" class="btn btn-primary" style="margin-top:16px;">返回登录页</a>
</div></body></html>
