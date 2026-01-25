package com.csu.r_book.modules.user.controller;

import com.csu.r_book.common.Result;
import com.csu.r_book.modules.user.model.dto.*;
import com.csu.r_book.modules.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户管理控制器
 */
@RestController
@RequestMapping("/api/user")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<UserDTO> login(@RequestBody LoginRequestDTO request) {
        UserDTO user = userService.login(request);
        return Result.success(user);
    }
    
    /**
     * 用户登出
     */
    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader(value = "Authorization", required = false) String token) {
        userService.logout(token);
        return Result.success(null);
    }
    
    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<UserDTO> register(@RequestBody UserCreateDTO request) {
        UserDTO user = userService.register(request);
        return Result.success(user);
    }
    
    /**
     * 批量导入用户
     */
    @PostMapping("/batch-import")
    public Result<BatchImportResultDTO> batchImport(@RequestBody BatchImportRequestDTO request) {
        BatchImportResultDTO result = userService.batchImport(request);
        return Result.success(result);
    }
    

    /**
     * 重置用户密码（管理员）
     */
    @PutMapping("/{id}/reset-password")
    public Result<ResetPasswordResultDTO> resetPassword(@PathVariable Long id) {
        ResetPasswordResultDTO result = userService.resetPassword(id);
        return Result.success(result);
    }

    /**
     * 用户本人修改密码
     */
    @PutMapping("/{id}/change-password")
    public Result<Void> changePassword(@PathVariable Long id,
                                      @RequestBody com.csu.r_book.modules.user.model.dto.ChangePasswordDTO dto,
                                      @RequestHeader(value = "Authorization", required = false) String token) {
        // 只允许本人操作
        Long currentUserId = getCurrentUserId(token);
        if (currentUserId == null || !currentUserId.equals(id)) {
            return Result.error(403, "只能修改自己的密码");
        }
        userService.changePassword(id, dto.getOldPassword(), dto.getNewPassword());
        return Result.success();
    }

    private Long getCurrentUserId(String token) {
        if (token == null) return null;
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        return com.csu.r_book.config.AuthInterceptor.getUserId(token);
    }
    
    /**
     * 获取用户列表
     */
    @GetMapping("/list")
    public Result<List<UserDTO>> getUserList() {
        List<UserDTO> users = userService.getAllUsers();
        return Result.success(users);
    }
    
    /**
     * 获取单个用户信息
     */
    @GetMapping("/{id}")
    public Result<UserDTO> getUser(@PathVariable Long id) {
        UserDTO user = userService.getUserById(id);
        return Result.success(user);
    }
    
    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return Result.success(null);
    }
    
    /**
     * 获取用户操作日志
     */
    @GetMapping("/{userId}/logs")
    public Result<List<UserLogDTO>> getUserLogs(@PathVariable Long userId) {
        List<UserLogDTO> logs = userService.getUserLogs(userId);
        return Result.success(logs);
    }
    
    /**
     * 获取所有操作日志（分页）
     */
    @GetMapping("/logs")
    public Result<Page<UserLogDTO>> getAllLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<UserLogDTO> logs = userService.getAllLogs(PageRequest.of(page, size));
        return Result.success(logs);
    }
}
