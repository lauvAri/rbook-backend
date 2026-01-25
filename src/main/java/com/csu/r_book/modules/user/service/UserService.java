package com.csu.r_book.modules.user.service;

import com.csu.r_book.modules.user.model.dto.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

/**
 * 用户服务接口
 */
public interface UserService {
    
    /**
     * 用户登录（带验证码）
     * @param request 登录请求
     * @return 用户信息（含Token）
     */
    UserDTO login(LoginRequestDTO request);
    
    /**
     * 用户登出
     * @param token 用户令牌
     */
    void logout(String token);
    
    /**
     * 用户注册
     * @param request 注册请求
     * @return 用户信息
     */
    UserDTO register(UserCreateDTO request);
    
    /**
     * 批量导入用户
     * @param request 批量导入请求
     * @return 导入结果
     */
    BatchImportResultDTO batchImport(BatchImportRequestDTO request);
    
    /**
     * 重置用户密码
     * @param userId 用户ID
     * @return 重置结果（含新密码）
     */
    ResetPasswordResultDTO resetPassword(Long userId);
    
        /**
         * 用户本人修改密码
         * @param userId 用户ID
         * @param oldPassword 旧密码
         * @param newPassword 新密码
         */
        void changePassword(Long userId, String oldPassword, String newPassword);
    
    /**
     * 获取用户列表
     * @return 用户列表
     */
    List<UserDTO> getAllUsers();
    
    /**
     * 根据ID获取用户
     * @param id 用户ID
     * @return 用户信息
     */
    UserDTO getUserById(Long id);
    
    /**
     * 删除用户
     * @param id 用户ID
     */
    void deleteUser(Long id);
    
    /**
     * 记录用户操作日志
     * @param userId 用户ID
     * @param operationType 操作类型
     * @param scriptId 脚本ID
     */
    void logOperation(Long userId, String operationType, String scriptId);
    
    /**
     * 获取用户日志
     * @param userId 用户ID
     * @return 日志列表
     */
    List<UserLogDTO> getUserLogs(Long userId);
    
    /**
     * 分页获取所有日志
     * @param pageable 分页参数
     * @return 日志分页
     */
    Page<UserLogDTO> getAllLogs(Pageable pageable);
}
