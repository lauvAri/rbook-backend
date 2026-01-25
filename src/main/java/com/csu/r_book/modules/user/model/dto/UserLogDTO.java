package com.csu.r_book.modules.user.model.dto;

import com.csu.r_book.modules.user.model.entity.UserLogEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 用户操作日志 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserLogDTO {
    
    /**
     * 日志ID
     */
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 用户名
     */
    private String username;
    
    /**
     * 操作类型
     */
    private String operationType;
    
    /**
     * 操作类型描述
     */
    private String operationDesc;
    
    /**
     * 脚本ID
     */
    private String scriptId;
    
    /**
     * 操作时间
     */
    private LocalDateTime createdAt;

    /**
     * 从实体转换为 DTO
     */
    public static UserLogDTO fromEntity(UserLogEntity entity) {
        String operationDesc = switch (entity.getOperationType()) {
            case CREATE_SCRIPT -> "新增题目";
            case UPDATE_SCRIPT -> "修改题目";
            case DELETE_SCRIPT -> "删除题目";
        };
        
        return UserLogDTO.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .operationType(entity.getOperationType().name())
                .operationDesc(operationDesc)
                .scriptId(entity.getScriptId())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
