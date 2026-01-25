package com.csu.r_book.modules.coderunner.repository;

import com.csu.r_book.modules.coderunner.model.entity.RScriptEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * R脚本 Repository
 */
@Repository
public interface RScriptRepository extends JpaRepository<RScriptEntity, String> {

    /**
     * 查询所有未删除的脚本
     */
    List<RScriptEntity> findAllByIsDeleted(Integer isDeleted);
    
    /**
     * 根据章节查询脚本（按排序顺序）
     */
    List<RScriptEntity> findByChapterOrderBySortOrderAsc(String chapter);
    
    /**
     * 获取所有不同的章节名称
     */
    @Query("SELECT DISTINCT e.chapter FROM RScriptEntity e WHERE e.chapter IS NOT NULL ORDER BY e.chapter")
    List<String> findDistinctChapters();
    
    /**
     * 统计指定章节的脚本数量
     */
    long countByChapter(String chapter);
}
