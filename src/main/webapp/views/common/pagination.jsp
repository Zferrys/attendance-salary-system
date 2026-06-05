<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  公共分页导航组件
  使用方式: <jsp:include page="/views/common/pagination.jsp"/>
  需要的 request 属性:
    - currentPage:  当前页码 (int)
    - totalPages:   总页数 (int)
    - totalCount:   总记录数 (int)
--%>
<c:if test="${totalPages > 1}">
<div class="pagination-info">
    共 <strong>${totalCount}</strong> 条记录，第 <strong>${currentPage}</strong>/<strong>${totalPages}</strong> 页
</div>
<div class="pagination">
    <%-- 首页 --%>
    <c:choose>
        <c:when test="${currentPage <= 1}">
            <span class="disabled">&laquo; 首页</span>
        </c:when>
        <c:otherwise>
            <a href="javascript:void(0)" onclick="goPage(1)">&laquo; 首页</a>
        </c:otherwise>
    </c:choose>
    
    <%-- 上一页 --%>
    <c:choose>
        <c:when test="${currentPage <= 1}">
            <span class="disabled">&lsaquo; 上一页</span>
        </c:when>
        <c:otherwise>
            <a href="javascript:void(0)" onclick="goPage(${currentPage - 1})">&lsaquo; 上一页</a>
        </c:otherwise>
    </c:choose>
    
    <%-- 页码（最多显示7页） --%>
    <c:set var="startPage" value="${currentPage - 3}"/>
    <c:set var="endPage" value="${currentPage + 3}"/>
    <c:if test="${startPage < 1}"><c:set var="startPage" value="1"/><c:set var="endPage" value="${startPage + 6}"/></c:if>
    <c:if test="${endPage > totalPages}"><c:set var="endPage" value="${totalPages}"/><c:set var="startPage" value="${endPage - 6}"/></c:if>
    <c:if test="${startPage < 1}"><c:set var="startPage" value="1"/></c:if>
    
    <c:forEach begin="${startPage}" end="${endPage}" var="p">
        <c:choose>
            <c:when test="${p == currentPage}">
                <span class="active">${p}</span>
            </c:when>
            <c:otherwise>
                <a href="javascript:void(0)" onclick="goPage(${p})">${p}</a>
            </c:otherwise>
        </c:choose>
    </c:forEach>
    
    <%-- 下一页 --%>
    <c:choose>
        <c:when test="${currentPage >= totalPages}">
            <span class="disabled">下一页 &rsaquo;</span>
        </c:when>
        <c:otherwise>
            <a href="javascript:void(0)" onclick="goPage(${currentPage + 1})">下一页 &rsaquo;</a>
        </c:otherwise>
    </c:choose>
    
    <%-- 末页 --%>
    <c:choose>
        <c:when test="${currentPage >= totalPages}">
            <span class="disabled">末页 &raquo;</span>
        </c:when>
        <c:otherwise>
            <a href="javascript:void(0)" onclick="goPage(${totalPages})">末页 &raquo;</a>
        </c:otherwise>
    </c:choose>
</div>
</c:if>
