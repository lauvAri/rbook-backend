package com.csu.r_book.modules.coderunner.model.dto;

import lombok.Data;

import java.util.Map;

/**
 * 执行脚本请求 DTO
 */
@Data
public class ExecuteRequestDTO {

    /**
     * 脚本ID
     */
    private String scriptId;

    /**
     * 变量参数，使用 Map 接收动态参数
     */
    private Map<String, Object> variables;

    /**
     * CSV 内容字符串或文件数据
     */
    private String fileData;

    /**
     * 是否为直接文本输入
     */
    private Boolean isRawInput;
}
