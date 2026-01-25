package com.csu.r_book.modules.user.repository;

import com.csu.r_book.modules.user.model.entity.UserLogEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 用户日志 Repository
 */
@Repository
public interface UserLogRepository extends JpaRepository<UserLogEntity, Long> {
    
    /**
     * 根据用户ID查询日志
     */
    List<UserLogEntity> findByUserIdOrderByCreatedAtDesc(Long userId);
    
    /**
     * 根据脚本ID查询日志
     */
    List<UserLogEntity> findByScriptIdOrderByCreatedAtDesc(String scriptId);
    
    /**
     * 分页查询所有日志
     */
    Page<UserLogEntity> findAllByOrderByCreatedAtDesc(Pageable pageable);
    
    /**
     * 根据用户ID分页查询
     */
    Page<UserLogEntity> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
}
