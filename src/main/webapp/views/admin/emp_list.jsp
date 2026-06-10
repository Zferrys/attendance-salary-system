<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="_csrf" content="${pageContext.session.getAttribute('CSRF_TOKEN')}">
  <title>员工管理 - 考勤薪资系统</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</head>
<body>
<jsp:include page="/views/common/_navbar.jsp">
  <jsp:param name="sectionName" value="员工管理"/>
</jsp:include>

<div class="main-container">
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/admin?action=dashboard">管理首页</a>
    <span class="separator">&#8250;</span>
    <span class="current">员工管理</span>
  </div>

  <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>
  <c:if test="${not empty errorMsg}"><div class="alert alert-danger">${errorMsg}</div></c:if>

  <!-- 搜索与操作栏 -->
  <div class="filter-bar">
    <input type="hidden" name="action" value="empList" form="searchForm">
    <input type="hidden" name="page" value="${currentPage}" form="searchForm" id="pageInput">
    <div style="position:relative;">
      <input name="name" value="${param.name}" placeholder="搜索姓名..." form="searchForm" style="width:180px;padding:7px 11px 7px 32px;border:1.5px solid var(--border);border-radius:var(--radius-sm);font-size:0.82rem;outline:none;">
      <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);font-size:0.8rem;color:var(--ink-muted);">&#128269;</span>
    </div>
    <label style="font-size:0.8rem;font-weight:600;color:var(--ink-secondary);">部门：</label>
    <select name="deptId" form="searchForm" style="padding:7px 11px;border:1.5px solid var(--border);border-radius:var(--radius-sm);font-size:0.82rem;outline:none;">
      <option value="">全部</option>
      <c:forEach items="${deptList}" var="d">
        <option value="${d.id}" ${param.deptId == d.id ? 'selected' : ''}>${d.deptName}</option>
      </c:forEach>
    </select>
    <button type="submit" class="btn btn-primary btn-sm" form="searchForm" onclick="document.getElementById('pageInput').value='1'">&#128269; 搜索</button>
    <a href="${pageContext.request.contextPath}/admin?action=empAdd" class="btn btn-success btn-sm">&#10133; 添加员工</a>
    <button type="button" class="btn btn-info btn-sm" onclick="document.getElementById('importFile').click()">&#128229; 批量导入</button>
    <a href="${pageContext.request.contextPath}/admin?action=exportTemplate" class="btn btn-outline btn-sm">&#128196; 下载模板</a>
    <form id="importForm" action="${pageContext.request.contextPath}/admin?action=empImport" method="post" enctype="multipart/form-data" style="display:none;">
      <input type="hidden" name="_csrf" value="${pageContext.session.getAttribute('CSRF_TOKEN')}">
      <input type="file" id="importFile" name="file" accept=".xlsx,.xls" onchange="document.getElementById('importForm').submit();showLoading('正在导入...')">
    </form>
  </div>
  <form id="searchForm" method="get" style="display:none;"><input type="hidden" name="action" value="empList"></form>

  <div class="card">
    <div class="card-header">
      员工列表
      <span style="font-weight:400;font-size:0.78rem;color:var(--ink-muted);">${empList.size()} 条记录</span>
    </div>
    <div class="card-body table-wrapper">
      <table class="data-table" id="empTable">
        <thead>
          <tr><th>工号</th><th>姓名</th><th>部门</th><th>职位</th><th>基本工资</th><th>入职日期</th><th>角色</th><th>操作</th></tr>
        </thead>
        <tbody>
          <c:forEach items="${empList}" var="e">
            <tr class="emp-row">
              <td><code>${e.empNo}</code></td>
              <td><strong>${e.name}</strong></td>
              <td>${e.deptName != null ? e.deptName : '--'}</td>
              <td>${e.position}</td>
              <td style="color:var(--success);font-weight:600;">&#165; ${e.baseSalary}</td>
              <td>${e.entryDate}</td>
              <td>
                <c:choose>
                  <c:when test="${fn:startsWith(e.empNo, 'A')}"><span class="tag tag-admin">管理员</span></c:when>
                  <c:when test="${fn:startsWith(e.empNo, 'M')}"><span class="tag tag-manager">主管</span></c:when>
                  <c:otherwise><span class="tag tag-emp">员工</span></c:otherwise>
                </c:choose>
              </td>
              <td>
                <a href="${pageContext.request.contextPath}/admin?action=empEdit&id=${e.id}" class="btn btn-info btn-sm">&#9998; 编辑</a>
                <a href="javascript:void(0)" onclick="confirmDelete('${e.id}', '${e.name}', '${e.empNo}')" class="btn btn-danger btn-sm">&#128465; 删除</a>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty empList}">
            <tr><td colspan="8" class="empty-state"><div class="empty-icon">&#128236;</div><p>暂无员工数据</p></td></tr>
          </c:if>
        </tbody>
      </table>
      <jsp:include page="/views/common/pagination.jsp"/>
    </div>
  </div>
</div>

<script>
function goPage(p) {
  document.getElementById('pageInput').value = p;
  document.getElementById('searchForm').submit();
}
function confirmDelete(id, name, empNo) {
  if (confirm('确定要删除员工 "' + name + '（' + empNo + '）" 吗？\n\n删除后将设置离职日期，该员工将无法登录系统。')) {
    window.location.href = '${pageContext.request.contextPath}/admin?action=empDelete&id=' + id;
  }
}
</script>
</body>
</html>
