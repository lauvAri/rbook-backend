package com.csu.r_book.modules.user.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.LocalDateTime;

/**
 * 用户信息实体
 */
@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "cr_users")
public class UserEntity {
    
    /**
     * 密码加密器（静态共享实例）
     */
    private static final BCryptPasswordEncoder PASSWORD_ENCODER = new BCryptPasswordEncoder();

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(name = "user_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private UserType userType = UserType.WORKER;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    /**
     * 设置明文密码（自动加密）
     * 开发时应优先使用此方法，避免忘记加密
     * 
     * @param rawPassword 明文密码
     */
    public void setRawPassword(String rawPassword) {
        this.password = PASSWORD_ENCODER.encode(rawPassword);
    }
    
    /**
     * 验证密码是否匹配
     * 
     * @param rawPassword 明文密码
     * @return 是否匹配
     */
    public boolean matchPassword(String rawPassword) {
        return PASSWORD_ENCODER.matches(rawPassword, this.password);
    }

    /**
     * 用户类型枚举
     */
    public enum UserType {
        ADMIN,  // 管理员
        WORKER  // 工人
    }
}
