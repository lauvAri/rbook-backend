package com.csu.r_book.modules.coderunner.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDateTime;
import java.util.List;

/**
 * R脚本定义实体
 */
@Data
@Entity
@Table(name = "cr_scripts")
@SQLRestriction("is_deleted = 0")
public class RScriptEntity {

    /**
     * 脚本业务ID (如 linear-regression)
     */
    @Id
    @Column(length = 64)
    private String id;

    /**
     * 脚本名称
     */
    @Column(length = 100, nullable = false)
    private String name;

    /**
     * 脚本描述 (支持Markdown格式，包括表格和LaTeX公式)
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * R脚本文件路径
     */
    @Column(name = "file_path", length = 255, nullable = false)
    private String filePath;

    /**
     * 是否支持自定义参数
     */
    @Column(name = "supports_variables")
    private Boolean supportsVariables = false;

    /**
     * 是否支持文件上传
     */
    @Column(name = "supports_file_input")
    private Boolean supportsFileInput = false;

    /**
     * 文件上传的提示文案
     */
    @Column(name = "file_input_desc", length = 255)
    private String fileInputDesc;

    /**
     * CSV 示例数据，展示给用户参考期望的数据格式
     */
    @Column(name = "example_data", columnDefinition = "TEXT")
    private String exampleData;

    /**
     * 所属章节
     */
    @Column(length = 100)
    private String chapter;

    /**
     * 排序顺序
     */
    @Column(name = "sort_order")
    private Integer sortOrder;

    /**
     * 创建时间
     */
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * 逻辑删除标记
     */
    @Column(name = "is_deleted")
    private Integer isDeleted = 0;

    /**
     * 一对多关联：获取该脚本下的所有变量配置
     */
    @OneToMany(mappedBy = "script", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    @OrderBy("sortOrder ASC")
    private List<ScriptVariableEntity> variables;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
