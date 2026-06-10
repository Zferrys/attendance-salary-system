package com.attendance.servlet;

import com.attendance.entity.Employee;
import com.attendance.service.EmployeeService;
import com.attendance.service.impl.EmployeeServiceImpl;
import com.attendance.utils.CsrfUtil;
import com.attendance.utils.LoginGuardUtil;
import com.attendance.utils.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * 登录Servlet - 安全增强版
 *
 * 安全特性:
 *   - Session固定攻击防护（登录成功后重建Session）
 *   - 暴力破解防护（连续5次失败锁定15分钟）
 *   - CSRF Token防护
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private EmployeeService employeeService = new EmployeeServiceImpl();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("logout".equals(action)) {
            doLogout(req, resp);
            return;
        }

        if ("login".equals(action) || action == null) {
            doLogin(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/views/common/login.jsp");
        }
    }

    /**
     * 安全登出：清除会话，重定向到登录页
     */
    private void doLogout(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/views/common/login.jsp");
    }

    /**
     * 安全登录：带暴力破解防护和Session固定攻击防护
     */
    private void doLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String empNo = req.getParameter("empNo");
        String password = req.getParameter("password");
        String clientIp = LoginGuardUtil.getClientIp(req);

        // 基础参数校验
        if (empNo == null || empNo.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            req.setAttribute("errorMsg", "请输入工号和密码");
            req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
            return;
        }

        empNo = empNo.trim();
        password = password.trim();

        // 检查IP是否被锁定
        String ipLockMsg = LoginGuardUtil.checkLocked(clientIp);
        if (ipLockMsg != null) {
            req.setAttribute("errorMsg", ipLockMsg);
            req.setAttribute("empNo", empNo);
            req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
            return;
        }

        // 检查账号是否被锁定
        String accountLockMsg = LoginGuardUtil.checkAccountLocked(empNo);
        if (accountLockMsg != null) {
            req.setAttribute("errorMsg", accountLockMsg);
            req.setAttribute("empNo", empNo);
            req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
            return;
        }

        // 调用Service层进行登录验证
        Employee employee = employeeService.loginByEmpNo(empNo, password);

        if (employee != null) {
            // 登录成功
            onLoginSuccess(req, resp, employee, clientIp, empNo, password);
        } else {
            // 登录失败
            onLoginFailure(req, resp, clientIp, empNo);
        }
    }

    /**
     * 登录成功处理
     * 
     * Session固定攻击防护: 销毁旧Session，创建新Session
     */
    private void onLoginSuccess(HttpServletRequest req, HttpServletResponse resp,
                                 Employee employee, String clientIp, String empNo,
                                 String password)
            throws IOException {
        // 清除失败记录
        LoginGuardUtil.clearFailures(clientIp, empNo);

        // 密码自动升级：如果数据库中的密码还不是PBKDF2格式，登录成功后自动升级
        String storedPassword = employee.getPassword();
        if (PasswordUtil.needsUpgrade(storedPassword)) {
            try {
                String newHashedPassword = PasswordUtil.hash(password);
                employee.setPassword(newHashedPassword);
                employeeService.updatePassword(employee.getId(), newHashedPassword);
                System.out.println("[密码升级] 工号: " + empNo + " 密码已从旧格式升级为PBKDF2");
            } catch (Exception e) {
                // 升级失败不影响登录，只记录日志
                System.err.println("[密码升级] 失败 - 工号: " + empNo + ", 原因: " + e.getMessage());
            }
        }

        // Session固定攻击防护：销毁旧Session，创建新Session
        HttpSession oldSession = req.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession newSession = req.getSession(true);
        newSession.setAttribute("currentUser", employee);
        // 新Session生成CSRF Token
        CsrfUtil.refreshToken(req);

        // 设置Session过期时间（30分钟无操作后过期）
        newSession.setMaxInactiveInterval(30 * 60);

        // 根据角色跳转
        String role = employee.getRole();
        String redirectUrl;
        if ("ADMIN".equals(role)) {
            redirectUrl = req.getContextPath() + "/admin?action=dashboard";
        } else if ("MANAGER".equals(role)) {
            redirectUrl = req.getContextPath() + "/mgr?action=dashboard";
        } else {
            redirectUrl = req.getContextPath() + "/employee?action=dashboard";
        }

        System.out.println("[登录] 成功 - 工号: " + empNo + ", 角色: " + role + ", IP: " + clientIp);
        resp.sendRedirect(redirectUrl);
    }

    /**
     * 登录失败处理
     */
    private void onLoginFailure(HttpServletRequest req, HttpServletResponse resp,
                                 String clientIp, String empNo)
            throws ServletException, IOException {
        // 记录失败
        LoginGuardUtil.recordFailure(clientIp, empNo);

        System.out.println("[登录] 失败 - 工号: " + empNo + ", IP: " + clientIp);

        req.setAttribute("errorMsg", "工号或密码错误");
        req.setAttribute("empNo", empNo);
        req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
    }
}
