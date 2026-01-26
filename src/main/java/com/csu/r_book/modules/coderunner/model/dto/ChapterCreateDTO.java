package com.csu.r_book.modules.coderunner.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 创建章节请求 DTO
 */
@Data
public class ChapterCreateDTO {

    @NotBlank(message = "章节名称不能为空")
    @Size(max = 100, message = "章节名称长度不能超过100")
    private String name;

    private Integer sortOrder;
}
