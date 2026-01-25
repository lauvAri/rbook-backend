package com.csu.r_book.modules.user.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 批量导入用户响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BatchImportResultDTO {
    
    /**
     * 总数
     */
    private int total;
    
    /**
     * 成功数量
     */
    private int successCount;
    
    /**
     * 失败数量
     */
    private int failedCount;
    
    /**
     * 详细结果列表
     */
    private List<ImportResult> results;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ImportResult {
        /**
         * 用户名
         */
        private String username;
        
        /**
         * 是否成功
         */
        private boolean success;
        
        /**
         * 用户ID（成功时返回）
         */
        private Long userId;
        
        /**
         * 密码（成功时返回）
         */
        private String password;
        
        /**
         * 错误信息（失败时返回）
         */
        private String message;
    }
}
