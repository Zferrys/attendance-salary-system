<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>添加员工 - 考勤薪资系统</title>
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
<nav class="navbar"><div class="navbar-brand">考勤薪资系统 <span>| 添加员工</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
    <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div></nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/admin?action=dashboard">&#127968; 管理首页</a>
        <span class="separator">&#8250;</span>
        <a href="${pageContext.request.contextPath}/admin?action=empList">员工管理</a>
        <span class="separator">&#8250;</span>
        <span class="current">添加员工</span>
    </div>

    <div class="card form-card">
        <div class="card-header">&#128221; 添加新员工</div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin" method="post" id="empForm">
                <input type="hidden" name="action" value="empAdd">
                
                <div class="form-section">
                    <div class="form-section-title">基本信息</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>角色 *</label>
                            <select id="roleSelect" required class="form-control" onchange="updateEmpNoHint()">
                                <option value="E">普通员工（E 开头）</option>
                                <option value="M">主管（M 开头）</option>
                                <option value="A">管理员（A 开头）</option>
                            </select>
                            <div class="input-hint">选择角色后，工号前缀会自动匹配</div>
                        </div>
                        <div class="form-group">
                            <label>姓名 *</label>
                            <input name="name" required class="form-control" placeholder="员工真实姓名">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>工号</label>
                            <input name="empNo" id="empNo" class="form-control" readonly style="background:#f3f4f6;color:#6b7280;">
                            <div class="input-hint" id="empNoHint">选择角色后系统将自动生成工号</div>
                        </div>
                        <div class="form-group">
                            <label>密码 *</label>
                            <input name="password" value="123456" class="form-control">
                            <div class="input-hint">默认密码 123456，系统将自动MD5加密存储</div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>邮箱</label>
                        <input name="email" type="email" class="form-control" placeholder="如 zhangsan@company.com">
                        <div class="input-hint">用于接收薪资发放通知</div>
                    </div>
                </div>
                
                <div class="form-section">
                    <div class="form-section-title">工作信息</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>部门 *</label>
                            <select name="deptId" required class="form-control">
                                <option value="">-- 请选择部门 --</option>
                                <c:forEach items="${deptList}" var="d"><option value="${d.id}">${d.deptName}</option></c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>职位 *</label>
                            <input name="position" required class="form-control" placeholder="如 Java开发工程师">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>基本工资(元) *</label>
                            <input name="baseSalary" type="number" step="0.01" required class="form-control" placeholder="如 8000.00">
                        </div>
                        <div class="form-group">
                            <label>入职日期 *</label>
                            <input name="entryDate" type="date" required class="form-control">
                        </div>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">&#128190; 保存</button>
                    <a href="${pageContext.request.contextPath}/admin?action=empList" class="btn btn-outline">返回列表</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// 根据角色自动生成工号
function updateEmpNoHint() {
    var role = document.getElementById('roleSelect').value;
    var empNoInput = document.getElementById('empNo');
    var hint = document.getElementById('empNoHint');
    var labels = {'E': '员工', 'M': '主管', 'A': '管理员'};
    
    // 调用后端接口获取该角色下一个可用工号
    empNoInput.value = '正在生成...';
    fetch('${pageContext.request.contextPath}/admin?action=getNextEmpNo&prefix=' + role)
        .then(function(resp) { return resp.json(); })
        .then(function(data) {
            empNoInput.value = data.empNo;
            hint.textContent = '系统自动生成 ' + labels[role] + ' 工号：' + data.empNo;
        })
        .catch(function() {
            // fallback: 简单递增
            var ts = new Date().getTime().toString().slice(-4);
            empNoInput.value = role + ts;
            hint.textContent = '系统自动生成 ' + labels[role] + ' 工号：' + empNoInput.value;
        });
}

// 页面加载时自动生成初始工号
window.addEventListener('DOMContentLoaded', function() {
    updateEmpNoHint();
});

// 表单验证
document.getElementById('empForm').addEventListener('submit', function(e) {
    var empNo = this.querySelector('[name="empNo"]').value.trim();
    if (!empNo) {
        alert('工号不能为空，请重新选择角色！');
        e.preventDefault();
        return;
    }
    showLoading('正在保存员工信息...');
});
</script>
</body>
</html>
