package com.attendance.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;

/**
 * 字符编码过滤器
 * 统一设置请求和响应的 UTF-8 编码，解决中文乱码问题
 */
@WebFilter("/*")
public class EncodingFilter implements Filter {

    private String encoding = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String cfgEncoding = filterConfig.getInitParameter("encoding");
        if (cfgEncoding != null && !cfgEncoding.isEmpty()) {
            this.encoding = cfgEncoding;
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding(encoding);
        response.setCharacterEncoding(encoding);
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // 无需清理
    }
}
