<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>管理后台 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .dashboard-welcome { font-size: 15px; color: #6b7280; margin-bottom: 20px; }
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
    .stat-number { font-size: 32px; font-weight: 700; color: #1f2937; line-height: 1; }
    .recent-activity { margin-top: 8px; }
    .activity-item { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f0f0f0; font-size: 13px; }
    .activity-item:last-child { border-bottom: none; }
    .activity-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
</style>
</head>
<body>
<nav class="navbar"><div class="navbar-brand">考勤薪资系统 <span>| 管理后台</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name} (管理员)</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div></nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/admin?action=dashboard">&#127968; 管理首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">数据概览</span>
    </div>

    <p class="dashboard-welcome">欢迎回来，${currentUser.name}！今天是 <span id="todayDate"></span></p>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>

    <!-- 统计卡片 -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background:linear-gradient(135deg,#1a73e8,#4a90d9);">&#128101;</div>
            <div class="stat-info"><div class="stat-value">${totalEmps}</div><div class="stat-label">员工总数</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:linear-gradient(135deg,#6366f1,#818cf8);">&#127970;</div>
            <div class="stat-info"><div class="stat-value">${totalDepts}</div><div class="stat-label">部门数量</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:linear-gradient(135deg,#0d9e6c,#34d399);">&#128176;</div>
            <div class="stat-info"><div class="stat-value">薪资管理</div><div class="stat-label">生成与发放</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:linear-gradient(135deg,#f0a020,#fbbf24);">&#128203;</div>
            <div class="stat-info"><div class="stat-value">报表导出</div><div class="stat-label">Excel/打印</div></div>
        </div>
    </div>

    <!-- 功能入口网格 -->
    <div class="feature-grid">
        <a href="${pageContext.request.contextPath}/admin?action=empList" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#dbeafe,#eff6ff); color:#1a73e8;">&#128100;</div>
            <div class="feature-info">
                <h3>员工信息管理</h3>
                <p>查看、搜索、添加员工信息，支持按部门和姓名筛选</p>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=attendanceList" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#fce7f3,#fdf2f8); color:#db2777;">&#128197;</div>
            <div class="feature-info">
                <h3>考勤管理</h3>
                <p>查看所有员工考勤记录，支持按部门、日期、状态筛选</p>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=salaryList" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#d1fae5,#ecfdf5); color:#0d9e6c;">&#128176;</div>
            <div class="feature-info">
                <h3>薪资管理与发放</h3>
                <p>生成月度薪资、查看薪资明细、执行薪资发放操作</p>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=empAdd" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#fef3c7,#fffbeb); color:#f0a020;">&#10133;</div>
            <div class="feature-info">
                <h3>添加新员工</h3>
                <p>录入新员工基本信息、部门、职位和基本工资</p>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=salaryReport" class="feature-card">
            <div class="feature-icon" style="background:linear-gradient(135deg,#ede9fe,#f5f3ff); color:#6366f1;">&#128202;</div>
            <div class="feature-info">
                <h3>月度薪资报表</h3>
                <p>查看月度薪资汇总，支持导出和打印薪资条</p>
            </div>
        </a>
    </div>

    <!-- 快捷操作提示 -->
    <div class="card">
        <div class="card-header">&#9889; 快捷操作指南</div>
        <div class="card-body">
            <div class="recent-activity">
                <div class="activity-item">
                    <div class="activity-dot" style="background:#1a73e8;"></div>
                    <span><strong>生成薪资：</strong>进入「薪资管理」选择月份，点击「生成当月薪资」按钮</span>
                </div>
                <div class="activity-item">
                    <div class="activity-dot" style="background:#0d9e6c;"></div>
                    <span><strong>发放薪资：</strong>在薪资列表中找到「未发放」记录，点击「发放」按钮</span>
                </div>
                <div class="activity-item">
                    <div class="activity-dot" style="background:#f0a020;"></div>
                    <span><strong>添加员工：</strong>点击「添加新员工」，填写基本信息后保存</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // 显示今日日期
    var now = new Date();
    var weekdays = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
    document.getElementById('todayDate').textContent = 
        now.getFullYear() + '年' + (now.getMonth()+1) + '月' + now.getDate() + '日 ' + weekdays[now.getDay()];
</script>
</body>
</html>
