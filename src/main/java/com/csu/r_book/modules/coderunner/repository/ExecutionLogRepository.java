package com.csu.r_book.modules.coderunner.repository;

import com.csu.r_book.modules.coderunner.model.entity.ExecutionLogEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 执行日志 Repository
 */
@Repository
public interface ExecutionLogRepository extends JpaRepository<ExecutionLogEntity, Long> {

    /**
     * 根据脚本ID查询执行日志
     */
    List<ExecutionLogEntity> findByScriptIdOrderByCreatedAtDesc(String scriptId);
}
