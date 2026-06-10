package com.attendance.utils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * CSRF 防护工具类
 *
 * 为每个用户会话生成唯一的CSRF Token，防止跨站请求伪造攻击。
 *
 * 使用方式:
 *   1. 在需要保护的表单中调用 CsrfUtil.getToken(request) 获取token
 *   2. 将token放入隐藏字段 <input type="hidden" name="_csrf" value="${csrfToken}">
 *   3. 在服务端调用 CsrfUtil.validate(request) 验证token
 *
 * 特殊处理:
 *   multipart/form-data 请求无法通过 request.getParameter() 获取表单字段，
 *   此时会从 URL 查询字符串和请求头中尝试获取 _csrf 参数。
 */
public class CsrfUtil {

    private static final String CSRF_SESSION_KEY = "CSRF_TOKEN";
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * 获取或生成当前会话的CSRF Token
     */
    public static String getToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String token = (String) session.getAttribute(CSRF_SESSION_KEY);
        if (token == null) {
            token = generateToken();
            session.setAttribute(CSRF_SESSION_KEY, token);
        }
        return token;
    }

    /**
     * 验证CSRF Token是否有效
     * 仅对POST/PUT/DELETE请求进行验证
     *
     * @param request HTTP请求
     * @return true表示token有效或无需验证(GET请求)
     */
    public static boolean validate(HttpServletRequest request) {
        String method = request.getMethod();
        // GET/HEAD/OPTIONS 请求不需要CSRF验证
        if ("GET".equalsIgnoreCase(method)
                || "HEAD".equalsIgnoreCase(method)
                || "OPTIONS".equalsIgnoreCase(method)) {
            return true;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        String sessionToken = (String) session.getAttribute(CSRF_SESSION_KEY);
        if (sessionToken == null) {
            return false;
        }

        // 1. 先从标准请求参数获取（对普通表单有效）
        String requestToken = request.getParameter("_csrf");

        // 2. multipart/form-data 请求无法通过 getParameter() 获取表单字段，
        //    此时尝试从 URL 查询字符串中提取 _csrf
        if (requestToken == null) {
            requestToken = extractFromQueryString(request.getQueryString());
        }

        // 3. 最后尝试从请求头获取（AJAX 请求）
        if (requestToken == null) {
            requestToken = request.getHeader("X-CSRF-TOKEN");
        }

        return sessionToken.equals(requestToken);
    }

    /**
     * 从查询字符串中提取指定参数值
     */
    private static String extractFromQueryString(String queryString) {
        if (queryString == null || queryString.isEmpty()) {
            return null;
        }
        for (String param : queryString.split("&")) {
            String[] kv = param.split("=", 2);
            if (kv.length == 2 && "_csrf".equals(kv[0])) {
                try {
                    return URLDecoder.decode(kv[1], StandardCharsets.UTF_8.name());
                } catch (Exception e) {
                    return kv[1];
                }
            }
        }
        return null;
    }

    /**
     * 生成新的CSRF Token（登录成功后调用）
     */
    public static String refreshToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String token = generateToken();
        session.setAttribute(CSRF_SESSION_KEY, token);
        return token;
    }

    private static String generateToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
