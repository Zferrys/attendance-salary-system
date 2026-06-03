<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>请假审批 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .review-card { background: #fff; border-radius: 12px; padding: 20px; margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); border: 1px solid #f0f0f0; transition: all 0.25s; }
    .review-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); border-color: #e5e7eb; }
    .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
    .review-user { display: flex; align-items: center; gap: 10px; }
    .review-avatar { width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, #1a73e8, #4a90d9); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 16px; font-weight: 600; }
    .review-name { font-weight: 600; color: #1f2937; }
    .review-dept { font-size: 12px; color: #6b7280; }
    .review-body { font-size: 14px; color: #4b5563; line-height: 1.8; padding: 12px 0; border-top: 1px solid #f0f0f0; border-bottom: 1px solid #f0f0f0; }
    .review-body .info-row { display: flex; gap: 20px; flex-wrap: wrap; }
    .review-body .info-row span { display: flex; align-items: center; gap: 4px; }
    .review-actions { display: flex; gap: 10px; margin-top: 14px; justify-content: flex-end; }
    .review-reason { background: #f8fafc; padding: 10px 14px; border-radius: 8px; margin-top: 10px; font-size: 13px; color: #6b7280; }
</style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 请假审批</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div>
</nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/manager?action=dashboard">&#127968; 主管首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">请假审批</span>
    </div>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>

    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
        <h3 style="font-size:18px;font-weight:700;color:#1f2937;">待审批的请假申请 <span style="font-size:14px;color:#6b7280;font-weight:400;">(${leaveList.size()} 条)</span></h3>
        <a href="${pageContext.request.contextPath}/manager?action=dashboard" class="btn btn-outline btn-sm">&#8592; 返回首页</a>
    </div>

    <c:forEach items="${leaveList}" var="l">
        <div class="review-card">
            <div class="review-header">
                <div class="review-user">
                    <div class="review-avatar">${fn:substring(l.empName, 0, 1)}</div>
                    <div>
                        <div class="review-name">${l.empName}</div>
                        <div class="review-dept">${l.leaveType}</div>
                    </div>
                </div>
                <span class="status-badge status-待审批">待审批</span>
            </div>
            <div class="review-body">
                <div class="info-row">
                    <span>&#128197; <strong>${l.startDate}</strong> 至 <strong>${l.endDate}</strong></span>
                    <span>&#9200; 共 <strong>${l.days}</strong> 天</span>
                </div>
                <div class="review-reason">
                    <strong>请假原因：</strong>${l.reason}
                </div>
            </div>
            <div class="review-actions">
                <form action="${pageContext.request.contextPath}/manager" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="approveLeave">
                    <input type="hidden" name="id" value="${l.id}">
                    <input type="hidden" name="status" value="已拒绝">
                    <button type="submit" class="btn btn-danger btn-sm" data-confirm="确定拒绝 ${l.empName} 的请假申请？">&#10060; 拒绝</button>
                </form>
                <form action="${pageContext.request.contextPath}/manager" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="approveLeave">
                    <input type="hidden" name="id" value="${l.id}">
                    <input type="hidden" name="status" value="已批准">
                    <button type="submit" class="btn btn-success btn-sm" data-confirm="确定批准 ${l.empName} 的请假申请？">&#9989; 批准</button>
                </form>
            </div>
        </div>
    </c:forEach>
    <c:if test="${empty leaveList}">
        <div class="card"><div class="card-body empty-state">
            <div class="empty-icon">&#127881;</div>
            <p>暂无待审批的请假申请</p>
        </div></div>
    </c:if>
</div>
</body>
</html>
