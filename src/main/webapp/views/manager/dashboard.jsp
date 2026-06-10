<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="_csrf" content="${pageContext.session.getAttribute('CSRF_TOKEN')}">
  <title>主管面板 - 考勤薪资系统</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</head>
<body>
<jsp:include page="/views/common/_navbar.jsp">
  <jsp:param name="sectionName" value="主管面板"/>
</jsp:include>

<div class="main-container">
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/mgr?action=dashboard">主管首页</a>
    <span class="separator">&#8250;</span>
    <span class="current">工作台</span>
  </div>

  <p style="font-size:0.88rem;color:var(--ink-secondary);margin-bottom:20px;">
    欢迎回来，<strong>${currentUser.name}</strong> &middot; <span id="todayDate"></span>
  </p>

  <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>

  <div class="stat-grid">
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,#f97316,#fb923c);color:#fff;">&#128203;</div>
      <div class="stat-info">
        <div class="stat-value">${pendingCount != null ? pendingCount : 0}</div>
        <div class="stat-label">待审批请假</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--brand),#3b82f6);color:#fff;">&#128101;</div>
      <div class="stat-info">
        <div class="stat-value">团队管理</div>
        <div class="stat-label">查看团队考勤</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--success),#34d399);color:#fff;">&#128176;</div>
      <div class="stat-info">
        <div class="stat-value">薪资查看</div>
        <div class="stat-label">个人薪资明细</div>
      </div>
    </div>
  </div>

  <div class="feature-grid">
    <a href="${pageContext.request.contextPath}/mgr?action=leaveReview" class="feature-card">
      <div class="feature-icon" style="background:var(--brand-soft);color:var(--brand);">&#9989;</div>
      <div class="feature-info">
        <h3>审批请假申请
          <c:if test="${pendingCount > 0}">
            <span style="background:var(--danger);color:#fff;font-size:0.68rem;padding:1px 7px;border-radius:10px;margin-left:6px;">${pendingCount}</span>
          </c:if>
        </h3>
        <p>查看并审批下属的请假申请</p>
      </div>
    </a>
    <a href="${pageContext.request.contextPath}/mgr?action=teamAttend" class="feature-card">
      <div class="feature-icon" style="background:var(--success-soft);color:var(--success);">&#128202;</div>
      <div class="feature-info">
        <h3>团队考勤统计</h3>
        <p>查看部门成员月度考勤情况</p>
      </div>
    </a>
    <a href="${pageContext.request.contextPath}/mgr?action=empList" class="feature-card">
      <div class="feature-icon" style="background:#eef2ff;color:var(--info);">&#128101;</div>
      <div class="feature-info">
        <h3>团队员工管理</h3>
        <p>查看和管理部门内员工信息</p>
      </div>
    </a>
    <a href="${pageContext.request.contextPath}/mgr?action=salaryView" class="feature-card">
      <div class="feature-icon" style="background:var(--warning-soft);color:var(--warning);">&#128176;</div>
      <div class="feature-info">
        <h3>我的薪资</h3>
        <p>查看个人月度薪资明细</p>
      </div>
    </a>
  </div>

  <div class="card">
    <div class="card-header">最近待审批请假
      <c:if test="${not empty pendingLeaves}">
        <a href="${pageContext.request.contextPath}/mgr?action=leaveReview" class="btn btn-outline btn-sm">查看全部</a>
      </c:if>
    </div>
    <div class="card-body">
      <c:forEach items="${pendingLeaves}" var="l">
        <div style="display:flex;align-items:center;gap:12px;padding:10px 14px;background:var(--bg);border-radius:8px;margin-bottom:8px;font-size:0.8rem;">
          <span style="font-weight:600;color:var(--ink);min-width:60px;">${l.empName}</span>
          <span style="color:var(--ink-secondary);flex:1;">${l.leaveType} &middot; ${l.startDate} 至 ${l.endDate}</span>
          <span style="color:var(--warning);font-weight:600;">${l.days}天</span>
        </div>
      </c:forEach>
      <c:if test="${empty pendingLeaves}">
        <div class="empty-state"><div class="empty-icon">&#127881;</div><p>暂无待审批的申请</p></div>
      </c:if>
    </div>
  </div>
</div>

<script>
  (function(){var n=new Date(),d=['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
    var el=document.getElementById('todayDate');
    if(el)el.textContent=n.getFullYear()+'年'+(n.getMonth()+1)+'月'+n.getDate()+'日 '+d[n.getDay()];})();
</script>
</body>
</html>
