-- =============================================
-- Code Runner 模块数据库初始化脚本 (MySQL 8.0+)
-- =============================================

-- 1. 用户信息表
CREATE TABLE IF NOT EXISTS `cr_users` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码(加密存储)',
  `user_type` VARCHAR(20) NOT NULL DEFAULT 'WORKER' COMMENT '用户类型: ADMIN(管理员), WORKER(工人)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- 2. 用户操作日志表
CREATE TABLE IF NOT EXISTS `cr_user_logs` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
  `operation_type` VARCHAR(50) NOT NULL COMMENT '操作类型: CREATE_SCRIPT(新增题目), UPDATE_SCRIPT(修改题目), DELETE_SCRIPT(删除题目)',
  `script_id` VARCHAR(64) DEFAULT NULL COMMENT '题目/脚本ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_script_id` (`script_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户操作日志表';

-- 3. 章节表
CREATE TABLE IF NOT EXISTS `cr_chapters` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '章节ID',
  `name` VARCHAR(100) NOT NULL COMMENT '章节名称',
  `sort_order` INT(11) DEFAULT 0 COMMENT '排序顺序',
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chapter_name` (`name`),
  KEY `idx_chapter_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='章节表';

-- 4. 脚本主表
CREATE TABLE IF NOT EXISTS `cr_scripts` (
  `id` VARCHAR(64) NOT NULL COMMENT '脚本业务ID',
  `name` VARCHAR(100) NOT NULL COMMENT '脚本名称',
  `description` TEXT DEFAULT NULL COMMENT '描述(支持Markdown格式)',
  `file_path` VARCHAR(255) NOT NULL COMMENT 'R脚本文件名或路径',
  `chapter` VARCHAR(50) DEFAULT NULL COMMENT '所属章节',
  `sort_order` INT(11) DEFAULT 0 COMMENT '章节内排序',
  `supports_variables` TINYINT(1) DEFAULT 0 COMMENT '是否支持变量',
  `supports_file_input` TINYINT(1) DEFAULT 0 COMMENT '是否支持文件输入',
  `file_input_desc` VARCHAR(255) DEFAULT NULL COMMENT '文件输入说明',
  `example_data` TEXT DEFAULT NULL COMMENT 'CSV示例数据',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_chapter` (`chapter`),
  KEY `idx_chapter_sort` (`chapter`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='R脚本定义表';

-- 5. 脚本变量表
CREATE TABLE IF NOT EXISTS `cr_script_variables` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `script_id` VARCHAR(64) NOT NULL COMMENT '关联脚本ID',
  `name` VARCHAR(50) NOT NULL COMMENT 'R变量名',
  `label` VARCHAR(50) NOT NULL COMMENT '前端显示名称',
  `type` VARCHAR(20) NOT NULL COMMENT '数据类型: NUMBER, STRING, BOOLEAN',
  `default_value` VARCHAR(100) DEFAULT NULL COMMENT '默认值',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '变量说明',
  `sort_order` INT(11) DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_script_id` (`script_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='脚本变量配置表';

-- 6. 执行日志表
CREATE TABLE IF NOT EXISTS `cr_execution_logs` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `script_id` VARCHAR(64) NOT NULL,
  `user_id` BIGINT(20) DEFAULT NULL COMMENT '执行用户ID',
  `request_params` TEXT DEFAULT NULL COMMENT '请求参数JSON',
  `is_success` TINYINT(1) NOT NULL,
  `execution_time_ms` BIGINT(20) DEFAULT 0,
  `error_message` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_create_time` (`created_at`),
  KEY `idx_script_id` (`script_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='脚本执行日志';

-- =============================================
-- 初始化默认数据
-- =============================================

-- 默认管理员账户由 Java 应用启动时自动创建 (DataInitializer.java)
-- 用户名: admin，密码: admin123

-- 演示脚本数据
INSERT INTO `cr_chapters` (`name`, `sort_order`, `is_deleted`)
VALUES
('第一章 描述性统计', 1, 0),
('第二章 回归分析', 2, 0),
('第三章 假设检验', 3, 0)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `sort_order` = VALUES(`sort_order`), `is_deleted` = VALUES(`is_deleted`);

INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`) 
VALUES 
('basic-stats', '基础统计分析', '计算数据的基本统计量', 'basic_stats.R', '第一章 描述性统计', 1, 0, 1, '请上传包含数值数据的 CSV 文件', 'value\n23\n45\n67\n89\n12\n34\n56\n78\n90\n21'),
('linear-regression', '线性回归分析', '执行简单线性回归并生成图表', 'linear_regression.R', '第二章 回归分析', 1, 1, 1, '请上传包含 x 和 y 两列数据的 CSV 文件', 'x,y\n1,2.3\n2,4.1\n3,6.5\n4,8.2\n5,10.8\n6,12.1\n7,14.9\n8,16.3\n9,18.7\n10,20.2'),
('drug-efficacy-ttest', '新型降压药疗效对比分析', '#### 💊 题目：新型降压药疗效对比分析 (T检验)\n\n**背景描述**\n本实验旨在评估一种新型降压药相对于安慰剂在降低收缩压方面的疗效。\n\n**统计学原理**\n统计量计算公式如下：\n$$ t = \\frac{\\bar{X}_1 - \\bar{X}_2}{\\sqrt{\\frac{s_1^2}{n_1} + \\frac{s_2^2}{n_2}}} $$\n\n**数据要求**\n请上传包含以下列的 CSV 文件：\n\n| 变量名 | 类型 | 描述 |\n| :--- | :--- | :--- |\n| `group` | String | 分组标签 |\n| `reduction` | Number | 血压下降数值 (mmHg) |', 'drug_efficacy_ttest.R', '第三章 假设检验', 1, 1, 1, '请上传包含 group (分组) 和 reduction (数值) 的 CSV 文件', 'group,reduction\nTreatment,15.5\nTreatment,12.3\nTreatment,18.1\nTreatment,14.2\nTreatment,16.8\nControl,5.2\nControl,4.8\nControl,6.1\nControl,3.9\nControl,5.5')
ON DUPLICATE KEY UPDATE `chapter` = VALUES(`chapter`), `sort_order` = VALUES(`sort_order`);

INSERT INTO `cr_script_variables` (`script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) 
VALUES 
('linear-regression', 'sample_size', '样本数量', 'NUMBER', '100', '生成的样本数量 (10-1000)', 1),
('linear-regression', 'noise_level', '噪声水平', 'NUMBER', '0.5', '数据噪声干扰程度', 2),
('drug-efficacy-ttest', 'conf_level', '置信水平', 'NUMBER', '0.95', '统计推断的置信区间 (0.90 - 0.99)', 1),
('drug-efficacy-ttest', 'equal_var', '假设方差相等', 'BOOLEAN', 'false', '是否假设两组总体方差相等 (开启为 Student t-test，关闭为 Welch t-test)', 2)
ON DUPLICATE KEY UPDATE `script_id` = `script_id`;
