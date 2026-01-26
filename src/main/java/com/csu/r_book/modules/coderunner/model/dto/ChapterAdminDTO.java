package com.csu.r_book.modules.coderunner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 章节管理 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChapterAdminDTO {

    private Long id;

    private String name;

    private Integer sortOrder;

    private long scriptCount;
}
