package com.csu.r_book.modules.coderunner.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.ToString;

/**
 * 脚本变量配置实体
 */
@Data
@Entity
@Table(name = "cr_script_variables")
public class ScriptVariableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 多对一关联：回到 Script
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "script_id")
    @ToString.Exclude
    private RScriptEntity script;

    /**
     * R 变量名
     */
    @Column(length = 50, nullable = false)
    private String name;

    /**
     * 前端显示名称
     */
    @Column(length = 50, nullable = false)
    private String label;

    /**
     * 变量类型: NUMBER, STRING, BOOLEAN
     */
    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private VariableType type = VariableType.STRING;

    /**
     * 默认值
     */
    @Column(name = "default_value", length = 100)
    private String defaultValue;

    /**
     * 变量说明
     */
    @Column(length = 200)
    private String description;

    /**
     * 前端表单的排序权重
     */
    @Column(name = "sort_order")
    private Integer sortOrder = 0;

    /**
     * 变量类型枚举
     */
    public enum VariableType {
        NUMBER,
        STRING,
        BOOLEAN
    }
}
