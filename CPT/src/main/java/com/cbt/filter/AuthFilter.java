package com.cbt.filter;

import com.cbt.model.User;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Set;

@WebFilter("/*")
public class AuthFilter implements Filter {
    private static final Set<String> PUBLIC_PATHS = Set.of(
            "/login",
            "/logout",
            "/resources/",
            "/css/",
            "/js/"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        if (user == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        } else {
            if (path.startsWith("/admin") && !"ADMIN".equalsIgnoreCase(user.getRole())) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}

    private boolean isPublic(String path) {
        return PUBLIC_PATHS.stream().anyMatch(path::startsWith) || path.endsWith(".css") || path.endsWith(".js");
    }
}
