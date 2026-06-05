<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>薪资管理 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .salary-summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; margin-bottom: 18px; }
    .summary-item { background: #fff; border-radius: 10px; padding: 18px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
    .summary-item .num { font-size: 24px; font-weight: 700; color: #1f2937; }
    .summary-item .label { font-size: 12px; color: #6b7280; margin-top: 4px; }
    .export-bar { display: flex; gap: 10px; margin-bottom: 18px; flex-wrap: wrap; }
    .data-table tbody tr { transition: all 0.2s; }
    .data-table tbody tr:hover { background: #f0f7ff; }
    .paid-row { background: #f0fdf4 !important; }
</style>
</head>
<body>
<nav class="navbar"><div class="navbar-brand">考勤薪资系统 <span>| 薪资管理</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
    <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div></nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/admin?action=dashboard">&#127968; 管理首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">薪资管理</span>
    </div>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>
    <c:if test="${not empty errorMsg}"><div class="alert alert-danger">${errorMsg}</div></c:if>

    <!-- 薪资汇总 -->
    <div class="salary-summary">
        <div class="summary-item">
            <div class="num">${totalCount}</div>
            <div class="label">总人数</div>
        </div>
        <div class="summary-item">
            <div class="num" style="color:#0d9e6c;">
                <c:set var="totalActual" value="0"/>
                <c:forEach items="${salaryList}" var="s">
                    <c:if test="${s.actualSalary != null}">
                        <c:set var="totalActual" value="${totalActual + s.actualSalary}"/>
                    </c:if>
                </c:forEach>
                ¥ ${totalActual}
            </div>
            <div class="label">实发总额</div>
        </div>
        <div class="summary-item">
            <div class="num" style="color:#f0a020;">
                <c:set var="unpaidCount" value="0"/>
                <c:forEach items="${salaryList}" var="s">
                    <c:if test="${s.status == '未发放'}"><c:set var="unpaidCount" value="${unpaidCount + 1}"/></c:if>
                </c:forEach>
                ${unpaidCount}
            </div>
            <div class="label">未发放人数</div>
        </div>
        <div class="summary-item">
            <div class="num" style="color:#1a73e8;">
                <c:set var="paidCount" value="0"/>
                <c:forEach items="${salaryList}" var="s">
                    <c:if test="${s.status == '已发放'}"><c:set var="paidCount" value="${paidCount + 1}"/></c:if>
                </c:forEach>
                ${paidCount}
            </div>
            <div class="label">已发放人数</div>
        </div>
    </div>

    <!-- 操作栏 -->
    <div class="filter-bar">
        <form method="get" id="salaryForm" style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <input type="hidden" name="action" value="salaryList">
            <input type="hidden" name="page" id="pageInput" value="${currentPage}">
            <label>&#128197; 选择月份：</label>
            <input type="month" name="yearMonth" value="${yearMonth}">
            <button type="submit" class="btn btn-primary btn-sm" onclick="document.getElementById('pageInput').value='1'">&#128269; 查询</button>
        </form>
        <form method="post" action="${pageContext.request.contextPath}/admin" style="display:inline;">
            <input type="hidden" name="action" value="salaryGen">
            <input type="hidden" name="yearMonth" value="${yearMonth}">
            <button type="submit" class="btn btn-success btn-sm" data-confirm="确认为 ${yearMonth} 生成薪资记录？系统将自动根据考勤和请假数据计算。">&#9889; 生成当月薪资</button>
        </form>
        <button type="button" class="btn btn-info btn-sm" onclick="exportTableToCSV('.data-table', '薪资报表_${yearMonth}.csv')">&#128190; 导出CSV</button>
        <a href="${pageContext.request.contextPath}/admin?action=dashboard" class="btn btn-outline btn-sm">返回首页</a>
    </div>

    <div class="card">
        <div class="card-header">${yearMonth} 薪资列表 <span style="font-weight:400;font-size:13px;color:#6b7280;">(${salaryList.size()} 条记录)</span></div>
        <div class="card-body table-wrapper">
            <table class="data-table" id="salaryTable">
                <thead><tr>
                    <th>工号</th><th>姓名</th><th>部门</th><th>基本工资</th><th>全勤奖</th>
                    <th>迟到扣款</th><th>请假扣款</th><th>实际工资</th><th>状态</th><th>操作</th>
                </tr></thead>
                <tbody>
                    <c:forEach items="${salaryList}" var="s">
                        <tr class="${s.status == '已发放' ? 'paid-row' : ''}">
                            <td><code style="background:#f3f4f6;padding:2px 8px;border-radius:4px;">${s.empNo}</code></td>
                            <td><strong>${s.empName}</strong></td>
                            <td>${s.deptName != null ? s.deptName : '--'}</td>
                            <td>¥ ${s.baseSalary != null ? s.baseSalary : '0.00'}</td>
                            <td style="color:#0d9e6c;">+ ¥ ${s.attendanceBonus != null && s.attendanceBonus > 0 ? s.attendanceBonus : '0.00'}</td>
                            <td style="color:#dc3545;">- ¥ ${s.deductionLate != null && s.deductionLate > 0 ? s.deductionLate : '0.00'}</td>
                            <td style="color:#dc3545;">- ¥ ${s.deductionLeave != null && s.deductionLeave > 0 ? s.deductionLeave : '0.00'}</td>
                            <td><strong style="color:#0d9e6c;font-size:16px;">¥ ${s.actualSalary != null ? s.actualSalary : '0.00'}</strong></td>
                            <td><span class="status-badge status-${s.status}">${s.status}</span></td>
                            <td>
                                <c:if test="${s.status == '未发放'}">
                                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="salaryPay">
                                        <input type="hidden" name="id" value="${s.id}">
                                        <input type="hidden" name="yearMonth" value="${yearMonth}">
                                        <button type="submit" class="btn btn-success btn-sm" data-confirm="确定发放 ${s.empName} 的薪资？">&#128179; 发放</button>
                                    </form>
                                </c:if>
                                <c:if test="${s.status == '已发放'}">
                                    <span style="color:#0d9e6c;font-size:13px;font-weight:600;">已发放 &#10003;</span>
                                </c:if>
                                <button type="button" class="btn btn-outline btn-sm" style="margin-left:4px;" onclick="showSalarySlip('${s.empName}','${s.empNo}','${s.deptName}','${s.baseSalary}','${s.attendanceBonus}','${s.deductionLate}','${s.deductionLeave}','${s.actualSalary}','${s.status}','${yearMonth}')">&#128424; 打印</button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty salaryList}">
                        <tr><td colspan="10" class="empty-state"><div class="empty-icon">&#128203;</div><p>暂无薪资数据</p><p style="font-size:13px;color:#9ca3af;">请点击上方「生成当月薪资」按钮来生成</p></td></tr>
                    </c:if>
                </tbody>
            </table>

            <jsp:include page="/views/common/pagination.jsp"/>

            <!-- 薪资计算规则说明 -->
            <div class="rule-box">
                <strong>&#128208; 薪资计算公式：</strong>
                实际工资 = 基本工资 + 全勤奖(300) - 迟到扣款 - 请假扣款
                &nbsp;|&nbsp;
                迟到扣款 = 次数 &#215; (月薪 / 21.75 / 8)
                &nbsp;|&nbsp;
                请假扣款 = (月薪 / 21.75) &#215; 天数
            </div>
        </div>
    </div>
</div>

<script>
function goPage(p) {
    document.getElementById('pageInput').value = p;
    document.getElementById('salaryForm').submit();
}
</script>

<!-- 薪资条打印弹窗 -->
<div id="slipModal" class="modal-overlay">
    <div class="modal-box" style="max-width:520px;">
        <div id="slipContent"></div>
        <div class="modal-actions" style="margin-top:20px;">
            <button class="btn btn-outline" onclick="document.getElementById('slipModal').classList.remove('active')">关闭</button>
            <button class="btn btn-primary" onclick="printSalarySlip()">&#128424; 打印薪资条</button>
        </div>
    </div>
</div>

<script>
function showSalarySlip(name, empNo, dept, base, bonus, late, leave, actual, status, ym) {
    var html = 
        '<div class="salary-slip">' +
        '<div class="salary-slip-header">' +
        '<h2>&#128176; 薪资条</h2>' +
        '<p>' + ym + ' | ' + dept + '</p>' +
        '</div>' +
        '<div class="salary-slip-body">' +
        '<div class="salary-slip-row"><span class="label">姓名</span><span class="value">' + name + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">工号</span><span class="value">' + empNo + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">基本工资</span><span class="value">&#165; ' + base + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">全勤奖</span><span class="value" style="color:#0d9e6c;">+ &#165; ' + (bonus || '0.00') + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">迟到扣款</span><span class="value" style="color:#dc3545;">- &#165; ' + (late || '0.00') + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">请假扣款</span><span class="value" style="color:#dc3545;">- &#165; ' + (leave || '0.00') + '</span></div>' +
        '<div class="salary-slip-row total"><span class="label">&#128176; 实发工资</span><span class="value">&#165; ' + actual + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">发放状态</span><span class="value">' + status + '</span></div>' +
        '</div>' +
        '<div class="salary-slip-footer">本薪资条由系统自动生成，如有疑问请联系人力资源部</div>' +
        '</div>';
    document.getElementById('slipContent').innerHTML = html;
    document.getElementById('slipModal').classList.add('active');
}

// 在新窗口中打印，只显示薪资条内容
function printSalarySlip() {
    var content = document.getElementById('slipContent').innerHTML;
    var win = window.open('', '_blank', 'width=600,height=600');
    win.document.write('<html><head><meta charset="UTF-8"><title>薪资条</title>');
    win.document.write('<style>');
    win.document.write('*{margin:0;padding:0;box-sizing:border-box;}');
    win.document.write('body{font-family:"Microsoft YaHei","PingFang SC",sans-serif;padding:20px;color:#1f2937;}');
    win.document.write('.salary-slip{max-width:500px;margin:0 auto;border:2px solid #1a73e8;border-radius:12px;overflow:hidden;}');
    win.document.write('.salary-slip-header{background:linear-gradient(135deg,#1e3a5f,#2980b9);color:#fff;padding:24px;text-align:center;}');
    win.document.write('.salary-slip-header h2{font-size:20px;margin-bottom:4px;}');
    win.document.write('.salary-slip-header p{font-size:13px;opacity:0.85;}');
    win.document.write('.salary-slip-body{padding:24px;}');
    win.document.write('.salary-slip-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px dashed #e5e7eb;font-size:14px;}');
    win.document.write('.salary-slip-row .label{color:#6b7280;}');
    win.document.write('.salary-slip-row .value{font-weight:600;}');
    win.document.write('.salary-slip-row.total{border-bottom:none;border-top:2px solid #1a73e8;margin-top:8px;padding-top:14px;}');
    win.document.write('.salary-slip-row.total .value{font-size:18px;color:#0d9e6c;}');
    win.document.write('.salary-slip-footer{text-align:center;padding:16px;background:#f8fafc;font-size:12px;color:#9ca3af;}');
    win.document.write('@page{size:auto;margin:0;}');
    win.document.write('</style></head><body>');
    win.document.write(content);
    win.document.write('</body></html>');
    win.document.close();
    win.focus();
    setTimeout(function(){ win.print(); win.close(); }, 500);
}
</script>
</body>
</html>
