<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>月度薪资报表 - 考勤薪资系统</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<style>
    .report-summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-bottom: 20px; }
    .report-card { background: #fff; border-radius: 12px; padding: 22px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); text-align: center; }
    .report-card .num { font-size: 28px; font-weight: 700; color: #1f2937; }
    .report-card .label { font-size: 13px; color: #6b7280; margin-top: 6px; }
    .report-card.highlight { border-left: 4px solid #0d9e6c; }
    .report-card.warn { border-left: 4px solid #f0a020; }
    .chart-section { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 20px; }
    @media (max-width: 768px) { .chart-section { grid-template-columns: 1fr; } }
    .chart-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
    .chart-card h3 { font-size: 15px; color: #374151; margin-bottom: 16px; }
    .bar-row { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; font-size: 13px; }
    .bar-label { width: 80px; text-align: right; color: #6b7280; flex-shrink: 0; }
    .bar-track { flex: 1; height: 24px; background: #f3f4f6; border-radius: 6px; overflow: hidden; position: relative; }
    .bar-fill { height: 100%; border-radius: 6px; transition: width 0.6s; display: flex; align-items: center; padding-left: 8px; color: #fff; font-weight: 600; font-size: 12px; }
    .bar-fill.paid { background: linear-gradient(90deg, #0d9e6c, #34d399); }
    .bar-fill.unpaid { background: linear-gradient(90deg, #f0a020, #fbbf24); }
    .bar-fill.bonus { background: linear-gradient(90deg, #6366f1, #818cf8); }
    .bar-fill.late { background: linear-gradient(90deg, #dc3545, #f87171); }
    .bar-fill.leave { background: linear-gradient(90deg, #f59e0b, #fbbf24); }
    .dept-table { width: 100%; border-collapse: collapse; font-size: 13px; }
    .dept-table th, .dept-table td { padding: 10px 12px; text-align: left; border-bottom: 1px solid #f0f0f0; }
    .dept-table th { color: #6b7280; font-weight: 600; background: #fafafa; }
    .dept-table tr:hover { background: #f9fafb; }
    .export-bar { display: flex; gap: 10px; margin-bottom: 18px; flex-wrap: wrap; }
    .percent-bar { width: 100%; height: 6px; background: #f3f4f6; border-radius: 3px; margin-top: 4px; overflow: hidden; }
    .percent-fill { height: 100%; border-radius: 3px; background: linear-gradient(90deg, #0d9e6c, #34d399); }
</style>
</head>
<body>
<nav class="navbar"><div class="navbar-brand">考勤薪资系统 <span>| 月度薪资报表</span></div>
    <div class="navbar-right"><span class="user-info">${currentUser.name}</span>
    <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a></div></nav>

<div class="main-container">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/admin?action=dashboard">&#127968; 管理首页</a>
        <span class="separator">&#8250;</span>
        <span class="current">月度薪资报表</span>
    </div>

    <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>

    <!-- 月份选择 -->
    <div class="filter-bar">
        <form method="get" style="display:flex;align-items:center;gap:12px;">
            <input type="hidden" name="action" value="salaryReport">
            <label>&#128197; 报表月份：</label>
            <input type="month" name="yearMonth" value="${yearMonth}">
            <button type="submit" class="btn btn-primary btn-sm">&#128269; 查看报表</button>
        </form>
        <button type="button" class="btn btn-info btn-sm" onclick="exportTableToCSV('.dept-table', '薪资报表_${yearMonth}.csv')">&#128190; 导出CSV</button>
        <a href="${pageContext.request.contextPath}/admin?action=dashboard" class="btn btn-outline btn-sm">返回首页</a>
    </div>

    <!-- 无数据提示 -->
    <c:if test="${totalCount == 0}">
        <div style="background:#fffbeb;border:1px solid #fde68a;border-radius:12px;padding:28px;text-align:center;margin-bottom:20px;">
            <div style="font-size:36px;margin-bottom:12px;">&#128203;</div>
            <h3 style="color:#92400e;margin-bottom:8px;">${yearMonth} 暂无薪资数据</h3>
            <p style="color:#a16207;margin-bottom:16px;">请先前往「薪资管理」生成该月份的薪资记录，再回来查看报表。</p>
            <a href="${pageContext.request.contextPath}/admin?action=salaryList&yearMonth=${yearMonth}" class="btn btn-primary">&#9889; 前往薪资管理生成薪资</a>
        </div>
    </c:if>

    <!-- 核心统计卡片 -->
    <c:if test="${totalCount > 0}">
    <div class="report-summary">
        <div class="report-card">
            <div class="num">${totalCount}</div>
            <div class="label">&#128101; 薪资总人数</div>
        </div>
        <div class="report-card highlight">
            <div class="num" style="color:#0d9e6c;">¥ <fmt:formatNumber value="${totalActual}" pattern="#,##0.00"/></div>
            <div class="label">&#128176; 实发薪资总额</div>
        </div>
        <div class="report-card">
            <div class="num" style="color:#1a73e8;">${paidCount}</div>
            <div class="label">&#9989; 已发放人数</div>
            <div class="percent-bar"><div class="percent-fill" style="width:${totalCount > 0 ? paidCount * 100 / totalCount : 0}%"></div></div>
        </div>
        <div class="report-card warn">
            <div class="num" style="color:#f0a020;">${unpaidCount}</div>
            <div class="label">&#9203; 待发放人数</div>
            <div class="percent-bar"><div class="percent-fill" style="width:${totalCount > 0 ? unpaidCount * 100 / totalCount : 0}%; background:#fbbf24;"></div></div>
        </div>
    </div>
    </c:if>

    <!-- 图表区域：发放进度 + 金额构成 -->
    <c:if test="${totalCount > 0}">
    <div class="chart-section">
        <div class="chart-card">
            <h3>&#128202; 发放进度</h3>
            <div class="bar-row">
                <span class="bar-label">已发放</span>
                <div class="bar-track">
                    <c:set var="paidPct" value="${totalCount > 0 ? paidCount * 100.0 / totalCount : 0}"/>
                    <div class="bar-fill paid" style="width:${totalCount > 0 ? paidCount * 100 / totalCount : 0}%; min-width:${paidCount > 0 ? '50px' : '0px'};"><fmt:formatNumber value="${paidPct}" pattern="0"/>%</div>
                </div>
            </div>
            <div class="bar-row">
                <span class="bar-label">待发放</span>
                <div class="bar-track">
                    <c:set var="unpaidPct" value="${totalCount > 0 ? unpaidCount * 100.0 / totalCount : 0}"/>
                    <div class="bar-fill unpaid" style="width:${totalCount > 0 ? unpaidCount * 100 / totalCount : 0}%; min-width:${unpaidCount > 0 ? '50px' : '0px'};"><fmt:formatNumber value="${unpaidPct}" pattern="0"/>%</div>
                </div>
            </div>
            <p style="font-size:12px;color:#9ca3af;margin-top:12px;">
                <c:if test="${unpaidCount > 0}">&#9888; 还有 ${unpaidCount} 人薪资待发放，请前往 <a href="${pageContext.request.contextPath}/admin?action=salaryList&yearMonth=${yearMonth}">薪资管理</a> 执行发放。</c:if>
                <c:if test="${unpaidCount == 0 && totalCount > 0}">&#127881; 所有薪资已全部发放完毕！</c:if>
            </p>
        </div>

        <div class="chart-card">
            <h3>&#128176; 薪资构成汇总</h3>
            <div class="bar-row">
                <span class="bar-label">基本工资</span>
                <div class="bar-track">
                    <div class="bar-fill" style="background:linear-gradient(90deg, #1a73e8, #60a5fa); width:100%; min-width:50px;">¥ <fmt:formatNumber value="${totalBase}" pattern="#,##0.00"/></div>
                </div>
            </div>
            <div class="bar-row">
                <span class="bar-label">全勤奖</span>
                <div class="bar-track">
                    <div class="bar-fill bonus" style="width:100%; min-width:50px;">¥ <fmt:formatNumber value="${totalBonus}" pattern="#,##0.00"/></div>
                </div>
            </div>
            <div class="bar-row">
                <span class="bar-label">迟到扣款</span>
                <div class="bar-track">
                    <div class="bar-fill late" style="width:100%; min-width:50px;">- ¥ <fmt:formatNumber value="${totalLate}" pattern="#,##0.00"/></div>
                </div>
            </div>
            <div class="bar-row">
                <span class="bar-label">请假扣款</span>
                <div class="bar-track">
                    <div class="bar-fill leave" style="width:100%; min-width:50px;">- ¥ <fmt:formatNumber value="${totalLeave}" pattern="#,##0.00"/></div>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <!-- 部门维度统计 -->
    <c:if test="${totalCount > 0}">
    <div class="chart-card" style="margin-bottom:20px;">
        <h3>&#127970; 部门薪资分布</h3>
        <table class="dept-table">
            <thead><tr><th>部门</th><th>人数</th><th>占比</th></tr></thead>
            <tbody>
                <c:set var="printedDepts" value=""/>
                <c:set var="deptIndex" value="0"/>
                <c:forEach items="${salaryList}" var="s">
                    <c:set var="dname" value="${s.deptName != null ? s.deptName : '未知'}"/>
                    <c:if test="${not printedDepts.contains(dname)}">
                        <c:set var="deptCount" value="0"/>
                        <c:forEach items="${salaryList}" var="s2">
                            <c:set var="dname2" value="${s2.deptName != null ? s2.deptName : '未知'}"/>
                            <c:if test="${dname == dname2}">
                                <c:set var="deptCount" value="${deptCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        <tr>
                            <td>${dname}</td>
                            <td>${deptCount} 人</td>
                            <td>
                                <div style="display:flex;align-items:center;gap:8px;">
                                    <c:set var="deptPct" value="${totalCount > 0 ? deptCount * 100.0 / totalCount : 0}"/>
                                    <div style="flex:1;height:6px;background:#f3f4f6;border-radius:3px;overflow:hidden;">
                                        <div style="height:100%;border-radius:3px;background:linear-gradient(90deg,#6366f1,#818cf8);width:${totalCount > 0 ? deptCount * 100 / totalCount : 0}%;"></div>
                                    </div>
                                    <span style="font-size:12px;color:#6b7280;"><fmt:formatNumber value="${deptPct}" pattern="0"/>%</span>
                                </div>
                            </td>
                        </tr>
                        <c:set var="printedDepts" value="${printedDepts}${dname},"/>
                    </c:if>
                </c:forEach>
            </tbody>
        </table>
    </div>
    </c:if>

    <!-- 明细列表 -->
    <div class="card">
        <div class="card-header">${yearMonth} 薪资明细 <span style="font-weight:400;font-size:13px;color:#6b7280;">(${totalCount} 条记录)</span></div>
        <div class="card-body table-wrapper">
            <table class="data-table dept-table">
                <thead><tr>
                    <th>工号</th><th>姓名</th><th>部门</th><th>基本工资</th>
                    <th>全勤奖</th><th>迟到扣款</th><th>请假扣款</th><th>实际工资</th><th>状态</th>
                </tr></thead>
                <tbody>
                    <c:forEach items="${salaryList}" var="s">
                        <tr>
                            <td><code style="background:#f3f4f6;padding:2px 8px;border-radius:4px;">${s.empNo}</code></td>
                            <td><strong>${s.empName}</strong></td>
                            <td>${s.deptName != null ? s.deptName : '--'}</td>
                            <td>¥ ${s.baseSalary != null ? s.baseSalary : '0.00'}</td>
                            <td style="color:#0d9e6c;">+ ¥ ${s.attendanceBonus != null && s.attendanceBonus > 0 ? s.attendanceBonus : '0.00'}</td>
                            <td style="color:#dc3545;">- ¥ ${s.deductionLate != null && s.deductionLate > 0 ? s.deductionLate : '0.00'}</td>
                            <td style="color:#dc3545;">- ¥ ${s.deductionLeave != null && s.deductionLeave > 0 ? s.deductionLeave : '0.00'}</td>
                            <td><strong style="color:#0d9e6c;font-size:15px;">¥ ${s.actualSalary != null ? s.actualSalary : '0.00'}</strong></td>
                            <td><span class="status-badge status-${s.status}">${s.status}</span></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty salaryList}">
                        <tr><td colspan="9" class="empty-state"><div class="empty-icon">&#128203;</div><p>暂无薪资数据</p></td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 快捷入口 -->
    <div style="margin-top:20px;padding:16px;background:#f9fafb;border-radius:8px;text-align:center;">
        <span style="color:#6b7280;margin-right:16px;">&#128269; 需要进行薪资操作？</span>
        <a href="${pageContext.request.contextPath}/admin?action=salaryList&yearMonth=${yearMonth}" class="btn btn-primary btn-sm">&#9889; 进入薪资管理（生成/发放）</a>
    </div>
</div>
</body>
</html>
