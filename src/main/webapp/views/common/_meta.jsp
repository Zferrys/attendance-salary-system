<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  共享页头组件
  参数: pageTitle - 页面标题, sectionName - 导航栏副标题, breadcrumb - 面包屑列表
--%>
<%
  String sectionName = (String) request.getAttribute("sectionName");
  if (sectionName == null) sectionName = "";
  String pageTitle = (String) request.getAttribute("pageTitle");
  if (pageTitle == null) pageTitle = "考勤薪资系统";
%>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="_csrf" content="${pageContext.request.session.getAttribute('CSRF_TOKEN')}">
<title><c:out value="${pageTitle}"/> - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=1.1">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>