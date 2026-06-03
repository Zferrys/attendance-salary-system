<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>主管面板 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .dashboard-welcome { font-size: 15px; color: #6b7280; margin-bottom: 20px; }
    .pending-badge {
        background: #dc3545; color: #fff; font-size: 11px; font-weight: 700;
        padding: 2px 8px; border-radius: 10px; margin-left: 6px;
    }
    .feature-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 18px; margin-bottom: 24px; }
    .feature-card {
        background: #fff; border-radius: 12px; padding: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.06); transition: all 0.3s;
        border: 1px solid transparent; cursor: pointer; text-decoration: none; color: inherit;
        display: flex; align-items: flex-start; gap: 16px;
    }
    .feature-card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(0,0,0,0.1); border-color: #e5e7eb; }
    .feature-icon { width: 52px; height: 52px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; flex-shrink: 0; }
    .feature-info h3 { font-size: 16px; font-weight: 600; color: #1f2937; margin-bottom: 4px; }
    .feature-info p { font-size: 13px; color: #6b7280; line-height: 1.5; }
    .leave-preview-item {
        display: flex; align-items: center; gap: 12px;
        padding: 12px 16px; background: #f8fafc; border-radius: 8px;
        margin-bottom: 8px; font-size: 13px; transition: all 0.2s;
    }
    .leave-preview-item:hover { background: #eff6ff; }
    .leave-preview-item .name { font-weight: 600; color: #1f2937; min-width: 60px; }
    .leave-preview-item .info { color: #6b7280; flex: 1; }
    .leave-preview-item .days { color: #f0a020; font-weight: 600; }
</style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 主管面板</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name} (${currentUser.position})</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div>
</nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/manager?action=dashboard">&#127968; 主管首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">工作台</span>
    </div>

    <p class="dashboard-welcome">欢迎回来，${currentUser.name}！今天是 <span id="todayDate"></span></p>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>

    <!-- 待审批统计 -->
    <div class="stat-grid">
        <div class="stat-card" style="border-left:4px solid #f97316;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#f97316,#fb923c);">&#128203;</div>
            <div class="stat-info">
                <div class="stat-value">${pendingCount != null ? pendingCount : 0}</div>
                <div class="stat-label">待审批请假申请</div>
            </div>
        </div>
        <div class="stat-card" style="border-left:4px solid #1a73e8;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#1a73e8,#4a90d9);">&#128101;</div>
            <div class="stat-info">
                <div class="stat-value">团队管理</div>
                <div class="stat-label">查看团队考勤</div>
            </div>
        </div>
        <div class="stat-card" style="border-left:4px solid #0d9e6c;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#0d9e6c,#34d399);">&#128176;</div>
            <div class="stat-info">
                <div class="stat-value">薪资查看</div>
                <div class="stat-label">个人薪资明细</div>
            </div>
        </div>
    </div>

    <!-- 功能入口 -->
    <div class="feature-grid">
        <a href="${pageContext.request.contextPath}/manager?action=leaveReview" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#dbeafe,#eff6ff); color:#1a73e8;">&#9989;</div>
            <div class="feature-info">
                <h3>审批请假申请 <c:if test="${pendingCount > 0}"><span class="pending-badge">${pendingCount}</span></c:if></h3>
                <p>查看并审批下属的请假申请，支持批准或拒绝操作</p>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/manager?action=teamAttend" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#d1fae5,#ecfdf5); color:#0d9e6c;">&#128202;</div>
            <div class="feature-info">
                <h3>团队考勤统计</h3>
                <p>查看部门成员的月度考勤情况，包括正常、迟到、早退、缺勤</p>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/manager?action=empList" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#e0e7ff,#eef2ff); color:#4f46e5;">&#128101;</div>
            <div class="feature-info">
                <h3>团队员工管理</h3>
                <p>查看和管理部门内所有员工的详细信息</p>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/manager?action=salaryView" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#fef3c7,#fffbeb); color:#f0a020;">&#128176;</div>
            <div class="feature-info">
                <h3>我的薪资</h3>
                <p>查看个人月度薪资明细，包括基本工资、扣款和实发工资</p>
            </div>
        </a>
    </div>

    <!-- 最近待审批记录 -->
    <div class="card">
        <div class="card-header">最近待审批请假
            <a href="${pageContext.request.contextPath}/manager?action=leaveReview" class="btn btn-outline btn-sm">查看全部</a>
        </div>
        <div class="card-body">
            <c:forEach items="${pendingLeaves}" var="l">
                <div class="leave-preview-item">
                    <span class="name">${l.empName}</span>
                    <span class="info">${l.leaveType} · ${l.startDate} 至 ${l.endDate}</span>
                    <span class="days">${l.days}天</span>
                </div>
            </c:forEach>
            <c:if test="${empty pendingLeaves}">
                <div class="empty-state"><div class="empty-icon">&#127881;</div><p>暂无待审批的申请</p></div>
            </c:if>
        </div>
    </div>
</div>

<script>
    var now = new Date();
    var weekdays = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
    document.getElementById('todayDate').textContent = 
        now.getFullYear() + '年' + (now.getMonth()+1) + '月' + now.getDate() + '日 ' + weekdays[now.getDay()];
</script>
</body>
</html>
