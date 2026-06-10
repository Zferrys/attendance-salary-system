<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="_csrf" content="${pageContext.session.getAttribute('CSRF_TOKEN')}">
  <title>员工首页 - 考勤薪资系统</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</head>
<body>
<jsp:include page="/views/common/_navbar.jsp">
  <jsp:param name="sectionName" value="员工端"/>
</jsp:include>

<div class="main-container">
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/employee?action=dashboard">员工首页</a>
    <span class="separator">&#8250;</span>
    <span class="current">工作台</span>
  </div>

  <c:if test="${not empty msg}">
    <div class="alert alert-${msgType == 'warning' ? 'warning' : 'success'}">${msg}</div>
  </c:if>

  <!-- 统计卡片 -->
  <div class="stat-grid">
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--brand),#3b82f6);color:#fff;">&#128197;</div>
      <div class="stat-info">
        <div class="stat-value">${attendStats.normalDays != null ? attendStats.normalDays : 0}</div>
        <div class="stat-label">本月正常天数</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--warning),#fbbf24);color:#fff;">&#9200;</div>
      <div class="stat-info">
        <div class="stat-value">${attendStats.lateDays != null ? attendStats.lateDays : 0}</div>
        <div class="stat-label">迟到次数</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--danger),#f87171);color:#fff;">&#10060;</div>
      <div class="stat-info">
        <div class="stat-value">${attendStats.absentDays != null ? attendStats.absentDays : 0}</div>
        <div class="stat-label">缺勤次数</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--success),#34d399);color:#fff;">&#128176;</div>
      <div class="stat-info">
        <div class="stat-label">我的薪资</div>
        <a href="${pageContext.request.contextPath}/employee?action=salaryView" class="btn btn-success btn-sm" style="margin-top:4px;">查看详情</a>
      </div>
    </div>
  </div>

  <!-- 打卡区 -->
  <div class="card">
    <div class="card-header">&#128205; 今日打卡 &middot; ${currentUser.position} ${currentUser.name}</div>
    <div class="clock-section">
      <div class="clock-time" id="liveClock">00:00:00</div>
      <div class="clock-date" id="liveDate">--</div>
      <div class="clock-btns">
        <form action="${pageContext.request.contextPath}/employee" method="post" style="display:inline;">
          <input type="hidden" name="action" value="clockIn">
          <input type="hidden" name="_csrf" value="${pageContext.session.getAttribute('CSRF_TOKEN')}">
          <button type="submit" class="clock-btn in" id="btnClockIn">&#128205; 上班打卡</button>
        </form>
        <form action="${pageContext.request.contextPath}/employee" method="post" style="display:inline;">
          <input type="hidden" name="action" value="clockOut">
          <input type="hidden" name="_csrf" value="${pageContext.session.getAttribute('CSRF_TOKEN')}">
          <button type="submit" class="clock-btn out" id="btnClockOut">&#127968; 下班打卡</button>
        </form>
      </div>
      <div class="tip-box">&#128161; 每天可打卡2次（上班+下班），9:00后标记迟到，18:00前离开标记早退</div>
    </div>
  </div>

  <!-- 快捷操作 -->
  <div class="quick-actions">
    <a href="${pageContext.request.contextPath}/employee?action=attendView" class="action-card">
      <span class="action-icon" style="background:linear-gradient(135deg,var(--brand),#3b82f6);color:#fff;">&#128203;</span>
      考勤日历
    </a>
    <a href="${pageContext.request.contextPath}/employee?action=applyLeave" class="action-card">
      <span class="action-icon" style="background:linear-gradient(135deg,var(--warning),#fbbf24);color:#fff;">&#128221;</span>
      请假申请
    </a>
    <a href="${pageContext.request.contextPath}/employee?action=leaveList" class="action-card">
      <span class="action-icon" style="background:linear-gradient(135deg,var(--info),#8b5cf6);color:#fff;">&#128196;</span>
      请假记录
    </a>
    <a href="${pageContext.request.contextPath}/employee?action=salaryView" class="action-card">
      <span class="action-icon" style="background:linear-gradient(135deg,var(--success),#34d399);color:#fff;">&#128176;</span>
      薪资详情
    </a>
  </div>

  <!-- 最近考勤 -->
  <div class="card">
    <div class="card-header">
      最近考勤记录
      <a href="${pageContext.request.contextPath}/employee?action=attendView" class="btn btn-outline btn-sm">查看全部</a>
    </div>
    <div class="card-body table-wrapper">
      <table class="data-table">
        <thead><tr><th>日期</th><th>上班</th><th>下班</th><th>状态</th><th>工时</th></tr></thead>
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
  (function u(){var n=new Date();
    document.getElementById('liveClock').textContent=
      String(n.getHours()).padStart(2,'0')+':'+String(n.getMinutes()).padStart(2,'0')+':'+String(n.getSeconds()).padStart(2,'0');
    var d=['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
    document.getElementById('liveDate').textContent=n.getFullYear()+'年'+(n.getMonth()+1)+'月'+n.getDate()+'日 '+d[n.getDay()];
    setTimeout(u,1000);})();
</script>
</body>
</html>
