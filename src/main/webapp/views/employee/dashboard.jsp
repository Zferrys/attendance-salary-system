<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>员工首页 - 考勤薪资系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
    <style>
        .clock-section { text-align: center; padding: 30px; }
        .clock-time { font-size: 42px; font-weight: 700; color: #1f2937; font-family: 'Courier New', monospace; }
        .clock-date { font-size: 15px; color: #6b7280; margin-top: 4px; }
        .clock-btns { display: flex; justify-content: center; gap: 16px; margin-top: 24px; flex-wrap: wrap; }
        .clock-btn { 
            padding: 16px 36px; border-radius: 12px; border: none; font-size: 16px; 
            font-weight: 600; cursor: pointer; transition: all 0.3s; color: #fff;
            display: flex; align-items: center; gap: 8px;
        }
        .clock-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.15); }
        .clock-btn.in { background: linear-gradient(135deg, #1a73e8, #4a90d9); }
        .clock-btn.out { background: linear-gradient(135deg, #0d9e6c, #34d399); }
        .clock-btn:disabled { background: #9ca3af; cursor: not-allowed; transform: none; box-shadow: none; }
        .tip-box { margin-top: 16px; padding: 12px 16px; background: #f8fafc; border-radius: 8px; font-size: 13px; color: #6b7280; }
        .recent-table tr { transition: all 0.2s; }
        .recent-table tr:hover { background: #f0f7ff; }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 员工端</span></div>
    <div class="navbar-right">
        <span class="user-info">${currentUser.name} (${currentUser.empNo})</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a>
    </div>
</nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/employee?action=dashboard">&#127968; 员工首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">工作台</span>
    </div>

    <!-- 消息提示 -->
    <c:if test="${not empty msg}">
        <div class="alert alert-${msgType == 'warning' ? 'warning' : 'success'}">${msg}</div>
    </c:if>

    <!-- 统计卡片区域 -->
    <div class="stat-grid">
        <div class="stat-card" style="border-left:4px solid #1a73e8;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#1a73e8,#4a90d9);">&#128197;</div>
            <div class="stat-info">
                <div class="stat-value">${attendStats.normalDays != null ? attendStats.normalDays : 0}</div>
                <div class="stat-label">本月正常天数</div>
            </div>
        </div>
        <div class="stat-card" style="border-left:4px solid #f0a020;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#f0a020,#fbbf24);">&#9200;</div>
            <div class="stat-info">
                <div class="stat-value">${attendStats.lateDays != null ? attendStats.lateDays : 0}</div>
                <div class="stat-label">迟到次数</div>
            </div>
        </div>
        <div class="stat-card" style="border-left:4px solid #dc3545;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#dc3545,#f87171);">&#10060;</div>
            <div class="stat-info">
                <div class="stat-value">${attendStats.absentDays != null ? attendStats.absentDays : 0}</div>
                <div class="stat-label">缺勤次数</div>
            </div>
        </div>
        <div class="stat-card" style="border-left:4px solid #0d9e6c;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#0d9e6c,#34d399);">&#128176;</div>
            <div class="stat-info">
                <div class="stat-label">查看薪资</div>
                <a href="${pageContext.request.contextPath}/employee?action=salaryView"
                   class="btn btn-success btn-sm" style="margin-top:6px;">点击查看</a>
            </div>
        </div>
    </div>

    <!-- 打卡操作区 -->
    <div class="card">
        <div class="card-header">&#128205; 今日打卡</div>
        <div class="clock-section">
            <p style="font-size:16px;color:#4b5563;margin-bottom:16px;">
                ${currentUser.position} - ${currentUser.name}
            </p>
            <div class="clock-time" id="liveClock">00:00:00</div>
            <div class="clock-date" id="liveDate">--</div>
            <div class="clock-btns">
                <form action="${pageContext.request.contextPath}/employee" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="clockIn">
                    <button type="submit" class="clock-btn in" id="btnClockIn">
                        &#128205; 上班打卡
                    </button>
                </form>
                <form action="${pageContext.request.contextPath}/employee" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="clockOut">
                    <button type="submit" class="clock-btn out" id="btnClockOut">
                        &#127968; 下班打卡
                    </button>
                </form>
            </div>
            <div class="tip-box">
                &#128161; 提示：每天只能打卡2次（上班+下班），9点后打卡将标记为"迟到"，18点前离开标记为"早退"
            </div>
        </div>
    </div>

    <!-- 快捷操作入口 -->
    <div class="quick-actions">
        <a href="${pageContext.request.contextPath}/employee?action=attendView" class="action-card">
            <span class="action-icon" style="background:linear-gradient(135deg,#1a73e8,#4a90d9);">&#128203;</span>
            考勤日历
        </a>
        <a href="${pageContext.request.contextPath}/employee?action=applyLeave" class="action-card">
            <span class="action-icon" style="background:linear-gradient(135deg,#f0a020,#fbbf24);">&#128221;</span>
            请假申请
        </a>
        <a href="${pageContext.request.contextPath}/employee?action=leaveList" class="action-card">
            <span class="action-icon" style="background:linear-gradient(135deg,#6366f1,#818cf8);">&#128196;</span>
            请假记录
        </a>
        <a href="${pageContext.request.contextPath}/employee?action=salaryView" class="action-card">
            <span class="action-icon" style="background:linear-gradient(135deg,#0d9e6c,#34d399);">&#128176;</span>
            薪资详情
        </a>
    </div>

    <!-- 最近考勤记录 -->
    <div class="card">
        <div class="card-header">
            最近考勤记录
            <a href="${pageContext.request.contextPath}/employee?action=attendView" class="btn btn-outline btn-sm">查看全部</a>
        </div>
        <div class="card-body table-wrapper">
            <table class="data-table recent-table">
                <thead>
                    <tr><th>日期</th><th>上班时间</th><th>下班时间</th><th>状态</th><th>工时</th></tr>
                </thead>
                <tbody>
                    <c:forEach items="${recentRecords}" var="r">
                        <tr>
                            <td><strong>${r.workDate}</strong></td>
                            <td>${r.checkInTime != null ? r.checkInTime : '--'}</td>
                            <td>${r.checkOutTime != null ? r.checkOutTime : '--'}</td>
                            <td><span class="status-badge status-${r.status}">${r.status}</span></td>
                            <td>${r.workHours != null ? r.workHours : '--'}h</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty recentRecords}">
                        <tr><td colspan="5" class="empty-state"><div class="empty-icon">&#128236;</div><p>暂无考勤记录</p></td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    // 实时时钟
    function updateClock() {
        var now = new Date();
        var h = String(now.getHours()).padStart(2, '0');
        var m = String(now.getMinutes()).padStart(2, '0');
        var s = String(now.getSeconds()).padStart(2, '0');
        document.getElementById('liveClock').textContent = h + ':' + m + ':' + s;
        
        var weekdays = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
        document.getElementById('liveDate').textContent = 
            now.getFullYear() + '年' + (now.getMonth()+1) + '月' + now.getDate() + '日 ' + weekdays[now.getDay()];
        
        // 根据时间自动禁用按钮
        var hour = now.getHours();
        var btnIn = document.getElementById('btnClockIn');
        var btnOut = document.getElementById('btnClockOut');
        // 简单的演示逻辑：实际应由后端控制
    }
    setInterval(updateClock, 1000);
    updateClock();
</script>
</body>
</html>
