<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>考勤管理 - 管理后台</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .filter-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: center;
            margin-bottom: 20px;
            padding: 16px;
            background: var(--surface);
            border-radius: 10px;
            border: 1px solid var(--border);
        }
        .filter-bar label {
            font-size: 13px;
            color: var(--ink-secondary);
            font-weight: 500;
        }
        .filter-bar select, .filter-bar input {
            padding: 7px 12px;
            border: 1px solid var(--border);
            border-radius: 6px;
            font-size: 13px;
            background: rgba(255,255,255,0.04);
            color: var(--ink);
        }
        .filter-bar select option {
            background: var(--bg-elevated);
            color: var(--ink);
        }
        .filter-bar .btn {
            padding: 7px 18px;
            font-size: 13px;
        }
        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            background: var(--surface);
            border-radius: 10px;
            overflow: hidden;
            border: 1px solid var(--border);
        }
        .attendance-table th {
            background: var(--surface-hover);
            padding: 12px 14px;
            text-align: left;
            font-size: 13px;
            font-weight: 600;
            color: var(--ink);
            border-bottom: 1px solid var(--border);
        }
        .attendance-table td {
            padding: 12px 14px;
            font-size: 13px;
            color: var(--ink-secondary);
            border-bottom: 1px solid var(--border-light);
        }
        .attendance-table tr:hover { background: var(--surface-hover); }
        .status-tag {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }
        .status-normal { background: var(--success-soft); color: var(--success); }
        .status-late { background: var(--warning-soft); color: var(--warning); }
        .status-early { background: var(--danger-soft); color: var(--danger); }
        .status-absent { background: rgba(255,255,255,0.06); color: var(--ink-muted); }
        .empty-tip {
            text-align: center;
            padding: 40px;
            color: var(--ink-muted);
            font-size: 14px;
        }
        .stats-bar {
            display: flex;
            gap: 16px;
            margin-bottom: 20px;
        }
        .stats-item {
            background: var(--surface);
            padding: 12px 20px;
            border-radius: 10px;
            border: 1px solid var(--border);
            font-size: 13px;
        }
        .stats-item strong {
            font-size: 20px;
            color: var(--ink);
            margin-right: 4px;
        }
        .action-btns {
            display: flex;
            gap: 6px;
        }
        .action-btns .btn {
            padding: 4px 10px;
            font-size: 12px;
            border-radius: 4px;
            text-decoration: none;
        }
        .btn-edit {
            background: var(--info-soft);
            color: var(--info);
            border: 1px solid var(--info-border);
        }
        .btn-edit:hover {
            background: rgba(167,139,250,0.15);
        }
        .btn-delete {
            background: var(--danger-soft);
            color: var(--danger);
            border: 1px solid var(--danger-border);
        }
        .btn-delete:hover {
            background: rgba(248,113,113,0.15);
        }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 管理后台</span></div>
    <div class="navbar-right">
        <span class="user-info">${currentUser.name} (管理员)</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a>
    </div>
</nav>

<div class="main-container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/admin?action=dashboard">&#127968; 管理首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">考勤管理</span>
    </div>

    <h2 class="page-title">&#128197; 考勤管理</h2>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>
    <c:if test="${not empty errorMsg}"><div class="alert alert-error">${errorMsg}</div></c:if>

    <!-- 统计概览 -->
    <div class="stats-bar">
        <div class="stats-item"><strong>${recordList.size()}</strong>条记录</div>
        <div class="stats-item" style="color:var(--success);"><strong id="statNormal">0</strong>正常</div>
        <div class="stats-item" style="color:var(--warning);"><strong id="statLate">0</strong>迟到</div>
        <div class="stats-item" style="color:var(--danger);"><strong id="statEarly">0</strong>早退</div>
        <div class="stats-item" style="color:var(--ink-muted);"><strong id="statAbsent">0</strong>缺勤</div>
    </div>

    <!-- 筛选栏 -->
    <form id="filterForm" class="filter-bar" method="get" action="${pageContext.request.contextPath}/admin">
        <input type="hidden" name="action" value="attendanceList">
        <input type="hidden" name="page" id="pageInput" value="${currentPage}">
        <label>部门：</label>
        <select name="deptId">
            <option value="">全部部门</option>
            <c:forEach var="d" items="${deptList}">
                <option value="${d.id}" ${deptId == d.id ? 'selected' : ''}>${d.deptName}</option>
            </c:forEach>
        </select>
        <label>日期从：</label>
        <input type="date" name="startDate" value="${startDate}">
        <label>到：</label>
        <input type="date" name="endDate" value="${endDate}">
        <label>状态：</label>
        <select name="status">
            <option value="">全部</option>
            <option value="正常" ${status == '正常' ? 'selected' : ''}>正常</option>
            <option value="迟到" ${status == '迟到' ? 'selected' : ''}>迟到</option>
            <option value="早退" ${status == '早退' ? 'selected' : ''}>早退</option>
            <option value="缺勤" ${status == '缺勤' ? 'selected' : ''}>缺勤</option>
        </select>
        <button type="submit" class="btn btn-primary" onclick="document.getElementById('pageInput').value='1'">&#128269; 查询</button>
        <a href="${pageContext.request.contextPath}/admin?action=attendanceList" class="btn btn-secondary">重置</a>
    </form>

    <!-- 考勤记录表格 -->
    <table class="attendance-table">
        <thead>
            <tr>
                <th>员工姓名</th>
                <th>部门</th>
                <th>日期</th>
                <th>上班时间</th>
                <th>下班时间</th>
                <th>工时</th>
                <th>状态</th>
                <th>操作</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="r" items="${recordList}">
                <tr>
                    <td><strong>${r.empName}</strong></td>
                    <td>${r.deptName != null ? r.deptName : '--'}</td>
                    <td>${r.workDate}</td>
                    <td>${r.checkInTime != null ? r.checkInTime : '--'}</td>
                    <td>${r.checkOutTime != null ? r.checkOutTime : '--'}</td>
                    <td>${r.workHours != null ? r.workHours : '--'}${r.workHours != null ? 'h' : ''}</td>
                    <td>
                        <span class="status-tag status-${r.status == '正常' ? 'normal' : r.status == '迟到' ? 'late' : r.status == '早退' ? 'early' : 'absent'}">
                            ${r.status}
                        </span>
                    </td>
                    <td>
                        <div class="action-btns">
                            <a href="${pageContext.request.contextPath}/admin?action=attendanceEdit&id=${r.id}"
                               class="btn btn-edit">编辑</a>
                            <a href="${pageContext.request.contextPath}/admin?action=attendanceDelete&id=${r.id}"
                               class="btn btn-delete"
                               onclick="return confirm('确定要删除这条考勤记录吗？')">删除</a>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty recordList}">
                <tr><td colspan="8" class="empty-tip">暂无考勤记录，请调整筛选条件</td></tr>
            </c:if>
        </tbody>
    </table>
    <jsp:include page="/views/common/pagination.jsp"/>
</div>

<script>
function goPage(p) {
    document.getElementById('pageInput').value = p;
    document.getElementById('filterForm').submit();
}
</script>
<script>
    // 统计各状态数量
    var normal = 0, late = 0, early = 0, absent = 0;
    <c:forEach var="r" items="${recordList}">
        var s = '${r.status}';
        if (s === '正常') normal++;
        else if (s === '迟到') late++;
        else if (s === '早退') early++;
        else if (s === '缺勤') absent++;
    </c:forEach>
    document.getElementById('statNormal').textContent = normal;
    document.getElementById('statLate').textContent = late;
    document.getElementById('statEarly').textContent = early;
    document.getElementById('statAbsent').textContent = absent;
</script>
</body>
</html>
