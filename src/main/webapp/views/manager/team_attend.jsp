<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>团队考勤统计 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .member-card { background: #fff; border-radius: 12px; padding: 20px; margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); border: 1px solid #f0f0f0; transition: all 0.25s; }
    .member-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
    .member-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
    .member-info { display: flex; align-items: center; gap: 12px; }
    .member-avatar { width: 44px; height: 44px; border-radius: 50%; background: linear-gradient(135deg, #1a73e8, #4a90d9); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: 600; }
    .member-name { font-weight: 600; color: #1f2937; font-size: 15px; }
    .member-position { font-size: 12px; color: #6b7280; }
    .member-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
    .member-stat { text-align: center; padding: 10px; background: #f8fafc; border-radius: 8px; }
    .member-stat .num { font-size: 20px; font-weight: 700; }
    .member-stat .lbl { font-size: 11px; color: #6b7280; margin-top: 2px; }
    .member-stat.normal .num { color: #0d9e6c; }
    .member-stat.late .num { color: #f0a020; }
    .member-stat.early .num { color: #f97316; }
    .member-stat.absent .num { color: #dc3545; }
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
            <label>&#128197; 月份：</label><input type="month" name="yearMonth" value="${yearMonth}">
            <button class="btn btn-primary btn-sm">&#128269; 查询</button>
        </form>
        <a href="${pageContext.request.contextPath}/mgr?action=dashboard" class="btn btn-outline btn-sm">返回首页</a>
    </div>

    <div style="margin-bottom:16px;">
        <h3 style="font-size:18px;font-weight:700;color:#1f2937;">${yearMonth} 团队成员考勤 <span style="font-size:14px;color:#6b7280;font-weight:400;">(${teamMembers.size()} 人)</span></h3>
    </div>

    <c:forEach items="${teamMembers}" var="m">
        <div class="member-card">
            <div class="member-header">
                <div class="member-info">
                    <div class="member-avatar">${fn:substring(m.name, 0, 1)}</div>
                    <div>
                        <div class="member-name">${m.name} <code style="font-size:12px;background:#f3f4f6;padding:2px 6px;border-radius:4px;">${m.empNo}</code></div>
                        <div class="member-position">${m.position}</div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/mgr?action=memberAttend&empId=${m.id}&yearMonth=${yearMonth}" class="btn btn-outline btn-sm">查看明细</a>
            </div>
            <div class="member-stats">
                <div class="member-stat normal">
                    <div class="num">--</div>
                    <div class="lbl">正常</div>
                </div>
                <div class="member-stat late">
                    <div class="num">--</div>
                    <div class="lbl">迟到</div>
                </div>
                <div class="member-stat early">
                    <div class="num">--</div>
                    <div class="lbl">早退</div>
                </div>
                <div class="member-stat absent">
                    <div class="num">--</div>
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
</div>
</body>
</html>
