<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>团队员工管理 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .member-card {
        display: flex; align-items: center; gap: 16px;
        padding: 16px 20px; background: var(--surface); border-radius: 10px;
        margin-bottom: 10px; border: 1px solid var(--border);
        transition: all 0.2s;
    }
    .member-card:hover { transform: translateY(-2px); border-color: var(--border-glow); background: var(--surface-hover); }
    .member-avatar {
        width: 48px; height: 48px; border-radius: 50%;
        background: linear-gradient(135deg, #38bdf8, #818cf8);
        color: #0a0e1a; display: flex; align-items: center; justify-content: center;
        font-size: 20px; font-weight: 700; flex-shrink: 0;
    }
    .member-info { flex: 1; }
    .member-info .name { font-size: 15px; font-weight: 600; color: var(--ink); }
    .member-info .detail { font-size: 13px; color: var(--ink-secondary); margin-top: 2px; }
    .member-status { font-size: 12px; font-weight: 600; padding: 4px 12px; border-radius: 20px; }
    .member-status.active { background: var(--success-soft); color: var(--success); }
    .member-status.inactive { background: var(--danger-soft); color: var(--danger); }
    .member-actions { display: flex; gap: 8px; flex-shrink: 0; }
    .btn-xs { padding: 5px 12px; font-size: 12px; border-radius: 6px; }
</style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 团队管理</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name} (${currentUser.position})</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div>
</nav>

<div class="main-container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/mgr?action=dashboard">&#127968; 主管首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">团队员工</span>
    </div>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>
    <c:if test="${not empty errorMsg}"><div class="alert alert-danger" style="background:var(--danger-soft);color:var(--danger);border:1px solid var(--danger-border);padding:12px;border-radius:8px;margin-bottom:16px;">${errorMsg}</div></c:if>

    <div class="filter-bar">
        <span style="font-weight:600;">团队成员列表（共 ${totalCount != null ? totalCount : teamMembers.size()} 人）</span>
        <a href="${pageContext.request.contextPath}/mgr?action=dashboard" class="btn btn-outline btn-sm">返回首页</a>
    </div>

    <div class="card">
        <div class="card-header">团队员工</div>
        <div class="card-body">
            <c:forEach items="${teamMembers}" var="m">
                <div class="member-card">
                    <div class="member-avatar">${fn:substring(m.name, 0, 1)}</div>
                    <div class="member-info">
                        <div class="name">${m.name} <code style="background:var(--surface);color:var(--ink-muted);padding:2px 8px;border-radius:4px;font-size:12px;">${m.empNo}</code></div>
                        <div class="detail">${m.position} &nbsp;|&nbsp; 入职：${m.entryDate} &nbsp;|&nbsp; 基本工资：¥ ${m.baseSalary}</div>
                    </div>
                    <span class="member-status ${m.leaveDate == null ? 'active' : 'inactive'}">
                        ${m.leaveDate == null ? '在职' : '已离职'}
                    </span>
                    <div class="member-actions">
                        <a href="${pageContext.request.contextPath}/mgr?action=empEdit&id=${m.id}" class="btn btn-info btn-xs">&#9998; 编辑</a>
                        <a href="javascript:void(0)" onclick="confirmDelete(${m.id}, '${m.name}', '${m.empNo}')" class="btn btn-danger btn-xs">&#128465; 删除</a>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty teamMembers}">
                <div class="empty-state">
                    <div class="empty-icon">&#128101;</div>
                    <p>暂无团队成员数据</p>
                </div>
            </c:if>
        </div>
    </div>

    <jsp:include page="/views/common/pagination.jsp"/>
</div>

<script>
function goPage(p) {
    window.location.href = '${pageContext.request.contextPath}/mgr?action=empList&page=' + p;
}
function confirmDelete(id, name, empNo) {
    if (confirm('确定要删除员工 "' + name + '（' + empNo + '）" 吗？\n\n删除后将设置离职日期，该员工将无法登录系统。')) {
        window.location.href = '${pageContext.request.contextPath}/mgr?action=empDelete&id=' + id;
    }
}
</script>
</body>
</html>
