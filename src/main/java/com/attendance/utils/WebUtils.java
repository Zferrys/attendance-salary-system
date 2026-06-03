package com.attendance.utils;

import javax.servlet.http.HttpServletRequest;
import java.util.Enumeration;

/**
 * Web 工具类
 *
 * 用途: 提供Web开发中常用的工具方法，包括：
 *       - 参数获取与类型转换（避免大量重复的getParameter代码）
 *       - AJAX请求判断
 *       - 通用响应处理
 */
public class WebUtils {

    /**
     * 从请求中获取整型参数，带默认值
     *
     * @param request HTTP请求对象
     * @param name    参数名
     * @param defaultValue 默认值（参数为空或不存在时返回）
     * @return 整型参数值
     */
    public static int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String value = request.getParameter(name);
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * 从请求中获取字符串参数
     *
     * @param request HTTP请求对象
     * @param name    参数名
     * @return 字符串参数值，不存在则返回null
     */
    public static String getStrParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value != null) {
            value = value.trim();
        }
        return (value != null && !value.isEmpty()) ? value : null;
    }

    /**
     * 判断是否为AJAX请求
     * 通过检查请求头 "X-Requested-With" 是否为 "XMLHttpRequest"
     *
     * @param request HTTP请求对象
     * @return true表示是AJAX请求，false表示普通页面请求
     */
    public static boolean isAjaxRequest(HttpServletRequest request) {
        String header = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equals(header);
    }
}
