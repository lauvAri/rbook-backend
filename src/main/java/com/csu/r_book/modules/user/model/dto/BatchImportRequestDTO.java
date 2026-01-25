package com.csu.r_book.modules.user.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 批量导入用户请求 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BatchImportRequestDTO {
    
    /**
     * 用户列表
     */
    private List<UserItem> users;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserItem {
        /**
         * 用户名
         */
        private String username;
        
        /**
         * 密码（不传则系统自动生成）
         */
        private String password;
    }
}
