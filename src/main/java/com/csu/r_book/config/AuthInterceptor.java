package com.csu.r_book.config;

import com.csu.r_book.modules.user.model.entity.UserEntity;
import com.csu.r_book.modules.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.io.IOException;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 权限校验拦截器
 */
@Slf4j
@Component
public class AuthInterceptor implements HandlerInterceptor {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    /**
     * Token 缓存：token -> userId
     * 注意：这个缓存需要和 UserServiceImpl 共享
     */
    private static final Map<String, Long> tokenCache = new ConcurrentHashMap<>();
    
    /**
     * 存储 Token
     */
    public static void storeToken(String token, Long userId) {
        tokenCache.put(token, userId);
    }
    
    /**
     * 移除 Token
     */
    public static void removeToken(String token) {
        if (token != null) {
            tokenCache.remove(token);
        }
    }
    
    /**
     * 获取用户ID
     */
    public static Long getUserId(String token) {
        return token != null ? tokenCache.get(token) : null;
    }
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String uri = request.getRequestURI();
        String method = request.getMethod();
        
        // OPTIONS 请求直接放行（CORS 预检）
        if ("OPTIONS".equalsIgnoreCase(method)) {
            return true;
        }
        
        // 获取 Token
        String token = extractToken(request);
        
        // 判断是否需要管理员权限
        if (isAdminRequired(uri, method)) {
            return checkAdminPermission(token, response);
        }
        
        // 判断是否需要登录
        if (isLoginRequired(uri, method)) {
            return checkLoginPermission(token, response);
        }
        
        // 公开接口，直接放行
        return true;
    }
    
    /**
     * 从请求中提取 Token
     */
    private String extractToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && !authHeader.isEmpty()) {
            // 支持 "Bearer xxx" 和 直接 "xxx" 两种格式
            if (authHeader.startsWith("Bearer ")) {
                return authHeader.substring(7);
            }
            return authHeader;
        }
        return null;
    }
    
    /**
     * 判断是否需要管理员权限
     */
    private boolean isAdminRequired(String uri, String method) {
        // 用户管理接口（除了登录、登出）
        if (uri.startsWith("/api/user/")) {
            // 登录、登出不需要管理员权限
            if (uri.equals("/api/user/login") || uri.equals("/api/user/logout")) {
                return false;
            }
            return true;
        }
        
        // 脚本管理接口
        if (uri.startsWith("/api/code-runner/admin/")) {
            return true;
        }
        
        return false;
    }
    
    /**
     * 判断是否需要登录
     */
    private boolean isLoginRequired(String uri, String method) {
        // 登出接口需要登录
        if (uri.equals("/api/user/logout")) {
            return true;
        }
        
        // 其他接口不需要登录（验证码、登录、脚本查询和执行）
        return false;
    }
    
    /**
     * 检查登录权限
     */
    private boolean checkLoginPermission(String token, HttpServletResponse response) throws IOException {
        if (token == null || !tokenCache.containsKey(token)) {
            sendError(response, 401, "未登录或登录已过期");
            return false;
        }
        return true;
    }
    
    /**
     * 检查管理员权限
     */
    private boolean checkAdminPermission(String token, HttpServletResponse response) throws IOException {
        // 先检查登录
        if (token == null || !tokenCache.containsKey(token)) {
            sendError(response, 401, "未登录或登录已过期");
            return false;
        }
        
        // 检查用户类型
        Long userId = tokenCache.get(token);
        Optional<UserEntity> userOpt = userRepository.findById(userId);
        
        if (userOpt.isEmpty()) {
            sendError(response, 401, "用户不存在");
            return false;
        }
        
        UserEntity user = userOpt.get();
        if (user.getUserType() != UserEntity.UserType.ADMIN) {
            sendError(response, 403, "无权限访问该资源");
            return false;
        }
        
        return true;
    }
    
    /**
     * 发送错误响应
     */
    private void sendError(HttpServletResponse response, int code, String message) throws IOException {
        response.setStatus(code == 401 ? 401 : (code == 403 ? 403 : 500));
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("code", code);
        result.put("message", message);
        result.put("data", null);
        response.getWriter().write(objectMapper.writeValueAsString(result));
    }
}
