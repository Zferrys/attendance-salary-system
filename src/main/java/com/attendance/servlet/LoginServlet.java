package com.attendance.servlet;

import com.attendance.entity.Employee;
import com.attendance.service.EmployeeService;
import com.attendance.service.impl.EmployeeServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

/**
 * 登录Servlet
 *
 * 用途: 处理员工/管理员登录请求，验证身份后跳转到对应页面。
 *
 * 请求映射: /login
 * 参数:
 *   - action=login: 执行登录操作（参数: name=姓名, password=密码）
 *   - action=logout: 执行登出操作
 *
 * 角色判断逻辑:
 *   - 工号以 "A" 开头 → 管理员 → 跳转管理后台
 *   - 工号以 "M" 开头 → 主管 → 跳转主管面板
 *   - 其他工号     → 普通员工 → 跳转员工首页
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private EmployeeService employeeService = new EmployeeServiceImpl();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("logout".equals(action)) {
            // 清除会话并重定向到登录页
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/views/common/login.jsp");
            return;
        }
        
        if ("login".equals(action) || action == null) {
            doLogin(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/views/common/login.jsp");
        }
    }

    /**
     * 处理登录请求
     */
    private void doLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name = req.getParameter("name");
        String password = req.getParameter("password");

        // 基础参数校验
        if (name == null || name.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            req.setAttribute("errorMsg", "请输入姓名和密码！");
            req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
            return;
        }

        // 调用Service层进行登录验证（按姓名查询）
        Employee employee = employeeService.login(name.trim(), password.trim());

        if (employee != null) {
            // 登录成功：将用户信息存入Session
            HttpSession session = req.getSession();
            session.setAttribute("currentUser", employee);

            // 根据工号前缀判断角色并跳转到对应页面
            if (employee.getEmpNo().startsWith("A")) {
                // 管理员 → 管理后台首页
                resp.sendRedirect(req.getContextPath() + "/admin?action=dashboard");
            } else if (employee.getEmpNo().startsWith("M")) {
                // 主管 → 主管面板首页
                resp.sendRedirect(req.getContextPath() + "/manager?action=dashboard");
            } else {
                // 普通员工 → 员工首页
                resp.sendRedirect(req.getContextPath() + "/employee?action=dashboard");
            }
        } else {
            // 登录失败：返回错误信息到登录页
            req.setAttribute("errorMsg", "姓名或密码错误！");
            req.setAttribute("name", name); // 回显姓名
            req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
        }
    }
}
