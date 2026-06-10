<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="_csrf" content="${pageContext.session.getAttribute('CSRF_TOKEN')}"><title>薪资管理 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .salary-summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; margin-bottom: 18px; }
    .summary-item { background: var(--surface); border-radius: 10px; padding: 18px; text-align: center; box-shadow: var(--shadow); border: 1px solid var(--border); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }
    .summary-item .num { font-size: 24px; font-weight: 700; color: var(--ink); }
    .summary-item .label { font-size: 12px; color: var(--ink-muted); margin-top: 4px; }
    .export-bar { display: flex; gap: 10px; margin-bottom: 18px; flex-wrap: wrap; }
    .data-table tbody tr { transition: all 0.2s; }
    .paid-row { background: rgba(52,211,153,0.06) !important; }
    .paid-row:hover { background: rgba(52,211,153,0.12) !important; }
    .search-box { position: relative; flex: 1; min-width: 200px; max-width: 300px; }
    .search-box input { padding-left: 34px !important; width: 100%; }
    .search-box .search-icon { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--ink-muted); font-size: 0.9rem; pointer-events: none; }
    /* 薪资条弹窗预览样式 */
    .salary-slip { border: 2px solid var(--border-glow); border-radius: 12px; overflow: hidden; font-size: 14px; }
    .salary-slip-header { background: linear-gradient(135deg, #3b82f6, #06b6d4); color: #fff; padding: 20px 24px; text-align: center; }
    .salary-slip-header h2 { font-size: 20px; margin-bottom: 2px; }
    .salary-slip-header p { font-size: 13px; opacity: 0.85; }
    .salary-slip-body { padding: 8px 16px; }
    .salary-slip-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #e5e7eb; font-size: 13px; }
    .salary-slip-row .label { color: #6b7280; }
    .salary-slip-row .value { font-weight: 600; color: var(--ink); }
    .salary-slip-row.total { border-bottom: none; border-top: 2px solid #06b6d4; margin-top: 6px; padding-top: 12px; }
    .salary-slip-row.total .value { font-size: 18px; color: #059669; }
    .salary-slip-footer { text-align: center; padding: 12px 16px; background: #f8fafc; font-size: 12px; color: #9ca3af; border-top: 1px solid #e5e7eb; }
</style>
</head>
<body>
<nav class="navbar"><div class="navbar-brand">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="rgba(56,189,248,0.9)" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
    考勤薪资系统 <span>| 薪资管理</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
    <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div></nav>

<div class="main-container">
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
            <div class="num" style="color:var(--success);">
                <c:set var="totalActual" value="0"/>
                <c:forEach items="${salaryList}" var="s">
                    <c:if test="${s.actualSalary != null}">
                        <c:set var="totalActual" value="${totalActual + s.actualSalary}"/>
                    </c:if>
                </c:forEach>
                &yen; ${totalActual}
            </div>
            <div class="label">实发总额</div>
        </div>
        <div class="summary-item">
            <div class="num" style="color:var(--warning);">
                <c:set var="unpaidCount" value="0"/>
                <c:forEach items="${salaryList}" var="s">
                    <c:if test="${s.status == '未发放'}"><c:set var="unpaidCount" value="${unpaidCount + 1}"/></c:if>
                </c:forEach>
                ${unpaidCount}
            </div>
            <div class="label">未发放人数</div>
        </div>
        <div class="summary-item">
            <div class="num" style="color:var(--brand);">
                <c:set var="paidCount" value="0"/>
                <c:forEach items="${salaryList}" var="s">
                    <c:if test="${s.status == '已发放'}"><c:set var="paidCount" value="${paidCount + 1}"/></c:if>
                </c:forEach>
                ${paidCount}
            </div>
            <div class="label">已发放人数</div>
        </div>
    </div>

    <!-- 操作栏：月份筛选 + 搜索 + 操作按钮 -->
    <div class="filter-bar">
        <form method="get" id="salaryForm" style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;width:100%;">
            <input type="hidden" name="action" value="salaryList">
            <input type="hidden" name="page" id="pageInput" value="${currentPage}">
            <label>&#128197; 月份：</label>
            <input type="month" name="yearMonth" value="${yearMonth}" style="width:160px;">
            <div class="search-box">
                <span class="search-icon">&#128269;</span>
                <input type="text" name="search" placeholder="搜索工号/姓名..." value="${search != null ? search : ''}" style="width:200px;">
            </div>
            <button type="submit" class="btn btn-primary btn-sm" onclick="document.getElementById('pageInput').value='1'">&#128269; 查询</button>
            <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('searchInput').value='';document.getElementById('salaryForm').submit();">&#8634; 清除</button>
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
        <div class="card-header">${yearMonth} 薪资列表 <span style="font-weight:400;font-size:13px;color:var(--ink-muted);">(${totalCount} 条记录<c:if test="${not empty search}">，搜索: "${search}"</c:if>)</span></div>
        <div class="card-body table-wrapper">
            <table class="data-table" id="salaryTable">
                <thead><tr>
                    <th>工号</th><th>姓名</th><th>部门</th><th>基本工资</th><th>全勤奖</th>
                    <th>迟到扣款</th><th>请假扣款</th><th>实际工资</th><th>状态</th><th>操作</th>
                </tr></thead>
                <tbody>
                    <c:forEach items="${salaryList}" var="s">
                        <tr class="${s.status == '已发放' ? 'paid-row' : ''}">
                            <td><code>${s.empNo}</code></td>
                            <td><strong>${s.empName}</strong></td>
                            <td>${s.deptName != null ? s.deptName : '--'}</td>
                            <td>&yen; ${s.baseSalary != null ? s.baseSalary : '0.00'}</td>
                            <td style="color:var(--success);">+ &yen; ${s.attendanceBonus != null && s.attendanceBonus > 0 ? s.attendanceBonus : '0.00'}</td>
                            <td style="color:var(--danger);">- &yen; ${s.deductionLate != null && s.deductionLate > 0 ? s.deductionLate : '0.00'}</td>
                            <td style="color:var(--danger);">- &yen; ${s.deductionLeave != null && s.deductionLeave > 0 ? s.deductionLeave : '0.00'}</td>
                            <td><strong style="color:var(--success);font-size:16px;">&yen; ${s.actualSalary != null ? s.actualSalary : '0.00'}</strong></td>
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
                                    <span style="color:var(--success);font-size:13px;font-weight:600;">已发放 &#10003;</span>
                                </c:if>
                                <button type="button" class="btn btn-outline btn-sm" style="margin-left:4px;" onclick="showSalarySlip('${s.empName}','${s.empNo}','${s.deptName}','${s.baseSalary}','${s.attendanceBonus}','${s.deductionLate}','${s.deductionLeave}','${s.actualSalary}','${s.status}','${yearMonth}','${s.generateTime}','${s.payTime}')">&#128424; 打印</button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty salaryList}">
                        <tr><td colspan="10" class="empty-state"><div class="empty-icon">&#128203;</div><p>暂无薪资数据</p><p style="font-size:13px;color:var(--ink-muted);">请点击上方「生成当月薪资」按钮来生成</p></td></tr>
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
// 分页导航：保留月份和搜索参数
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
function showSalarySlip(name, empNo, dept, base, bonus, late, leave, actual, status, ym, genTime, payTime) {
    var now = new Date();
    var timeStr = now.getFullYear() + '-' + String(now.getMonth()+1).padStart(2,'0') + '-' + String(now.getDate()).padStart(2,'0') + ' ' + String(now.getHours()).padStart(2,'0') + ':' + String(now.getMinutes()).padStart(2,'0');
    var payHtml = '';
    if (payTime && payTime != '' && payTime != 'null') {
        payHtml = '<div class="salary-slip-row"><span class="label">发放时间</span><span class="value" style="color:#059669;">' + payTime + '</span></div>';
    }
    var genHtml = '';
    if (genTime && genTime != '' && genTime != 'null') {
        genHtml = '<div class="salary-slip-row"><span class="label">生成时间</span><span class="value" style="color:#64748b;">' + genTime + '</span></div>';
    } else {
        genHtml = '<div class="salary-slip-row"><span class="label">打印时间</span><span class="value" style="color:#64748b;">' + timeStr + '</span></div>';
    }
    var html = 
        '<div class="salary-slip">' +
        '<div class="salary-slip-header">' +
        '<h2>薪资条</h2>' +
        '<p>' + ym + ' &nbsp;|&nbsp; ' + (dept || '--') + '</p>' +
        '</div>' +
        '<div class="salary-slip-body">' +
        '<div class="salary-slip-row"><span class="label">姓名</span><span class="value">' + name + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">工号</span><span class="value">' + empNo + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">基本工资</span><span class="value">¥ ' + (base || '0.00') + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">全勤奖</span><span class="value" style="color:#059669;">+ ¥ ' + (bonus || '0.00') + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">迟到扣款</span><span class="value" style="color:#dc2626;">- ¥ ' + (late || '0.00') + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">请假扣款</span><span class="value" style="color:#dc2626;">- ¥ ' + (leave || '0.00') + '</span></div>' +
        '<div class="salary-slip-row total"><span class="label">实发工资</span><span class="value">¥ ' + (actual || '0.00') + '</span></div>' +
        '<div class="salary-slip-row"><span class="label">发放状态</span><span class="value">' + status + '</span></div>' +
        genHtml + payHtml +
        '</div>' +
        '<div class="salary-slip-footer">本薪资条由系统自动生成，如有疑问请联系人力资源部</div>' +
        '</div>';
    document.getElementById('slipContent').innerHTML = html;
    document.getElementById('slipModal').classList.add('active');
}

function printSalarySlip() {
    var content = document.getElementById('slipContent').innerHTML;
    var win = window.open('', '_blank', 'width=600,height=600');
    win.document.write('<html><head><meta charset="UTF-8"><title>薪资条</title>');
    win.document.write('<style>');
    win.document.write('*{margin:0;padding:0;box-sizing:border-box;}');
    win.document.write('body{font-family:"Microsoft YaHei","PingFang SC",sans-serif;padding:20px;color:#1f2937;}');
    win.document.write('.salary-slip{max-width:500px;margin:0 auto;border:2px solid #38bdf8;border-radius:12px;overflow:hidden;font-size:14px;}');
    win.document.write('.salary-slip-header{background:linear-gradient(135deg,#3b82f6,#06b6d4);color:#fff;padding:20px 24px;text-align:center;}');
    win.document.write('.salary-slip-header h2{font-size:20px;margin-bottom:2px;}');
    win.document.write('.salary-slip-header p{font-size:13px;opacity:0.85;}');
    win.document.write('.salary-slip-body{padding:8px 16px;}');
    win.document.write('.salary-slip-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px dashed #e5e7eb;font-size:13px;}');
    win.document.write('.salary-slip-row .label{color:#6b7280;}');
    win.document.write('.salary-slip-row .value{font-weight:600;}');
    win.document.write('.salary-slip-row.total{border-bottom:none;border-top:2px solid #06b6d4;margin-top:6px;padding-top:12px;}');
    win.document.write('.salary-slip-row.total .value{font-size:18px;color:#059669;}');
    win.document.write('.salary-slip-footer{text-align:center;padding:12px 16px;background:#f8fafc;font-size:12px;color:#9ca3af;border-top:1px solid #e5e7eb;}');
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
