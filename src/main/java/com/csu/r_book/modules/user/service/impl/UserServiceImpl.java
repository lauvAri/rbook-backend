package com.csu.r_book.modules.user.service.impl;

import com.csu.r_book.config.AuthInterceptor;
import com.csu.r_book.modules.captcha.service.CaptchaService;
import com.csu.r_book.modules.user.model.dto.*;
import com.csu.r_book.modules.user.model.entity.UserEntity;
import com.csu.r_book.modules.user.model.entity.UserLogEntity;
import com.csu.r_book.modules.user.repository.UserLogRepository;
import com.csu.r_book.modules.user.repository.UserRepository;
import com.csu.r_book.modules.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 用户服务实现类
 */
@Service
public class UserServiceImpl implements UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private UserLogRepository userLogRepository;
    
    @Autowired
    private CaptchaService captchaService;
    
    private final SecureRandom random = new SecureRandom();
    
    /**
     * 密码字符集
     */
    private static final String PASSWORD_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#$%";
    
    @Override
    public UserDTO login(LoginRequestDTO request) {
        // 验证验证码
        if (!captchaService.verifyCaptcha(request.getCaptchaKey(), request.getCaptchaCode())) {
            throw new RuntimeException("验证码错误或已过期");
        }
        
        UserEntity user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("用户名或密码错误"));
        
        if (!user.matchPassword(request.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }
        
        // 生成 Token 并存储到全局缓存
        String token = UUID.randomUUID().toString().replace("-", "");
        AuthInterceptor.storeToken(token, user.getId());
        
        UserDTO dto = UserDTO.fromEntity(user);
        dto.setToken(token);
        return dto;
    }
    
    @Override
    public void logout(String token) {
        AuthInterceptor.removeToken(token);
    }
    
    @Override
    @Transactional
    public UserDTO register(UserCreateDTO request) {
        // 检查用户名是否已存在
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        
        UserEntity user = new UserEntity();
        user.setUsername(request.getUsername());
        user.setRawPassword(request.getPassword());  // 自动加密
        user.setUserType(UserEntity.UserType.valueOf(request.getUserType().toUpperCase()));
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        UserEntity savedUser = userRepository.save(user);
        return UserDTO.fromEntity(savedUser);
    }
    
    @Override
    @Transactional
    public BatchImportResultDTO batchImport(BatchImportRequestDTO request) {
        List<BatchImportResultDTO.ImportResult> results = new ArrayList<>();
        int successCount = 0;
        int failedCount = 0;
        
        for (BatchImportRequestDTO.UserItem item : request.getUsers()) {
            try {
                // 检查用户名是否已存在
                if (userRepository.existsByUsername(item.getUsername())) {
                    results.add(BatchImportResultDTO.ImportResult.builder()
                            .username(item.getUsername())
                            .success(false)
                            .message("用户名已存在")
                            .build());
                    failedCount++;
                    continue;
                }
                
                // 生成或使用提供的密码
                String password = item.getPassword();
                if (password == null || password.isEmpty()) {
                    password = generateRandomPassword();
                }
                
                // 创建用户
                UserEntity user = new UserEntity();
                user.setUsername(item.getUsername());
                user.setRawPassword(password);  // 自动加密
                user.setUserType(UserEntity.UserType.WORKER);
                user.setCreatedAt(LocalDateTime.now());
                user.setUpdatedAt(LocalDateTime.now());
                
                UserEntity savedUser = userRepository.save(user);
                
                results.add(BatchImportResultDTO.ImportResult.builder()
                        .username(item.getUsername())
                        .success(true)
                        .userId(savedUser.getId())
                        .password(password)
                        .build());
                successCount++;
                
            } catch (Exception e) {
                results.add(BatchImportResultDTO.ImportResult.builder()
                        .username(item.getUsername())
                        .success(false)
                        .message(e.getMessage())
                        .build());
                failedCount++;
            }
        }
        
        return BatchImportResultDTO.builder()
                .total(request.getUsers().size())
                .successCount(successCount)
                .failedCount(failedCount)
                .results(results)
                .build();
    }
    
    @Override
    @Transactional
        public ResetPasswordResultDTO resetPassword(Long userId) {
        UserEntity user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        // 重置为固定密码 123456
        String newPassword = "123456";
        user.setRawPassword(newPassword);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
        return ResetPasswordResultDTO.builder()
            .userId(user.getId())
            .username(user.getUsername())
            .newPassword(newPassword)
            .build();
        }

        @Override
        @Transactional
        public void changePassword(Long userId, String oldPassword, String newPassword) {
        UserEntity user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        if (!user.matchPassword(oldPassword)) {
            throw new RuntimeException("原密码错误");
        }
        user.setRawPassword(newPassword);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
        }
    
    /**
     * 生成随机密码
     */
    private String generateRandomPassword() {
        StringBuilder sb = new StringBuilder(10);
        for (int i = 0; i < 10; i++) {
            sb.append(PASSWORD_CHARS.charAt(random.nextInt(PASSWORD_CHARS.length())));
        }
        return sb.toString();
    }
    
    @Override
    public List<UserDTO> getAllUsers() {
        return userRepository.findAll().stream()
                .map(UserDTO::fromEntity)
                .collect(Collectors.toList());
    }
    
    @Override
    public UserDTO getUserById(Long id) {
        UserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return UserDTO.fromEntity(user);
    }
    
    @Override
    @Transactional
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("用户不存在");
        }
        userRepository.deleteById(id);
    }
    
    @Override
    @Transactional
    public void logOperation(Long userId, String operationType, String scriptId) {
        UserLogEntity log = new UserLogEntity();
        log.setUserId(userId);
        log.setOperationType(UserLogEntity.OperationType.valueOf(operationType));
        log.setScriptId(scriptId);
        log.setCreatedAt(LocalDateTime.now());
        
        userLogRepository.save(log);
    }
    
    @Override
    public List<UserLogDTO> getUserLogs(Long userId) {
        return userLogRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(UserLogDTO::fromEntity)
                .collect(Collectors.toList());
    }
    
    @Override
    public Page<UserLogDTO> getAllLogs(Pageable pageable) {
        return userLogRepository.findAllByOrderByCreatedAtDesc(pageable)
                .map(UserLogDTO::fromEntity);
    }
}
