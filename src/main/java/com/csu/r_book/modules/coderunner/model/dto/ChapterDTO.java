package com.csu.r_book.modules.coderunner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 章节信息 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChapterDTO {
    
    /**
     * 章节名称
     */
    private String name;
    
    /**
     * 该章节下的脚本数量
     */
    private long scriptCount;
}
