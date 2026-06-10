package com.attendance.filter;

import com.attendance.entity.Employee;
import com.attendance.utils.CsrfUtil;
import com.google.gson.Gson;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;

/**
 * 权限认证过滤器 (AuthFilter)
 *
 * 拦截所有请求，检查登录状态和角色权限。
 * 
 * 过滤规则:
 *   1. 静态资源和登录页面 → 放行
 *   2. /admin/* → 需要 ADMIN 角色
 *   3. /mgr/*   → 需要 MANAGER 或 ADMIN 角色
 *   4. /employee/* → 所有已登录用户
 *   5. POST请求 → 需要CSRF Token校验
 *   6. 未登录 → 重定向到登录页
 */
@WebFilter(filterName = "authFilter", urlPatterns = "/*")
public class AuthFilter implements Filter {

    /** 无需认证即可访问的路径 */
    private static final Set<String> PUBLIC_PATHS = new HashSet<>(Arrays.asList(
        "/login",
        "/views/common/landing.jsp",
        "/views/common/login.jsp",
        "/views/miniapp/login.jsp",
        "/views/common/error_403.jsp",
        "/views/common/error_404.jsp",
        "/views/common/error_500.jsp"
    ));

    /** 静态资源路径前缀 */
    private static final String[] STATIC_PREFIXES = {
        "/assets/", "/favicon.ico"
    };

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("[AuthFilter] 权限认证过滤器已初始化 - 安全增强版");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        String method = req.getMethod();

        // 1. 放行静态资源
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. 放行公开路径
        if (PUBLIC_PATHS.contains(path) || path.startsWith("/miniapp")) {
            chain.doFilter(request, response);
            return;
        }

        // 3. 登录接口特殊处理：不做登录检查但需CSRF校验
        if ("/login".equals(path) && "POST".equalsIgnoreCase(method)) {
            if (!CsrfUtil.validate(req)) {
                handleCsrfFailure(req, resp);
                return;
            }
            chain.doFilter(request, response);
            return;
        }

        // 4. 检查登录状态
        HttpSession session = req.getSession(false);
        Employee user = (session != null) ? (Employee) session.getAttribute("currentUser") : null;

        if (user == null) {
            handleNotLoggedIn(req, resp);
            return;
        }

        // 5. 角色权限校验
        String role = user.getRole();
        if (path.startsWith("/admin")) {
            if (!"ADMIN".equals(role)) {
                req.setAttribute("errorMsg", "您没有管理后台访问权限");
                req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
                return;
            }
        } else if (path.startsWith("/mgr")) {
            if (!"MANAGER".equals(role) && !"ADMIN".equals(role)) {
                req.setAttribute("errorMsg", "您没有主管面板访问权限");
                req.getRequestDispatcher("/views/common/login.jsp").forward(req, resp);
                return;
            }
        }

        // 6. 非GET请求的CSRF校验（登录接口已在上面处理）
        if (!"GET".equalsIgnoreCase(method)
                && !"HEAD".equalsIgnoreCase(method)
                && !"OPTIONS".equalsIgnoreCase(method)) {
            if (!CsrfUtil.validate(req)) {
                handleCsrfFailure(req, resp);
                return;
            }
        }

        // 7. 为JSP页面设置安全响应头
        setSecurityHeaders(resp);

        chain.doFilter(request, response);
    }

    private boolean isStaticResource(String path) {
        for (String prefix : STATIC_PREFIXES) {
            if (path.startsWith(prefix)) return true;
        }
        return false;
    }

    private void setSecurityHeaders(HttpServletResponse resp) {
        resp.setHeader("X-Content-Type-Options", "nosniff");
        resp.setHeader("X-Frame-Options", "DENY");
        resp.setHeader("X-XSS-Protection", "1; mode=block");
        resp.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
    }

    private void handleNotLoggedIn(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
        if (isAjax) {
            Map<String, String> result = new HashMap<>();
            result.put("url", req.getContextPath() + "/views/common/login.jsp");
            result.put("error", "session_expired");
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(new Gson().toJson(result));
        } else {
            resp.sendRedirect(req.getContextPath() + "/views/common/login.jsp");
        }
    }

    private void handleCsrfFailure(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
        if (isAjax) {
            Map<String, String> result = new HashMap<>();
            result.put("error", "csrf_invalid");
            result.put("message", "请求验证失败，请刷新页面后重试");
            resp.setContentType("application/json;charset=UTF-8");
            resp.setStatus(403);
            resp.getWriter().write(new Gson().toJson(result));
        } else {
            req.getSession().setAttribute("errorMsg", "请求验证失败，请刷新页面后重试");
            try {
                resp.sendRedirect(req.getContextPath() + "/views/common/login.jsp");
            } catch (IOException e) {
                resp.sendError(403, "CSRF验证失败");
            }
        }
    }

    @Override
    public void destroy() {
        System.out.println("[AuthFilter] 权限认证过滤器已销毁");
    }
}
