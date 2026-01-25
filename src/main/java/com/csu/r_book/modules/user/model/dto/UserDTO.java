package com.csu.r_book.modules.user.model.dto;

import com.csu.r_book.modules.user.model.entity.UserEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 用户信息 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    
    /**
     * 用户ID
     */
    private Long id;
    
    /**
     * 用户名
     */
    private String username;
    
    /**
     * 用户类型
     */
    private String userType;
    
    /**
     * 注册时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
    
    /**
     * 登录令牌（仅登录时返回）
     */
    private String token;

    /**
     * 从实体转换为 DTO
     */
    public static UserDTO fromEntity(UserEntity entity) {
        return UserDTO.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .userType(entity.getUserType().name())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}
