<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>编辑员工 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .form-card { max-width: 650px; margin: 0 auto; }
    .form-section { margin-bottom: 20px; }
    .form-section-title { font-size: 14px; font-weight: 600; color: #4b5563; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #f0f0f0; }
    .form-row { display: flex; gap: 16px; }
    .form-row .form-group { flex: 1; }
    .input-hint { font-size: 12px; color: #9ca3af; margin-top: 4px; }
</style>
</head>
<body>
<nav class="navbar"><div class="navbar-brand">考勤薪资系统 <span>| 编辑员工</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name} (${currentUser.position})</span>
    <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div></nav>

<div class="main-container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/mgr?action=dashboard">&#127968; 主管首页</a>
        <span class="separator">&#8250;</span>
        <a href="${pageContext.request.contextPath}/mgr?action=empList">团队管理</a>
        <span class="separator">&#8250;</span>
        <span class="current">编辑员工</span>
    </div>

    <c:if test="${not empty errorMsg}"><div class="alert alert-danger" style="background:#fee2e2;color:#991b1b;padding:12px;border-radius:8px;margin-bottom:16px;">${errorMsg}</div></c:if>

    <div class="card form-card">
        <div class="card-header">&#9998; 编辑员工信息 - ${editEmp.name}（${editEmp.empNo}）</div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/mgr" method="post" id="empForm">
                <input type="hidden" name="action" value="empUpdate">
                <input type="hidden" name="id" value="${editEmp.id}">
                
                <div class="form-section">
                    <div class="form-section-title">基本信息</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>工号</label>
                            <input class="form-control" value="${editEmp.empNo}" disabled>
                            <div class="input-hint">工号不可修改</div>
                        </div>
                        <div class="form-group">
                            <label>姓名 *</label>
                            <input name="name" value="${editEmp.name}" required class="form-control" placeholder="员工真实姓名">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>新密码</label>
                            <input name="password" class="form-control" placeholder="留空则不修改密码">
                            <div class="input-hint">如需重置密码，请在此输入新密码（系统将自动MD5加密存储）</div>
                        </div>
                        <div class="form-group">
                            <label>邮箱</label>
                            <input name="email" type="email" value="${editEmp.email}" class="form-control" placeholder="如 zhangsan@company.com">
                            <div class="input-hint">用于接收薪资发放通知</div>
                        </div>
                    </div>
                </div>
                
                <div class="form-section">
                    <div class="form-section-title">工作信息</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>部门</label>
                            <input class="form-control" value="${editEmp.deptName}" disabled>
                            <div class="input-hint">部门不可修改</div>
                        </div>
                        <div class="form-group">
                            <label>职位 *</label>
                            <input name="position" value="${editEmp.position}" required class="form-control" placeholder="如 Java开发工程师">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>基本工资(元) *</label>
                            <input name="baseSalary" type="number" step="0.01" value="${editEmp.baseSalary}" required class="form-control" placeholder="如 8000.00">
                        </div>
                        <div class="form-group">
                            <label>入职日期</label>
                            <input class="form-control" value="${editEmp.entryDate}" disabled>
                            <div class="input-hint">入职日期不可修改</div>
                        </div>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">&#128190; 保存修改</button>
                    <a href="${pageContext.request.contextPath}/mgr?action=empList" class="btn btn-outline">返回列表</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.getElementById('empForm').addEventListener('submit', function(e) {
    var name = this.querySelector('[name="name"]').value.trim();
    if (!name) {
        alert('姓名不能为空！');
        e.preventDefault();
        return;
    }
    showLoading('正在保存员工信息...');
});
</script>
</body>
</html>
