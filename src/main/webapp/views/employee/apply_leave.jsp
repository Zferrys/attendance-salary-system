<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>请假申请 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .leave-form-card { max-width: 600px; margin: 0 auto; }
    .leave-type-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 16px; }
    .leave-type-option {
        padding: 14px; border: 2px solid #e5e7eb; border-radius: 10px;
        text-align: center; cursor: pointer; transition: all 0.25s;
        background: #fff;
    }
    .leave-type-option:hover { border-color: #1a73e8; }
    .leave-type-option.selected { border-color: #1a73e8; background: #eff6ff; }
    .leave-type-option .icon { font-size: 24px; margin-bottom: 6px; }
    .leave-type-option .name { font-size: 14px; font-weight: 600; color: #1f2937; }
    .leave-type-option .desc { font-size: 11px; color: #6b7280; margin-top: 2px; }
    .days-preview { background: #f8fafc; padding: 12px 16px; border-radius: 8px; font-size: 14px; color: #4b5563; margin-top: 8px; }
    .days-preview strong { color: #1a73e8; }
</style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 请假申请</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div>
</nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/employee?action=dashboard">&#127968; 员工首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">请假申请</span>
    </div>

    <c:if test="${not empty errorMsg}"><div class="alert alert-danger">${errorMsg}</div></c:if>

    <div class="card leave-form-card">
        <div class="card-header">&#128221; 提交请假申请</div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/employee" method="post" id="leaveForm">
                <input type="hidden" name="action" value="applyLeave">
                <input type="hidden" name="leaveType" id="leaveTypeInput" value="">

                <div class="form-group">
                    <label>请假类型</label>
                    <div class="leave-type-grid">
                        <div class="leave-type-option" data-type="事假" onclick="selectLeaveType(this)">
                            <div class="icon">&#128100;</div>
                            <div class="name">事假</div>
                            <div class="desc">扣除当日工资</div>
                        </div>
                        <div class="leave-type-option" data-type="病假" onclick="selectLeaveType(this)">
                            <div class="icon">&#127973;</div>
                            <div class="name">病假</div>
                            <div class="desc">需提供证明</div>
                        </div>
                        <div class="leave-type-option" data-type="年假" onclick="selectLeaveType(this)">
                            <div class="icon">&#127796;</div>
                            <div class="name">年假</div>
                            <div class="desc">带薪休假</div>
                        </div>
                    </div>
                </div>

                <div style="display:flex;gap:12px;">
                    <div class="form-group" style="flex:1;">
                        <label>开始日期 *</label>
                        <input type="date" name="startDate" id="startDate" class="form-control" required onchange="calcDays()">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>结束日期 *</label>
                        <input type="date" name="endDate" id="endDate" class="form-control" required onchange="calcDays()">
                    </div>
                </div>
                <div class="days-preview" id="daysPreview" style="display:none;">
                    共计请假 <strong id="daysCount">0</strong> 天
                </div>

                <div class="form-group">
                    <label>请假原因 *</label>
                    <textarea name="reason" class="form-control" rows="3"
                              placeholder="请详细描述请假原因..." required></textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">&#128228; 提交申请</button>
                    <a href="${pageContext.request.contextPath}/employee?action=dashboard"
                       class="btn btn-outline">返回首页</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function selectLeaveType(el) {
    document.querySelectorAll('.leave-type-option').forEach(function(o) { o.classList.remove('selected'); });
    el.classList.add('selected');
    document.getElementById('leaveTypeInput').value = el.dataset.type;
}

function calcDays() {
    var s = document.getElementById('startDate').value;
    var e = document.getElementById('endDate').value;
    if (s && e) {
        var start = new Date(s);
        var end = new Date(e);
        if (end >= start) {
            var days = Math.floor((end - start) / (1000 * 60 * 60 * 24)) + 1;
            document.getElementById('daysCount').textContent = days;
            document.getElementById('daysPreview').style.display = 'block';
        }
    }
}

// 默认选中第一个
document.querySelector('.leave-type-option').click();

// 表单验证
document.getElementById('leaveForm').addEventListener('submit', function(e) {
    if (!document.getElementById('leaveTypeInput').value) {
        alert('请选择请假类型！');
        e.preventDefault();
        return;
    }
    var s = document.getElementById('startDate').value;
    var en = document.getElementById('endDate').value;
    if (s && en && new Date(en) < new Date(s)) {
        alert('结束日期不能早于开始日期！');
        e.preventDefault();
        return;
    }
    showLoading('正在提交请假申请...');
});
</script>
</body>
</html>
