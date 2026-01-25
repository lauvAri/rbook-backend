package com.csu.r_book.config;

import com.csu.r_book.modules.user.model.entity.UserEntity;
import com.csu.r_book.modules.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 数据初始化器
 * 在应用启动时检查并创建默认数据
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {
    
    private final UserRepository userRepository;
    
    /**
     * 默认管理员用户名
     */
    private static final String DEFAULT_ADMIN_USERNAME = "admin";
    
    /**
     * 默认管理员密码
     */
    private static final String DEFAULT_ADMIN_PASSWORD = "admin123";
    
    @Override
    public void run(ApplicationArguments args) {
        initDefaultAdmin();
    }
    
    /**
     * 初始化默认管理员账户
     */
    private void initDefaultAdmin() {
        if (userRepository.existsByUsername(DEFAULT_ADMIN_USERNAME)) {
            log.info("默认管理员账户已存在，跳过初始化");
            return;
        }
        
        log.info("创建默认管理员账户: {}", DEFAULT_ADMIN_USERNAME);
        
        UserEntity admin = new UserEntity();
        admin.setUsername(DEFAULT_ADMIN_USERNAME);
        admin.setRawPassword(DEFAULT_ADMIN_PASSWORD);  // 自动加密
        admin.setUserType(UserEntity.UserType.ADMIN);
        
        userRepository.save(admin);
        
        log.info("默认管理员账户创建成功，用户名: {}，密码: {}", DEFAULT_ADMIN_USERNAME, DEFAULT_ADMIN_PASSWORD);
    }
}
