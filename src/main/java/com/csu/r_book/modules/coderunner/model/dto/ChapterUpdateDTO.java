package com.csu.r_book.modules.coderunner.model.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 更新章节请求 DTO
 */
@Data
public class ChapterUpdateDTO {

    @Size(max = 100, message = "章节名称长度不能超过100")
    private String name;

    private Integer sortOrder;
}
