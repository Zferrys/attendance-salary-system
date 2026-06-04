package com.attendance.filter;

import com.attendance.entity.Employee;
import com.google.gson.Gson;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * 权限认证过滤器（AuthFilter）
 *
 * 用途: 拦截所有需要登录才能访问的请求，检查用户是否已登录。
 *       根据用户角色（员工/主管/管理员）控制不同页面的访问权限。
 *
 * 过滤规则:
 *   1. 登录页面 → 放行（无需登录）
 *   2. /employee/* → 需要普通员工或管理员登录
 *   3. /mgr/*       → 需要主管(M开头工号)或管理员(A开头工号)登录
 *   4. /admin/*    → 需要管理员(A开头工号)登录
 *
 * AJAX请求特殊处理:
 *   - 未登录时返回 JSON {url: "login.jsp"} 而非重定向页面
 */
@WebFilter(filterName = "authFilter",
           urlPatterns = {"/employee", "/mgr", "/admin"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 过滤器初始化（可在此读取配置参数）
        System.out.println("[AuthFilter] 权限认证过滤器已初始化");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession();
        
        String url = req.getServletPath(); // 如 /employee, /mgr, /admin

        // 获取当前登录用户
        Employee user = (Employee) session.getAttribute("currentUser");

        if (user == null) {
            // 未登录处理
            handleNotLoggedIn(req, resp);
            return;
        }

        // 根据请求路径进行权限校验
        String empNo = user.getEmpNo();

        if (url.startsWith("/admin")) {
            // 管理员页面：只有A开头的工号可访问
            if (!empNo.startsWith("A")) {
                req.setAttribute("errorMsg", "您没有管理后台访问权限！");
                req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
                return;
            }
        } else if (url.startsWith("/mgr")) {
            // 主管页面：M开头或A开头可访问
            if (!empNo.startsWith("M") && !empNo.startsWith("A")) {
                req.setAttribute("errorMsg", "您没有主管面板访问权限！");
                req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
                return;
            }
        }
        // /employee 路径：所有已登录用户均可访问

        // 权限通过，放行请求到目标Servlet
        chain.doFilter(request, response);
    }

    /**
     * 处理未登录情况
     * - 普通请求：重定向到登录页
     * - AJAX请求：返回JSON响应（前端据此跳转）
     */
    private void handleNotLoggedIn(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
        
        if (isAjax) {
            // AJAX请求返回JSON
            Map<String, String> result = new HashMap<>();
            result.put("url", req.getContextPath() + "/views/common/login.jsp");
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(new Gson().toJson(result));
        } else {
            // 普通请求重定向到登录页
            resp.sendRedirect(req.getContextPath() + "/views/common/login.jsp");
        }
    }

    @Override
    public void destroy() {
        System.out.println("[AuthFilter] 权限认证过滤器已销毁");
    }
}
