package com.csu.r_book.modules.coderunner.model.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

/**
 * 更新脚本请求 DTO
 */
@Data
public class ScriptUpdateDTO {

    /**
     * 脚本名称
     */
    @NotBlank(message = "脚本名称不能为空")
    @Size(max = 100, message = "脚本名称长度不能超过100")
    private String name;

    /**
     * 脚本描述
     */
    @Size(max = 500, message = "脚本描述长度不能超过500")
    private String description;

    /**
     * R脚本代码内容 (可选，不传则不更新脚本文件)
     */
    private String scriptContent;

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
    @Size(max = 255, message = "文件输入说明长度不能超过255")
    private String fileInputDesc;

    /**
     * CSV 示例数据
     */
    private String exampleData;

    /**
     * 所属章节
     */
    @Size(max = 100, message = "章节名称长度不能超过100")
    private String chapter;

    /**
     * 排序顺序
     */
    private Integer sortOrder;

    /**
     * 变量定义列表 (传入则全量替换)
     */
    @Valid
    private List<VariableUpdateDTO> variables;

    /**
     * 变量定义
     */
    @Data
    public static class VariableUpdateDTO {

        /**
         * 变量名 (R变量名)
         */
        @NotBlank(message = "变量名不能为空")
        @Size(max = 50, message = "变量名长度不能超过50")
        @Pattern(regexp = "^[a-zA-Z_][a-zA-Z0-9_]*$", message = "变量名只能包含字母、数字和下划线，且不能以数字开头")
        private String name;

        /**
         * 前端显示标签
         */
        @NotBlank(message = "显示标签不能为空")
        @Size(max = 50, message = "显示标签长度不能超过50")
        private String label;

        /**
         * 变量类型: NUMBER, STRING, BOOLEAN
         */
        @NotBlank(message = "变量类型不能为空")
        @Pattern(regexp = "^(NUMBER|STRING|BOOLEAN)$", message = "变量类型只能是 NUMBER、STRING 或 BOOLEAN")
        private String type;

        /**
         * 默认值
         */
        @Size(max = 100, message = "默认值长度不能超过100")
        private String defaultValue;

        /**
         * 变量说明
         */
        @Size(max = 200, message = "变量说明长度不能超过200")
        private String description;

        /**
         * 排序权重
         */
        private Integer sortOrder = 0;
    }
}
