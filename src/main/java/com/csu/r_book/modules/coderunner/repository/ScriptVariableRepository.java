package com.csu.r_book.modules.coderunner.repository;

import com.csu.r_book.modules.coderunner.model.entity.ScriptVariableEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 脚本变量 Repository
 */
@Repository
public interface ScriptVariableRepository extends JpaRepository<ScriptVariableEntity, Long> {

    /**
     * 根据脚本ID查询变量列表
     */
    List<ScriptVariableEntity> findByScriptIdOrderBySortOrderAsc(String scriptId);
}
