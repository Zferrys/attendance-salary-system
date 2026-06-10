<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>请假记录 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .timeline { position: relative; padding-left: 24px; }
    .timeline::before { content: ''; position: absolute; left: 6px; top: 0; bottom: 0; width: 2px; background: var(--border); }
    .timeline-item { position: relative; margin-bottom: 16px; padding: 16px; background: var(--surface); border-radius: 10px; border: 1px solid var(--border); }
    .timeline-item::before { content: ''; position: absolute; left: -23px; top: 20px; width: 12px; height: 12px; border-radius: 50%; background: var(--ink-muted); border: 2px solid var(--bg); }
    .timeline-item.status-待审批::before { background: var(--warning); }
    .timeline-item.status-已批准::before { background: var(--success); }
    .timeline-item.status-已拒绝::before { background: var(--danger); }
    .timeline-item.status-已撤销::before { background: var(--ink-muted); }
    .timeline-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
    .timeline-header .type { font-weight: 600; font-size: 15px; color: var(--ink); }
    .timeline-body { font-size: 13px; color: var(--ink-secondary); line-height: 1.8; }
    .timeline-body strong { color: var(--ink); }
    .timeline-footer { margin-top: 10px; display: flex; justify-content: space-between; align-items: center; }
    .timeline-date { font-size: 12px; color: var(--ink-muted); }
</style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 请假记录</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div>
</nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/employee?action=dashboard">&#127968; 员工首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">请假记录</span>
    </div>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>

    <div style="text-align:right;margin-bottom:16px;">
        <span style="float:left;color:var(--ink-secondary);font-size:14px;line-height:40px;">共 <strong>${totalCount}</strong> 条记录</span>
        <a href="${pageContext.request.contextPath}/employee?action=applyLeave" class="btn btn-primary">&#10133; 新建请假</a>
    </div>

    <!-- 时间线视图 -->
    <div class="timeline">
        <c:forEach items="${leaveList}" var="l">
            <div class="timeline-item status-${l.status}">
                <div class="timeline-header">
                    <span class="type">${l.leaveType}</span>
                    <span class="status-badge status-${l.status}">${l.status}</span>
                </div>
                <div class="timeline-body">
                    <div><strong>时间：</strong>${l.startDate} ~ ${l.endDate}（${l.days}天）</div>
                    <div><strong>原因：</strong>${l.reason}</div>
                </div>
                <div class="timeline-footer">
                    <span class="timeline-date">申请时间：${l.startDate}</span>
                    <c:if test="${l.status == '待审批'}">
                        <a href="${pageContext.request.contextPath}/employee?action=cancelLeave&id=${l.id}"
                           onclick="return confirm('确定撤销此请假申请？');" class="btn btn-danger btn-sm">撤销</a>
                    </c:if>
                </div>
            </div>
        </c:forEach>
        <c:if test="${empty leaveList}">
            <div class="empty-state"><div class="empty-icon">&#128236;</div><p>暂无请假记录</p></div>
        </c:if>
    </div>

    <jsp:include page="/views/common/pagination.jsp"/>

    <div style="text-align:center;margin-top:16px;">
        <a href="${pageContext.request.contextPath}/employee?action=dashboard" class="btn btn-outline">&#8592; 返回首页</a>
    </div>
</div>

<script>
function goPage(p) {
    window.location.href = '${pageContext.request.contextPath}/employee?action=leaveList&page=' + p;
}
</script>
</body>
</html>
