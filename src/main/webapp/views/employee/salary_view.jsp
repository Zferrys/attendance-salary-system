<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>薪资详情 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .salary-card { max-width: 600px; margin: 0 auto; }
    .salary-header { text-align: center; padding: 24px; background: linear-gradient(135deg, #1e3a5f, #2980b9); color: #fff; border-radius: 10px 10px 0 0; }
    .salary-header h2 { font-size: 20px; margin-bottom: 4px; }
    .salary-header p { opacity: 0.85; font-size: 13px; }
    .salary-body { padding: 24px; }
    .salary-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px dashed #e5e7eb; font-size: 14px; }
    .salary-row .label { color: #6b7280; }
    .salary-row .value { font-weight: 600; color: #1f2937; }
    .salary-row.total { border-bottom: none; border-top: 2px solid #1a73e8; margin-top: 8px; padding-top: 16px; }
    .salary-row.total .value { font-size: 20px; color: #0d9e6c; }
    .salary-footer { text-align: center; padding: 16px; background: #f8fafc; border-radius: 0 0 10px 10px; font-size: 12px; color: #9ca3af; }
    .history-list { margin-top: 20px; }
    .history-item { display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; background: #f8fafc; border-radius: 8px; margin-bottom: 8px; font-size: 14px; transition: all 0.2s; }
    .history-item:hover { background: #eff6ff; }
    .history-item .month { font-weight: 600; color: #1f2937; }
    .history-item .amount { font-weight: 700; color: #0d9e6c; }
</style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 薪资详情</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div>
</nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/employee?action=dashboard">&#127968; 员工首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">薪资详情</span>
    </div>

    <div class="filter-bar">
        <form method="get" style="display:flex;align-items:center;gap:12px;">
            <input type="hidden" name="action" value="salaryView">
            <label>&#128197; 选择月份：</label>
            <input type="month" name="yearMonth" value="${yearMonth}">
            <button type="submit" class="btn btn-primary btn-sm">&#128269; 查询</button>
        </form>
        <a href="${pageContext.request.contextPath}/employee?action=dashboard" class="btn btn-outline btn-sm">返回首页</a>
    </div>

    <c:if test="${salary != null}">
        <!-- 薪资明细卡片 -->
        <div class="card salary-card">
            <div class="salary-header">
                <h2>&#128176; ${yearMonth} 薪资条</h2>
                <p>${currentUser.name} | ${currentUser.empNo} | <span class="status-badge status-${salary.status}" style="color:#fff;background:rgba(255,255,255,0.2);">${salary.status}</span></p>
            </div>
            <div class="salary-body">
                <div class="salary-row"><span class="label">基本工资</span><span class="value">&#165; ${salary.baseSalary != null ? salary.baseSalary : '0.00'}</span></div>
                <div class="salary-row"><span class="label">全勤奖（无迟到无请假无缺勤发放300元）</span><span class="value" style="color:#0d9e6c;">+ &#165; ${salary.attendanceBonus != null ? salary.attendanceBonus : '0.00'}</span></div>
                <div class="salary-row"><span class="label">加班补贴</span><span class="value" style="color:#0d9e6c;">+ &#165; ${salary.overtimePay != null ? salary.overtimePay : '0.00'}</span></div>
                <div class="salary-row"><span class="label">迟到扣款 (每次=月薪/21.75/8&#215;1h)</span><span class="value" style="color:#dc3545;">- &#165; ${salary.deductionLate != null ? salary.deductionLate : '0.00'}</span></div>
                <div class="salary-row"><span class="label">请假扣款 (日薪=月薪/21.75 &#215; 天数)</span><span class="value" style="color:#dc3545;">- &#165; ${salary.deductionLeave != null ? salary.deductionLeave : '0.00'}</span></div>
                <div class="salary-row total">
                    <span class="label">&#128176; 实际应发工资</span>
                    <span class="value">&#165; ${salary.actualSalary != null ? salary.actualSalary : '0.00'}</span>
                </div>
                <div class="salary-row"><span class="label">生成时间</span><span class="value">${salary.generateTime}</span></div>
                <c:if test="${salary.payTime != null}">
                    <div class="salary-row"><span class="label">发放时间</span><span class="value" style="color:#0d9e6c;">${salary.payTime} &#9989;</span></div>
                </c:if>
            </div>
            <div class="salary-footer">
                本薪资条由系统自动生成，如有疑问请联系人力资源部
                <div style="margin-top:10px;">
                    <button class="btn btn-primary btn-sm" onclick="printSalarySlip()">&#128424; 打印薪资条</button>
                </div>
            </div>
        </div>

        <div class="rule-box">
            <strong>&#128208; 薪资计算规则说明：</strong>
            1. 月平均工作日：21.75天（(365-104双休)/12）<br>
            2. 日薪 = 基本工资 / 21.75<br>
            3. 迟到每次扣款 = 基本工资 / 21.75 / 8 &#215; 1小时<br>
            4. 请假扣款 = 日薪 &#215; 请假天数<br>
            5. 全勤奖：无迟到+无请假+无缺勤 &#8594; 发放300元<br>
            6. 实际工资 = 基本工资 + 全勤奖 - 迟到扣款 - 请假扣款
        </div>
    </c:if>

    <c:if test="${salary == null}">
        <div class="card"><div class="card-body empty-state">
            <div class="empty-icon">&#128203;</div>
            <p>${yearMonth} 的薪资记录尚未生成</p>
            <p style="font-size:13px;color:#9ca3af;margin-top:4px;">请联系管理员生成薪资记录</p>
            <a href="${pageContext.request.contextPath}/employee?action=dashboard" class="btn btn-outline btn-sm" style="margin-top:12px;">&#8592; 返回首页</a>
        </div></div>
    </c:if>
</div>
</body>
</html>
