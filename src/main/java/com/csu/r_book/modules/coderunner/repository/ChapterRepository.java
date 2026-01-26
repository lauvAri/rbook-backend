package com.csu.r_book.modules.coderunner.repository;

import com.csu.r_book.modules.coderunner.model.entity.ChapterEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 章节 Repository
 */
@Repository
public interface ChapterRepository extends JpaRepository<ChapterEntity, Long> {

    List<ChapterEntity> findByIsDeletedOrderBySortOrderAscIdAsc(Integer isDeleted);

    Optional<ChapterEntity> findByIdAndIsDeleted(Long id, Integer isDeleted);

    Optional<ChapterEntity> findByName(String name);

    Optional<ChapterEntity> findByNameAndIsDeleted(String name, Integer isDeleted);
}
