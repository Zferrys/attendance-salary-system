<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>考勤日历 - 考勤薪资系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
    <style>
        .calendar-container { margin-top: 12px; }
        .cal-month-title { text-align: center; font-size: 18px; font-weight: 700; color: #1f2937; margin-bottom: 16px; }
        .cal-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 6px;
        }
        .cal-weekday {
            text-align: center; font-weight: 600; font-size: 13px; color: #6b7280;
            padding: 10px 0; background: #f8fafc; border-radius: 8px;
        }
        .cal-day {
            aspect-ratio: 1; min-height: 72px;
            border-radius: 10px; padding: 6px;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            font-size: 13px; position: relative; cursor: default;
            transition: all 0.2s; border: 2px solid transparent;
        }
        .cal-day:hover { transform: scale(1.05); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .cal-day .day-num { font-size: 16px; font-weight: 700; }
        .cal-day .day-status { font-size: 11px; margin-top: 2px; font-weight: 500; }
        .cal-day.normal { background: #d1fae5; border-color: #a7f3d0; }
        .cal-day.late { background: #fef3c7; border-color: #fde68a; }
        .cal-day.early { background: #ffedd5; border-color: #fed7aa; }
        .cal-day.absent { background: #fee2e2; border-color: #fecaca; }
        .cal-day.rest { background: #f3f4f6; color: #9ca3af; }
        .cal-day.today { border-color: #1a73e8; box-shadow: 0 0 0 3px rgba(26,115,232,0.15); }
        .cal-day.empty { background: transparent; }
        .stats-bar { display: flex; gap: 16px; margin-bottom: 16px; flex-wrap: wrap; }
        .stats-bar .stat-pill {
            display: flex; align-items: center; gap: 6px;
            padding: 8px 14px; background: #fff; border-radius: 20px;
            font-size: 13px; box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
        .stats-bar .stat-pill .dot { width: 10px; height: 10px; border-radius: 50%; }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 考勤日历</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div>
</nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/employee?action=dashboard">&#127968; 员工首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">考勤日历</span>
    </div>

    <!-- 月份选择 -->
    <div class="filter-bar">
        <form method="get" style="display:flex;align-items:center;gap:12px;">
            <input type="hidden" name="action" value="attendView">
            <label>&#128197; 选择月份：</label>
            <input type="month" name="yearMonth" value="${yearMonth}">
            <button type="submit" class="btn btn-primary btn-sm">&#128269; 查询</button>
        </form>
        <a href="${pageContext.request.contextPath}/employee?action=dashboard" class="btn btn-outline btn-sm">返回首页</a>
    </div>

    <!-- 图例 -->
    <div class="stats-bar">
        <div class="stat-pill"><span class="dot" style="background:#d1fae5;"></span>正常</div>
        <div class="stat-pill"><span class="dot" style="background:#fef3c7;"></span>迟到</div>
        <div class="stat-pill"><span class="dot" style="background:#ffedd5;"></span>早退</div>
        <div class="stat-pill"><span class="dot" style="background:#fee2e2;"></span>缺勤</div>
        <div class="stat-pill"><span class="dot" style="background:#f3f4f6;border:1px solid #d1d5db;"></span>休息/无记录</div>
    </div>

    <!-- 统计摘要 -->
    <div class="stat-grid">
        <div class="stat-card" style="border-left:4px solid #0d9e6c;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#0d9e6c,#34d399);">&#10003;</div>
            <div class="stat-info"><div class="stat-value">${stats.normalDays != null ? stats.normalDays : 0}</div><div class="stat-label">正常天数</div></div>
        </div>
        <div class="stat-card" style="border-left:4px solid #f0a020;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#f0a020,#fbbf24);">&#9200;</div>
            <div class="stat-info"><div class="stat-value">${stats.lateDays != null ? stats.lateDays : 0}</div><div class="stat-label">迟到天数</div></div>
        </div>
        <div class="stat-card" style="border-left:4px solid #f97316;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#f97316,#fb923c);">&#127939;</div>
            <div class="stat-info"><div class="stat-value">${stats.earlyDays != null ? stats.earlyDays : 0}</div><div class="stat-label">早退天数</div></div>
        </div>
        <div class="stat-card" style="border-left:4px solid #dc3545;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#dc3545,#f87171);">&#10005;</div>
            <div class="stat-info"><div class="stat-value">${stats.absentDays != null ? stats.absentDays : 0}</div><div class="stat-label">缺勤天数</div></div>
        </div>
    </div>

    <!-- 日历视图 -->
    <div class="card">
        <div class="card-header">${yearMonth} 月度考勤日历</div>
        <div class="card-body">
            <div class="calendar-container">
                <div class="cal-grid" id="calendarGrid">
                    <div class="cal-weekday">日</div>
                    <div class="cal-weekday">一</div>
                    <div class="cal-weekday">二</div>
                    <div class="cal-weekday">三</div>
                    <div class="cal-weekday">四</div>
                    <div class="cal-weekday">五</div>
                    <div class="cal-weekday">六</div>
                </div>
            </div>
            
            <!-- 考勤明细表格 -->
            <div style="margin-top:24px;">
                <h4 style="font-size:15px;font-weight:600;color:#1f2937;margin-bottom:12px;">&#128203; 考勤明细</h4>
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr><th>日期</th><th>上班时间</th><th>下班时间</th><th>状态</th><th>工时(h)</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${records}" var="r">
                                <tr>
                                    <td><strong>${r.workDate}</strong></td>
                                    <td>${r.checkInTime != null ? r.checkInTime : '未打卡'}</td>
                                    <td>${r.checkOutTime != null ? r.checkOutTime : '未打卡'}</td>
                                    <td><span class="status-badge status-${r.status}">${r.status}</span></td>
                                    <td>${r.workHours != null ? r.workHours : '--'}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty records}">
                                <tr><td colspan="5" class="empty-state"><div class="empty-icon">&#128197;</div><p>${yearMonth} 暂无考勤记录</p></td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// 生成日历网格
(function() {
    var ym = '${yearMonth}';
    if (!ym) return;
    var parts = ym.split('-');
    var year = parseInt(parts[0]), month = parseInt(parts[1]);
    var firstDay = new Date(year, month - 1, 1);
    var lastDay = new Date(year, month, 0);
    var startWeekday = firstDay.getDay();
    var totalDays = lastDay.getDate();
    var today = new Date();
    var isCurrentMonth = (today.getFullYear() == year && today.getMonth() + 1 == month);
    
    // 考勤记录映射
    var recordMap = {};
    <c:forEach items="${records}" var="r">
    recordMap['${fn:substring(r.workDate, 8, 10)}'] = { status: '${r.status}', inTime: '${r.checkInTime}', outTime: '${r.checkOutTime}' };
    </c:forEach>
    
    var html = '';
    var weekdays = ['日','一','二','三','四','五','六'];
    
    // 空白填充
    for (var i = 0; i < startWeekday; i++) {
        html += '<div class="cal-day empty"></div>';
    }
    
    for (var d = 1; d <= totalDays; d++) {
        var dayStr = String(d).padStart(2, '0');
        var rec = recordMap[dayStr];
        var statusClass = 'rest';
        var statusText = '休息';
        
        if (rec) {
            if (rec.status == '正常') { statusClass = 'normal'; statusText = '正常'; }
            else if (rec.status == '迟到') { statusClass = 'late'; statusText = '迟到'; }
            else if (rec.status == '早退') { statusClass = 'early'; statusText = '早退'; }
            else if (rec.status == '缺勤') { statusClass = 'absent'; statusText = '缺勤'; }
        }
        
        var isToday = isCurrentMonth && d == today.getDate();
        var todayClass = isToday ? 'today' : '';
        
        html += '<div class="cal-day ' + statusClass + ' ' + todayClass + '" title="' + dayStr + '日: ' + statusText + '">' +
                '<span class="day-num">' + d + '</span>' +
                '<span class="day-status">' + statusText + '</span>' +
                '</div>';
    }
    
    document.getElementById('calendarGrid').insertAdjacentHTML('beforeend', html);
})();
</script>
</body>
</html>
