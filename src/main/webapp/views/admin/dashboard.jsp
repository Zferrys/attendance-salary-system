<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("pageTitle", "管理后台"); request.setAttribute("sectionName", "管理后台"); %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="_csrf" content="${pageContext.session.getAttribute('CSRF_TOKEN')}">
  <title>管理后台 - 考勤薪资系统</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</head>
<body>
<jsp:include page="/views/common/_navbar.jsp"/>

<div class="main-container">
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/admin?action=dashboard">管理首页</a>
    <span class="separator">&#8250;</span>
    <span class="current">数据概览</span>
  </div>

  <p class="dashboard-welcome" style="font-size:0.88rem;color:var(--ink-secondary);margin-bottom:20px;">
    欢迎回来，<strong>${currentUser.name}</strong> &middot; <span id="todayDate"></span>
  </p>

  <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>

  <!-- 统计卡片 -->
  <div class="stat-grid">
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--brand),#3b82f6);color:#fff;">&#128101;</div>
      <div class="stat-info">
        <div class="stat-value">${totalEmps}</div>
        <div class="stat-label">员工总数</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--info),#8b5cf6);color:#fff;">&#127970;</div>
      <div class="stat-info">
        <div class="stat-value">${totalDepts}</div>
        <div class="stat-label">部门数量</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--success),#34d399);color:#fff;">&#128176;</div>
      <div class="stat-info">
        <div class="stat-value">薪资管理</div>
        <div class="stat-label">生成与发放</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:linear-gradient(135deg,var(--warning),#fbbf24);color:#fff;">&#128203;</div>
      <div class="stat-info">
        <div class="stat-value">报表导出</div>
        <div class="stat-label">Excel / 打印</div>
      </div>
    </div>
  </div>

  <!-- 功能入口 -->
  <div class="feature-grid">
    <a href="${pageContext.request.contextPath}/admin?action=empList" class="feature-card">
      <div class="feature-icon" style="background:var(--brand-soft);color:var(--brand);">&#128100;</div>
      <div class="feature-info">
        <h3>员工信息管理</h3>
        <p>查看、搜索、添加员工，按部门和姓名筛选</p>
      </div>
    </a>
    <a href="${pageContext.request.contextPath}/admin?action=attendanceList" class="feature-card">
      <div class="feature-icon" style="background:#fce7f3;color:#db2777;">&#128197;</div>
      <div class="feature-info">
        <h3>考勤管理</h3>
        <p>查看所有考勤记录，按部门、日期、状态筛选</p>
      </div>
    </a>
    <a href="${pageContext.request.contextPath}/admin?action=salaryList" class="feature-card">
      <div class="feature-icon" style="background:var(--success-soft);color:var(--success);">&#128176;</div>
      <div class="feature-info">
        <h3>薪资管理与发放</h3>
        <p>生成月度薪资、查看明细、执行发放操作</p>
      </div>
    </a>
    <a href="${pageContext.request.contextPath}/admin?action=empAdd" class="feature-card">
      <div class="feature-icon" style="background:var(--warning-soft);color:var(--warning);">&#10133;</div>
      <div class="feature-info">
        <h3>添加新员工</h3>
        <p>录入新员工基本信息、部门、职位和工资</p>
      </div>
    </a>
    <a href="${pageContext.request.contextPath}/admin?action=salaryReport" class="feature-card">
      <div class="feature-icon" style="background:var(--info-soft);color:var(--info);">&#128202;</div>
      <div class="feature-info">
        <h3>月度薪资报表</h3>
        <p>查看月度汇总，支持导出和打印薪资条</p>
      </div>
    </a>
  </div>

  <!-- 快捷操作指南 -->
  <div class="card">
    <div class="card-header">&#9889; 快捷操作指南</div>
    <div class="card-body">
      <div style="display:flex;flex-direction:column;gap:10px;font-size:0.82rem;">
        <div style="display:flex;align-items:center;gap:10px;padding:8px 0;border-bottom:1px solid var(--border-light);">
          <span style="width:8px;height:8px;border-radius:50%;background:var(--brand);flex-shrink:0;"></span>
          <span><strong>生成薪资：</strong>进入「薪资管理」选择月份，点击「生成当月薪资」</span>
        </div>
        <div style="display:flex;align-items:center;gap:10px;padding:8px 0;border-bottom:1px solid var(--border-light);">
          <span style="width:8px;height:8px;border-radius:50%;background:var(--success);flex-shrink:0;"></span>
          <span><strong>发放薪资：</strong>在薪资列表中找到「未发放」记录，点击「发放」</span>
        </div>
        <div style="display:flex;align-items:center;gap:10px;padding:8px 0;">
          <span style="width:8px;height:8px;border-radius:50%;background:var(--warning);flex-shrink:0;"></span>
          <span><strong>添加员工：</strong>点击「添加新员工」，填写基本信息后保存</span>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  (function(){var n=new Date,d=['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
    var el=document.getElementById('todayDate');
    if(el)el.textContent=n.getFullYear()+'年'+(n.getMonth()+1)+'月'+n.getDate()+'日 '+d[n.getDay()];})();
</script>
</body>
</html>
