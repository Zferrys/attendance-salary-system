<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 共享导航栏 v3.0 - 玻璃拟态风格 --%>
<c:set var="_sec" value="${not empty sectionName ? sectionName : param.sectionName}"/>
<nav class="navbar">
  <div class="navbar-brand">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="rgba(56,189,248,0.9)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <rect x="3" y="4" width="18" height="18" rx="2"/>
      <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
      <line x1="3" y1="10" x2="21" y2="10"/>
      <path d="M8 14h.01M12 14h.01M16 14h.01M8 18h.01M12 18h.01M16 18h.01"/>
    </svg>
    考勤薪资 <span>${_sec}</span>
  </div>
  <div class="navbar-right">
    <span class="user-info">${currentUser.name}</span>
    <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">退出</a>
  </div>
</nav>
