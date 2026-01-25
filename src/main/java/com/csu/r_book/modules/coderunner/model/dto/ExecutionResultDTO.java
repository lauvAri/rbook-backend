package com.csu.r_book.modules.coderunner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 执行结果响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExecutionResultDTO {

    /**
     * 执行是否成功
     */
    private Boolean success;

    /**
     * 输出内容列表
     */
    private List<OutputItem> outputs;

    /**
     * 执行耗时 (毫秒)
     */
    private Long executionTime;

    /**
     * 错误信息，仅在 success=false 时有值
     */
    private String error;

    /**
     * 输出项
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OutputItem {
        /**
         * 输出类型: "text" 或 "image"
         */
        private String type;

        /**
         * type="text" 时使用，文本内容
         */
        private String content;

        /**
         * type="image" 时使用，Base64 字符串
         */
        private String data;

        /**
         * 图片格式: "png", "jpeg"
         */
        private String format;

        /**
         * 图片标题
         */
        private String caption;
    }
}
