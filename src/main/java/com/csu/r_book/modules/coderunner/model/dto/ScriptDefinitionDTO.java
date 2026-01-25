package com.csu.r_book.modules.coderunner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 脚本定义信息 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScriptDefinitionDTO {

    /**
     * 脚本ID
     */
    private String id;

    /**
     * 脚本名称
     */
    private String name;

    /**
     * 脚本描述
     */
    private String description;

    /**
     * 是否支持自定义参数
     */
    private Boolean supportsVariables;

    /**
     * 是否支持文件上传
     */
    private Boolean supportsFileInput;

    /**
     * 文件上传的提示文案
     */
    private String fileInputDesc;

    /**
     * CSV 示例数据，展示给用户参考期望的数据格式
     */
    private String exampleData;

    /**
     * 所属章节
     */
    private String chapter;

    /**
     * 排序顺序
     */
    private Integer sortOrder;

    /**
     * R 脚本代码内容
     */
    private String scriptContent;

    /**
     * 变量定义列表
     */
    private List<VariableDefinition> variables;

    /**
     * 变量定义
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VariableDefinition {
        /**
         * 变量名 (R变量名)
         */
        private String name;

        /**
         * 前端显示标签
         */
        private String label;

        /**
         * 变量类型: NUMBER, STRING, BOOLEAN
         */
        private String type;

        /**
         * 默认值
         */
        private String defaultValue;

        /**
         * 变量说明
         */
        private String description;
    }
}
