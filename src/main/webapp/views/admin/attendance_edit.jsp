<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>编辑考勤记录 - 管理后台</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .edit-form {
            max-width: 500px;
            background: #fff;
            padding: 28px 32px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
        }
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
        }
        .form-group input[readonly] {
            background: #f1f5f9;
            color: #64748b;
        }
        .form-actions {
            display: flex;
            gap: 12px;
            margin-top: 24px;
        }
        .form-actions .btn {
            padding: 9px 24px;
            font-size: 14px;
        }
        .readonly-info {
            background: #f8fafc;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid #e2e8f0;
        }
        .readonly-info p {
            margin: 4px 0;
            font-size: 13px;
            color: #475569;
        }
        .readonly-info strong {
            color: #1e293b;
        }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">考勤薪资系统 <span>| 管理后台</span></div>
    <div class="navbar-right">
        <span class="user-info">${currentUser.name} (管理员)</span>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-link">安全退出</a>
    </div>
</nav>

<div class="main-container">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/admin?action=dashboard">&#127968; 管理首页</a>
        <span class="separator">&#8250;</span>
        <a href="${pageContext.request.contextPath}/admin?action=attendanceList">考勤管理</a>
        <span class="separator">&#8250;</span>
        <span class="current">编辑考勤记录</span>
    </div>

    <h2 class="page-title">&#9998; 编辑考勤记录</h2>

    <div class="edit-form">
        <!-- 只读信息展示 -->
        <div class="readonly-info">
            <p><strong>员工：</strong>${record.empName}</p>
            <p><strong>部门：</strong>${record.deptName != null ? record.deptName : '--'}</p>
            <p><strong>日期：</strong>${record.workDate}</p>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/admin">
            <input type="hidden" name="action" value="attendanceUpdate">
            <input type="hidden" name="id" value="${record.id}">

            <div class="form-group">
                <label>上班时间</label>
                <input type="datetime-local" name="checkInTime"
                       value="${record.checkInTime != null ? record.checkInTime.toString().substring(0, 16) : ''}">
                <small style="color:#94a3b8;">留空表示未打卡</small>
            </div>

            <div class="form-group">
                <label>下班时间</label>
                <input type="datetime-local" name="checkOutTime"
                       value="${record.checkOutTime != null ? record.checkOutTime.toString().substring(0, 16) : ''}">
                <small style="color:#94a3b8;">留空表示未打卡</small>
            </div>

            <div class="form-group">
                <label>考勤状态</label>
                <select name="status" required>
                    <option value="正常" ${record.status == '正常' ? 'selected' : ''}>正常</option>
                    <option value="迟到" ${record.status == '迟到' ? 'selected' : ''}>迟到</option>
                    <option value="早退" ${record.status == '早退' ? 'selected' : ''}>早退</option>
                    <option value="缺勤" ${record.status == '缺勤' ? 'selected' : ''}>缺勤</option>
                </select>
            </div>

            <div class="form-group">
                <label>工时（小时）</label>
                <input type="number" name="workHours" step="0.1" min="0" max="24"
                       value="${record.workHours != null ? record.workHours : ''}">
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">保存修改</button>
                <a href="${pageContext.request.contextPath}/admin?action=attendanceList" class="btn btn-secondary">取消</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
