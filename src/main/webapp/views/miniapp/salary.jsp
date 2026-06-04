<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>薪资查询 - 小程序</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --primary: #1a73e8;
            --success: #0d9e6c;
            --danger: #dc3545;
            --bg: #f0f2f5;
            --card-bg: #ffffff;
            --text: #1f2937;
            --text-secondary: #6b7280;
            --border: #e5e7eb;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            padding-bottom: 80px;
            -webkit-tap-highlight-color: transparent;
        }

        .header {
            background: linear-gradient(135deg, #1e3a5f 0%, #2980b9 100%);
            color: #fff;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            position: sticky;
            top: 0;
            z-index: 100;
            padding-top: max(16px, env(safe-area-inset-top));
        }
        .header .back-btn {
            color: #fff;
            text-decoration: none;
            font-size: 22px;
            padding: 4px 8px;
            border-radius: 8px;
        }
        .header .back-btn:active { background: rgba(255,255,255,0.15); }
        .header .title { font-size: 17px; font-weight: 700; }

        .container {
            max-width: 480px;
            margin: 0 auto;
            padding: 16px;
        }

        /* 月份选择 */
        .month-picker {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            background: var(--card-bg);
            border-radius: 16px;
            padding: 14px 20px;
            margin-bottom: 16px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .month-picker .arrow-btn {
            width: 36px;
            height: 36px;
            border: 1.5px solid var(--border);
            background: #fff;
            border-radius: 50%;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text);
            transition: all 0.2s;
        }
        .month-picker .arrow-btn:active { background: #f0f2f5; border-color: var(--primary); }
        .month-picker .month-label {
            font-size: 18px;
            font-weight: 700;
            min-width: 120px;
            text-align: center;
        }

        /* 薪资总览卡片 */
        .salary-total-card {
            background: linear-gradient(135deg, #0d9e6c, #34d399);
            color: #fff;
            border-radius: 16px;
            padding: 28px 24px;
            text-align: center;
            margin-bottom: 16px;
            box-shadow: 0 4px 16px rgba(13,158,108,0.3);
        }
        .salary-total-card .total-label {
            font-size: 13px;
            opacity: 0.85;
            margin-bottom: 8px;
        }
        .salary-total-card .total-amount {
            font-size: 42px;
            font-weight: 700;
            font-family: 'SF Mono', 'Menlo', monospace;
        }
        .salary-total-card .total-amount .unit {
            font-size: 20px;
            font-weight: 400;
        }

        /* 明细卡片 */
        .detail-card {
            background: var(--card-bg);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            margin-bottom: 16px;
        }
        .detail-card .card-title {
            padding: 14px 20px;
            font-size: 15px;
            font-weight: 700;
            border-bottom: 1px solid var(--border);
        }
        .detail-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 20px;
            border-bottom: 1px solid var(--border);
            font-size: 14px;
        }
        .detail-item:last-child { border-bottom: none; }
        .detail-item .item-label {
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .detail-item .item-value {
            font-weight: 600;
            font-size: 15px;
        }
        .item-value.income { color: var(--success); }
        .item-value.deduct { color: var(--danger); }
        .item-value.total { color: var(--primary); font-size: 17px; }
        .detail-item.total-row {
            background: #f8fafc;
            font-weight: 700;
        }

        .empty-state {
            text-align: center;
            padding: 48px 20px;
            color: #9ca3af;
        }
        .empty-state .empty-icon { font-size: 48px; margin-bottom: 12px; }
        .empty-state p { font-size: 15px; }

        /* Toast */
        .toast {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%) translateY(-120px);
            padding: 14px 28px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            color: #fff;
            z-index: 9999;
            transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }

        /* 底部导航 */
        .bottom-nav {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: var(--card-bg);
            display: flex;
            border-top: 1px solid var(--border);
            z-index: 99;
            padding-bottom: env(safe-area-inset-bottom);
            box-shadow: 0 -2px 12px rgba(0,0,0,0.04);
        }
        .bottom-nav .nav-item {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 10px 0;
            text-decoration: none;
            color: var(--text-secondary);
            font-size: 11px;
            transition: all 0.2s;
            gap: 4px;
        }
        .bottom-nav .nav-item .nav-icon { font-size: 22px; }
    </style>
</head>
<body>

<div class="header">
    <a href="${pageContext.request.contextPath}/miniapp?action=clock" class="back-btn">←</a>
    <div class="title">💰 薪资查询</div>
</div>

<div class="toast" id="toast"></div>

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="container">
    <!-- 月份选择 -->
    <form method="get" action="${pageContext.request.contextPath}/miniapp" style="margin:0;">
        <input type="hidden" name="action" value="salary">
        <div class="month-picker">
            <button type="button" class="arrow-btn" onclick="changeMonth(-1)">◀</button>
            <div class="month-label" id="monthLabel">${yearMonth.substring(0,4)}年${yearMonth.substring(5)}月</div>
            <button type="button" class="arrow-btn" onclick="changeMonth(1)">▶</button>
        </div>
        <input type="hidden" name="yearMonth" id="yearMonthInput" value="${yearMonth}">
    </form>

    <!-- 薪资数据区域 -->
    <c:choose>
        <c:when test="${not empty salary}">
            <div class="salary-total-card">
                <div class="total-label">实发工资</div>
                <div class="total-amount"><span class="unit">¥</span>${salary.actualSalary}</div>
            </div>

            <div class="detail-card">
                <div class="card-title">💰 收入项</div>
                <div class="detail-item">
                    <span class="item-label">📋 基本工资</span>
                    <span class="item-value income">¥${salary.baseSalary}</span>
                </div>
                <div class="detail-item">
                    <span class="item-label">🎁 全勤奖</span>
                    <span class="item-value income">¥${salary.attendanceBonus}</span>
                </div>
                <div class="detail-item">
                    <span class="item-label">⏰ 加班费</span>
                    <span class="item-value income">¥${salary.overtimePay}</span>
                </div>
            </div>

            <div class="detail-card">
                <div class="card-title">📉 扣除项</div>
                <div class="detail-item">
                    <span class="item-label">⏰ 迟到扣款</span>
                    <span class="item-value deduct">-¥${salary.deductionLate}</span>
                </div>
                <div class="detail-item">
                    <span class="item-label">📝 请假扣款</span>
                    <span class="item-value deduct">-¥${salary.deductionLeave}</span>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="empty-icon">📭</div>
                <p>${yearMonth.substring(0,4)}年${yearMonth.substring(5)}月暂无薪资数据</p>
                <p style="font-size:12px;color:#c0c0c0;margin-top:4px;">请等待管理员生成薪资</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- 底部导航 -->
<div class="bottom-nav">
    <a href="${pageContext.request.contextPath}/miniapp?action=clock" class="nav-item">
        <span class="nav-icon">🏠</span>
        打卡
    </a>
    <a href="${pageContext.request.contextPath}/miniapp?action=records" class="nav-item">
        <span class="nav-icon">📋</span>
        记录
    </a>
    <a href="${pageContext.request.contextPath}/miniapp?action=my" class="nav-item">
        <span class="nav-icon">👤</span>
        我的
    </a>
</div>

<script>
    function changeMonth(offset) {
        var label = document.getElementById('monthLabel').textContent;
        var parts = label.replace('月','').split('年');
        var y = parseInt(parts[0]);
        var m = parseInt(parts[1]) + offset;
        if (m < 1) { m = 12; y--; }
        if (m > 12) { m = 1; y++; }
        var newMonth = y + '-' + String(m).padStart(2, '0');
        window.location.href = '${pageContext.request.contextPath}/miniapp?action=salary&yearMonth=' + newMonth;
    }
</script>
</body>
</html>
