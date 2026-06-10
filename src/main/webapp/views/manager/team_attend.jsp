<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>团队考勤统计 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .member-card { background: var(--surface); border-radius: 12px; padding: 20px; margin-bottom: 16px; border: 1px solid var(--border); transition: all 0.25s; }
    .member-card:hover { border-color: var(--border-glow); background: var(--surface-hover); }
    .member-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
    .member-info { display: flex; align-items: center; gap: 12px; }
    .member-avatar { width: 44px; height: 44px; border-radius: 50%; background: linear-gradient(135deg, #38bdf8, #818cf8); color: #0a0e1a; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: 600; }
    .member-name { font-weight: 600; color: var(--ink); font-size: 15px; }
    .member-position { font-size: 12px; color: var(--ink-secondary); }
    .member-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
    .member-stat { text-align: center; padding: 10px; background: var(--surface-hover); border-radius: 8px; }
    .member-stat .num { font-size: 20px; font-weight: 700; }
    .member-stat .lbl { font-size: 11px; color: var(--ink-secondary); margin-top: 2px; }
    .member-stat.normal .num { color: var(--success); }
    .member-stat.late .num { color: var(--warning); }
    .member-stat.early .num { color: #f97316; }
    .member-stat.absent .num { color: var(--danger); }
</style>
</head>
<body>
<nav class="navbar"><div class="navbar-brand">考勤薪资系统 <span>| 团队考勤</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
    <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div></nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/mgr?action=dashboard">&#127968; 主管首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">团队考勤</span>
    </div>

    <div class="filter-bar">
        <form method="get" style="display:flex;align-items:center;gap:12px;">
            <input type="hidden" name="action" value="teamAttend">
            <input type="hidden" name="page" value="1">
            <label>&#128197; 月份：</label><input type="month" name="yearMonth" value="${yearMonth}">
            <button class="btn btn-primary btn-sm">&#128269; 查询</button>
        </form>
        <a href="${pageContext.request.contextPath}/mgr?action=dashboard" class="btn btn-outline btn-sm">返回首页</a>
    </div>

    <div style="margin-bottom:16px;">
        <h3 style="font-size:18px;font-weight:700;color:var(--ink);">${yearMonth} 团队成员考勤 <span style="font-size:14px;color:var(--ink-secondary);font-weight:400;">(${totalCount != null ? totalCount : teamMembers.size()} 人)</span></h3>
    </div>

    <c:forEach items="${teamMembers}" var="m">
        <div class="member-card">
            <div class="member-header">
                <div class="member-info">
                    <div class="member-avatar">${fn:substring(m.name, 0, 1)}</div>
                    <div>
                        <div class="member-name">${m.name} <code style="font-size:12px;background:var(--surface);color:var(--ink-muted);padding:2px 6px;border-radius:4px;">${m.empNo}</code></div>
                        <div class="member-position">${m.position}</div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/mgr?action=memberAttend&empId=${m.id}&yearMonth=${yearMonth}" class="btn btn-outline btn-sm">查看明细</a>
            </div>
            <div class="member-stats">
                <% 
                    // 从 attendList 计算当月统计
                    com.attendance.mapper.AttendRecordMapper attendMapper = null;
                    java.util.List<com.attendance.entity.AttendRecord> attendList = m.getAttendList();
                    int normalDays = 0, lateDays = 0, earlyDays = 0, absentDays = 0;
                    if (attendList != null) {
                        for (com.attendance.entity.AttendRecord ar : attendList) {
                            String status = ar.getStatus();
                            if ("正常".equals(status)) normalDays++;
                            else if ("迟到".equals(status)) lateDays++;
                            else if ("早退".equals(status)) earlyDays++;
                            else if ("缺勤".equals(status)) absentDays++;
                        }
                    }
                %>
                <div class="member-stat normal">
                    <div class="num"><%=normalDays%></div>
                    <div class="lbl">正常</div>
                </div>
                <div class="member-stat late">
                    <div class="num"><%=lateDays%></div>
                    <div class="lbl">迟到</div>
                </div>
                <div class="member-stat early">
                    <div class="num"><%=earlyDays%></div>
                    <div class="lbl">早退</div>
                </div>
                <div class="member-stat absent">
                    <div class="num"><%=absentDays%></div>
                    <div class="lbl">缺勤</div>
                </div>
            </div>
        </div>
    </c:forEach>
    <c:if test="${empty teamMembers}">
        <div class="card"><div class="card-body empty-state">
            <div class="empty-icon">&#128101;</div><p>暂无团队成员数据</p>
        </div></div>
    </c:if>

    <jsp:include page="/views/common/pagination.jsp"/>
</div>

<script>
function goPage(p) {
    window.location.href = '${pageContext.request.contextPath}/mgr?action=teamAttend&yearMonth=${yearMonth}&page=' + p;
}
</script>
</body>
</html>
