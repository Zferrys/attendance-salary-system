<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>请假申请 - 小程序</title>
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

        .form-card {
            background: var(--card-bg);
            border-radius: 16px;
            padding: 24px 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 8px;
        }
        .form-group select,
        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 12px 16px;
            border: 1.5px solid var(--border);
            border-radius: 12px;
            font-size: 15px;
            color: var(--text);
            background: #f9fafb;
            outline: none;
            transition: all 0.25s;
            font-family: inherit;
        }
        .form-group select:focus,
        .form-group input:focus,
        .form-group textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(26,115,232,0.12);
            background: #fff;
        }
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        .date-row {
            display: flex;
            gap: 12px;
        }
        .date-row .form-group {
            flex: 1;
        }

        .submit-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #1a73e8, #4a90d9);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.25s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 4px;
        }
        .submit-btn:active {
            transform: scale(0.97);
            opacity: 0.9;
        }
        .submit-btn.loading {
            pointer-events: none;
            opacity: 0.7;
        }
        .submit-btn .spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 2.5px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
        }
        .submit-btn.loading .spinner { display: inline-block; }
        .submit-btn.loading .btn-text { display: none; }

        @keyframes spin { to { transform: rotate(360deg); } }

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
            white-space: nowrap;
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }

        .overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9998;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s;
        }
        .overlay.show { opacity: 1; pointer-events: all; }
        .overlay .loader {
            width: 48px;
            height: 48px;
            border: 4px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

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
    <div class="title">📝 请假申请</div>
</div>

<div class="toast" id="toast"></div>
<div class="overlay" id="overlay"><div class="loader"></div></div>

<div class="container">
    <div class="form-card">
        <form id="leaveForm" onsubmit="submitLeave(event)">
            <div class="form-group">
                <label for="leaveType">请假类型</label>
                <select id="leaveType" name="leaveType" required>
                    <option value="">请选择请假类型</option>
                    <option value="事假">事假</option>
                    <option value="病假">病假</option>
                    <option value="年假">年假</option>
                    <option value="调休">调休</option>
                    <option value="婚假">婚假</option>
                    <option value="产假">产假</option>
                    <option value="丧假">丧假</option>
                    <option value="其他">其他</option>
                </select>
            </div>

            <div class="date-row">
                <div class="form-group">
                    <label for="startDate">开始日期</label>
                    <input type="date" id="startDate" name="startDate" required>
                </div>
                <div class="form-group">
                    <label for="endDate">结束日期</label>
                    <input type="date" id="endDate" name="endDate" required>
                </div>
            </div>

            <div class="form-group">
                <label for="reason">请假原因</label>
                <textarea id="reason" name="reason" placeholder="请详细说明请假原因..." required></textarea>
            </div>

            <button type="submit" class="submit-btn" id="submitBtn">
                <span class="btn-text">📤 提交申请</span>
                <span class="spinner"></span>
            </button>
        </form>
    </div>
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
    const ctxPath = '${pageContext.request.contextPath}';

    // 设置默认日期
    document.addEventListener('DOMContentLoaded', function() {
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        const todayStr = yyyy + '-' + mm + '-' + dd;
        document.getElementById('startDate').value = todayStr;
        document.getElementById('endDate').value = todayStr;
    });

    function showToast(msg, type) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.className = 'toast ' + (type || 'info');
        requestAnimationFrame(() => toast.classList.add('show'));
        setTimeout(() => toast.classList.remove('show'), 2500);
    }

    function showLoading() { document.getElementById('overlay').classList.add('show'); }
    function hideLoading() { document.getElementById('overlay').classList.remove('show'); }

    function submitLeave(e) {
        e.preventDefault();
        const btn = document.getElementById('submitBtn');

        const leaveType = document.getElementById('leaveType').value;
        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;
        const reason = document.getElementById('reason').value.trim();

        if (!leaveType || !startDate || !endDate || !reason) {
            showToast('请填写完整信息！', 'error');
            return;
        }

        if (endDate < startDate) {
            showToast('结束日期不能早于开始日期！', 'error');
            return;
        }

        btn.classList.add('loading');
        showLoading();

        const formData = new URLSearchParams();
        formData.append('leaveType', leaveType);
        formData.append('startDate', startDate);
        formData.append('endDate', endDate);
        formData.append('reason', reason);

        fetch(ctxPath + '/miniapp?action=submitLeave', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(r => r.json())
        .then(data => {
            hideLoading();
            btn.classList.remove('loading');
            if (data.needLogin) {
                window.location.href = ctxPath + '/miniapp';
                return;
            }
            if (data.success) {
                showToast(data.message, 'success');
                document.getElementById('leaveForm').reset();
                // 重置日期
                const today = new Date();
                const todayStr = today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2,'0') + '-' + String(today.getDate()).padStart(2,'0');
                document.getElementById('startDate').value = todayStr;
                document.getElementById('endDate').value = todayStr;
            } else {
                showToast(data.message, 'error');
            }
        })
        .catch(err => {
            hideLoading();
            btn.classList.remove('loading');
            showToast('网络错误，请重试', 'error');
        });
    }
</script>
</body>
</html>
