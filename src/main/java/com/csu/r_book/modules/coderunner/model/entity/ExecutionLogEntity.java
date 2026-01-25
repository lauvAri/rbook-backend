package com.csu.r_book.modules.coderunner.model.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 脚本执行日志实体
 */
@Data
@Entity
@Table(name = "cr_execution_logs")
public class ExecutionLogEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 关联脚本ID
     */
    @Column(name = "script_id", length = 64, nullable = false)
    private String scriptId;

    /**
     * 请求参数 (JSON格式)
     */
    @Column(name = "request_params", columnDefinition = "TEXT")
    private String requestParams;

    /**
     * 执行状态 (1:成功, 0:失败)
     */
    @Column(name = "is_success", nullable = false)
    private Boolean isSuccess;

    /**
     * 错误信息
     */
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    /**
     * 执行耗时 (毫秒)
     */
    @Column(name = "execution_time_ms")
    private Long executionTimeMs;

    /**
     * 执行时间
     */
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
