/*
 Navicat Premium Dump SQL

 Source Server         : r-book
 Source Server Type    : MySQL
 Source Server Version : 80045 (8.0.45)
 Source Host           : 127.0.0.1:3306
 Source Schema         : r_book

 Target Server Type    : MySQL
 Target Server Version : 80045 (8.0.45)
 File Encoding         : 65001

 Date: 29/01/2026 17:00:30
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for cr_chapters
-- ----------------------------
DROP TABLE IF EXISTS `cr_chapters`;
CREATE TABLE `cr_chapters` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '章节ID',
  `name` varchar(100) NOT NULL COMMENT '章节名称',
  `sort_order` int DEFAULT '0' COMMENT '排序顺序',
  `is_deleted` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chapter_name` (`name`),
  KEY `idx_chapter_sort` (`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='章节表';

-- ----------------------------
-- Records of cr_chapters
-- ----------------------------
BEGIN;
INSERT INTO `cr_chapters` (`id`, `name`, `sort_order`, `is_deleted`, `created_at`, `updated_at`) VALUES (1, '第一章 描述性统计', 1, 0, '2026-01-26 11:48:29', '2026-01-26 11:48:29');
INSERT INTO `cr_chapters` (`id`, `name`, `sort_order`, `is_deleted`, `created_at`, `updated_at`) VALUES (2, '第二章 回归分析', 2, 0, '2026-01-26 11:48:29', '2026-01-26 11:48:29');
INSERT INTO `cr_chapters` (`id`, `name`, `sort_order`, `is_deleted`, `created_at`, `updated_at`) VALUES (3, '第三章 假设检验', 3, 0, '2026-01-26 11:48:29', '2026-01-26 11:48:29');
INSERT INTO `cr_chapters` (`id`, `name`, `sort_order`, `is_deleted`, `created_at`, `updated_at`) VALUES (4, '第七章', 7, 1, '2026-01-28 16:26:02', '2026-01-28 16:31:01');
INSERT INTO `cr_chapters` (`id`, `name`, `sort_order`, `is_deleted`, `created_at`, `updated_at`) VALUES (5, '第7章', 7, 0, '2026-01-29 13:13:59', '2026-01-29 13:13:59');
INSERT INTO `cr_chapters` (`id`, `name`, `sort_order`, `is_deleted`, `created_at`, `updated_at`) VALUES (6, '第8章', 8, 0, '2026-01-29 13:55:43', '2026-01-29 13:55:43');
COMMIT;

-- ----------------------------
-- Table structure for cr_execution_logs
-- ----------------------------
DROP TABLE IF EXISTS `cr_execution_logs`;
CREATE TABLE `cr_execution_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `script_id` varchar(64) NOT NULL,
  `user_id` bigint DEFAULT NULL COMMENT '执行用户ID',
  `request_params` text COMMENT '请求参数JSON',
  `is_success` tinyint(1) NOT NULL,
  `execution_time_ms` bigint DEFAULT '0',
  `error_message` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_create_time` (`created_at`),
  KEY `idx_script_id` (`script_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='脚本执行日志';

-- ----------------------------
-- Records of cr_execution_logs
-- ----------------------------
BEGIN;
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (1, 'drug-efficacy-ttest', NULL, '{\"scriptId\":\"drug-efficacy-ttest\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 1050, NULL, '2026-01-26 12:10:38');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (2, 'linear-regression', NULL, '{\"scriptId\":\"linear-regression\",\"variables\":{\"sample_size\":\"100\",\"noise_level\":\"0.8\"},\"fileData\":null,\"isRawInput\":null}', 1, 182, NULL, '2026-01-28 14:50:16');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (3, 'drug-efficacy-ttest', NULL, '{\"scriptId\":\"drug-efficacy-ttest\",\"variables\":{\"conf_level\":\"0.95\",\"equal_var\":\"false\"},\"fileData\":null,\"isRawInput\":null}', 1, 902, NULL, '2026-01-28 15:17:50');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (4, 'script-t9kfgqfh87', NULL, '{\"scriptId\":\"script-t9kfgqfh87\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 132, NULL, '2026-01-28 16:27:03');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (5, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 770, NULL, '2026-01-29 13:18:30');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (6, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"FALSE\"},\"fileData\":null,\"isRawInput\":null}', 1, 654, NULL, '2026-01-29 13:19:13');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (7, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"FALSE\"},\"fileData\":null,\"isRawInput\":null}', 1, 758, NULL, '2026-01-29 13:23:23');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (8, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"FALSE\"},\"fileData\":null,\"isRawInput\":null}', 1, 753, NULL, '2026-01-29 13:25:27');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (9, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n21,34\\n43,56\\n32,67\",\"isRawInput\":true}', 1, 753, NULL, '2026-01-29 13:26:55');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (10, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\",\"isRawInput\":true}', 1, 739, NULL, '2026-01-29 13:27:37');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (11, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n32,12\",\"isRawInput\":true}', 1, 725, NULL, '2026-01-29 13:27:55');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (12, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n1,2\",\"isRawInput\":true}', 1, 699, NULL, '2026-01-29 13:28:22');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (13, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"TRUE\"},\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n1,2\",\"isRawInput\":true}', 1, 746, NULL, '2026-01-29 13:28:33');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (14, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"FALSE\"},\"fileData\":null,\"isRawInput\":null}', 0, 138, 'R process exited with code 1', '2026-01-29 13:30:32');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (15, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 702, NULL, '2026-01-29 13:32:09');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (16, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 756, NULL, '2026-01-29 13:49:40');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (17, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 761, NULL, '2026-01-29 13:50:14');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (18, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 687, NULL, '2026-01-29 13:50:21');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (19, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 702, NULL, '2026-01-29 13:51:37');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (20, 'drug-efficacy-ttest', NULL, '{\"scriptId\":\"drug-efficacy-ttest\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 1033, NULL, '2026-01-29 13:52:35');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (21, 'script-t9m3puy2ot', NULL, '{\"scriptId\":\"script-t9m3puy2ot\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 185, NULL, '2026-01-29 14:08:27');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (22, 'script-t9m3puy2ot', NULL, '{\"scriptId\":\"script-t9m3puy2ot\",\"variables\":null,\"fileData\":\"Male,Female\\n54,43\\n23,34\\n45,65\\n54,77\\n45,46\\n50,65\",\"isRawInput\":true}', 1, 163, NULL, '2026-01-29 14:10:35');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (23, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 701, NULL, '2026-01-29 14:14:38');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (24, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 694, NULL, '2026-01-29 14:17:45');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (25, 'script-t9m3puy2ot', NULL, '{\"scriptId\":\"script-t9m3puy2ot\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 163, NULL, '2026-01-29 14:20:34');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (26, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 808, NULL, '2026-01-29 14:28:32');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (27, 'script-t9m3puy2ot', NULL, '{\"scriptId\":\"script-t9m3puy2ot\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 156, NULL, '2026-01-29 14:29:28');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (28, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 841, NULL, '2026-01-29 14:32:25');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (29, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"TRUE\"},\"fileData\":null,\"isRawInput\":null}', 1, 847, NULL, '2026-01-29 14:32:45');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (30, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n3,3\",\"isRawInput\":true}', 0, 825, 'R process exited with code 1', '2026-01-29 14:33:20');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (31, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 773, NULL, '2026-01-29 14:39:02');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (32, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n3,3\",\"isRawInput\":true}', 1, 758, NULL, '2026-01-29 14:39:22');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (33, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 786, NULL, '2026-01-29 14:42:43');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (34, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"TRUE\"},\"fileData\":null,\"isRawInput\":null}', 1, 806, NULL, '2026-01-29 14:43:22');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (35, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 800, NULL, '2026-01-29 14:49:26');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (36, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 0, 739, 'R process exited with code 1', '2026-01-29 14:51:29');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (37, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 796, NULL, '2026-01-29 14:52:21');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (38, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 854, NULL, '2026-01-29 14:55:13');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (39, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"TRUE\"},\"fileData\":null,\"isRawInput\":null}', 1, 847, NULL, '2026-01-29 14:55:37');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (40, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n3,3\",\"isRawInput\":true}', 1, 844, NULL, '2026-01-29 14:56:27');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (41, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"FALSE\"},\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n3,3\",\"isRawInput\":true}', 1, 851, NULL, '2026-01-29 14:57:00');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (42, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"true\"},\"fileData\":null,\"isRawInput\":null}', 1, 797, NULL, '2026-01-29 15:02:45');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (43, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 792, NULL, '2026-01-29 15:02:53');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (44, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n2,2\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\",\"isRawInput\":true}', 1, 822, NULL, '2026-01-29 15:03:12');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (45, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n2,2\\n2,2\",\"isRawInput\":true}', 0, 113, 'R process exited with code 1', '2026-01-29 15:03:29');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (46, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n2,2\\n2,2\\n1,1\\n1,1\",\"isRawInput\":true}', 1, 798, NULL, '2026-01-29 15:03:41');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (47, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"false\"},\"fileData\":\"group,x\\n2,2\\n2,2\\n1,1\\n1,1\",\"isRawInput\":true}', 1, 809, NULL, '2026-01-29 15:03:56');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (48, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 842, NULL, '2026-01-29 15:05:58');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (49, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"true\"},\"fileData\":null,\"isRawInput\":null}', 1, 849, NULL, '2026-01-29 15:06:19');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (50, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":null,\"fileData\":\"group,x\\n1,1\\n2,2\\n1,1\\n2,2\",\"isRawInput\":true}', 1, 848, NULL, '2026-01-29 15:07:13');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (51, 'script-t9m1egjnmj', NULL, '{\"scriptId\":\"script-t9m1egjnmj\",\"variables\":{\"yates_correction\":\"false\"},\"fileData\":\"group,x\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,1\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n1,2\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,1\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\\n2,2\",\"isRawInput\":true}', 1, 859, NULL, '2026-01-29 15:07:51');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (52, 'script-t9m3puy2ot', NULL, '{\"scriptId\":\"script-t9m3puy2ot\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 159, NULL, '2026-01-29 15:13:32');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (53, 'script-t9m3puy2ot', NULL, '{\"scriptId\":\"script-t9m3puy2ot\",\"variables\":null,\"fileData\":\"Male,Female\\n54,43\\n23,34\\n45,65\\n54,77\\n45,46\\n50,65\",\"isRawInput\":true}', 1, 159, NULL, '2026-01-29 15:14:11');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (54, 'script-t9m7yd51nb', NULL, '{\"scriptId\":\"script-t9m7yd51nb\",\"variables\":null,\"fileData\":null,\"isRawInput\":null}', 1, 123, NULL, '2026-01-29 15:40:07');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (55, 'script-t9m7yd51nb', NULL, '{\"scriptId\":\"script-t9m7yd51nb\",\"variables\":{\"x\":\"20\",\"y\":\"world\"},\"fileData\":null,\"isRawInput\":null}', 1, 122, NULL, '2026-01-29 15:40:34');
INSERT INTO `cr_execution_logs` (`id`, `script_id`, `user_id`, `request_params`, `is_success`, `execution_time_ms`, `error_message`, `created_at`) VALUES (56, 'script-t9m7yd51nb', NULL, '{\"scriptId\":\"script-t9m7yd51nb\",\"variables\":{\"x\":\"20\",\"y\":\"world\"},\"fileData\":\"Male,Female\\n54,43\\n23,34\\n45,65\\n54,77\\n45,46\\n50,65\",\"isRawInput\":true}', 1, 126, NULL, '2026-01-29 15:40:47');
COMMIT;

-- ----------------------------
-- Table structure for cr_script_variables
-- ----------------------------
DROP TABLE IF EXISTS `cr_script_variables`;
CREATE TABLE `cr_script_variables` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `script_id` varchar(64) NOT NULL COMMENT '关联脚本ID',
  `name` varchar(50) NOT NULL COMMENT 'R变量名',
  `label` varchar(50) NOT NULL COMMENT '前端显示名称',
  `type` varchar(20) NOT NULL COMMENT '数据类型: NUMBER, STRING, BOOLEAN',
  `default_value` varchar(100) DEFAULT NULL COMMENT '默认值',
  `description` varchar(200) DEFAULT NULL COMMENT '变量说明',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_script_id` (`script_id`),
  CONSTRAINT `FKhgqhtsnuudqnx3rfp4bj7ypab` FOREIGN KEY (`script_id`) REFERENCES `cr_scripts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='脚本变量配置表';

-- ----------------------------
-- Records of cr_script_variables
-- ----------------------------
BEGIN;
INSERT INTO `cr_script_variables` (`id`, `script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) VALUES (1, 'linear-regression', 'sample_size', '样本数量', 'NUMBER', '100', '生成的样本数量 (10-1000)', 1);
INSERT INTO `cr_script_variables` (`id`, `script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) VALUES (2, 'linear-regression', 'noise_level', '噪声水平', 'NUMBER', '0.5', '数据噪声干扰程度', 2);
INSERT INTO `cr_script_variables` (`id`, `script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) VALUES (7, 'drug-efficacy-ttest', 'conf_level', '置信水平', 'NUMBER', '0.95', '统计推断的置信区间 (0.90 - 0.99)', 1);
INSERT INTO `cr_script_variables` (`id`, `script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) VALUES (8, 'drug-efficacy-ttest', 'equal_var', '假设方差相等', 'BOOLEAN', 'false', '是否假设两组总体方差相等 (开启为 Student t-test，关闭为 Welch t-test)', 2);
INSERT INTO `cr_script_variables` (`id`, `script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) VALUES (19, 'script-t9m1egjnmj', 'yates_correction', 'yates_correction', 'BOOLEAN', 'FALSE', '是否开启Yates连续性校正，默认为 FALSE', 1);
INSERT INTO `cr_script_variables` (`id`, `script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) VALUES (20, 'script-t9m7yd51nb', 'x', 'x', 'NUMBER', '10', '测试x', 1);
INSERT INTO `cr_script_variables` (`id`, `script_id`, `name`, `label`, `type`, `default_value`, `description`, `sort_order`) VALUES (21, 'script-t9m7yd51nb', 'y', 'y', 'STRING', 'hello', '测试y', 2);
COMMIT;

-- ----------------------------
-- Table structure for cr_scripts
-- ----------------------------
DROP TABLE IF EXISTS `cr_scripts`;
CREATE TABLE `cr_scripts` (
  `id` varchar(64) NOT NULL COMMENT '脚本业务ID',
  `name` varchar(100) NOT NULL COMMENT '脚本名称',
  `description` text COMMENT '描述(支持Markdown格式)',
  `file_path` varchar(255) NOT NULL COMMENT 'R脚本文件名或路径',
  `chapter` varchar(100) DEFAULT NULL,
  `sort_order` int DEFAULT '0' COMMENT '章节内排序',
  `supports_variables` tinyint(1) DEFAULT '0' COMMENT '是否支持变量',
  `supports_file_input` tinyint(1) DEFAULT '0' COMMENT '是否支持文件输入',
  `file_input_desc` varchar(255) DEFAULT NULL COMMENT '文件输入说明',
  `example_data` text COMMENT 'CSV示例数据',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_chapter` (`chapter`),
  KEY `idx_chapter_sort` (`chapter`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='R脚本定义表';

-- ----------------------------
-- Records of cr_scripts
-- ----------------------------
BEGIN;
INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`, `created_at`, `updated_at`, `is_deleted`) VALUES ('basic-stats', '基础统计分析', '计算数据的基本统计量', 'basic_stats.R', '第一章 描述性统计', 1, 0, 1, '请上传包含数值数据的 CSV 文件', 'value\n23\n45\n67\n89\n12\n34\n56\n78\n90\n21', '2026-01-26 11:48:29', '2026-01-26 11:48:29', 0);
INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`, `created_at`, `updated_at`, `is_deleted`) VALUES ('drug-efficacy-ttest', '新型降压药疗效对比分析', '#### 💊 题目：新型降压药疗效对比分析 (T检验)\n\n**背景描述**\n本实验旨在评估一种新型降压药相对于安慰剂在降低收缩压方面的疗效。\n\n**统计学原理**\n统计量计算公式如下：\n$$ t = \\frac{\\bar{X}_1 - \\bar{X}_2}{\\sqrt{\\frac{s_1^2}{n_1} + \\frac{s_2^2}{n_2}}} $$\n\n**数据要求**\n请上传包含以下列的 CSV 文件：\n\n| 变量名 | 类型 | 描述 |\n| :--- | :--- | :--- |\n| `group` | String | 分组标签 |\n| `reduction` | Number | 血压下降数值 (mmHg) |', 'drug_efficacy_ttest.R', '第三章 假设检验', 1, 1, 1, '请上传包含 group (分组) 和 reduction (数值) 的 CSV 文件', 'group,reduction\nTreatment,15.5\nTreatment,12.3\nTreatment,18.1\nTreatment,14.2\nTreatment,16.8\nControl,5.2\nControl,4.8\nControl,6.1\nControl,3.9\nControl,5.5', '2026-01-26 11:48:29', '2026-01-26 11:55:46', 0);
INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`, `created_at`, `updated_at`, `is_deleted`) VALUES ('linear-regression', '线性回归分析', '执行简单线性回归并生成图表', 'linear_regression.R', '第二章 回归分析', 1, 1, 1, '请上传包含 x 和 y 两列数据的 CSV 文件', 'x,y\n1,2.3\n2,4.1\n3,6.5\n4,8.2\n5,10.8\n6,12.1\n7,14.9\n8,16.3\n9,18.7\n10,20.2', '2026-01-26 11:48:29', '2026-01-26 11:48:29', 0);
INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`, `created_at`, `updated_at`, `is_deleted`) VALUES ('script-t9kfgqfh87', '第七章第一节', '测试', 'script-t9kfgqfh87.R', '第七章', NULL, 0, 0, NULL, NULL, '2026-01-28 16:26:50', '2026-01-28 16:31:25', 1);
INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`, `created_at`, `updated_at`, `is_deleted`) VALUES ('script-t9m1egjnmj', '卡方检验测试', '## 测试卡方检验\n测试卡方检验', 'script-t9m1egjnmj.R', '第7章', NULL, 1, 1, '请上传包含group和x两列的csv文件', 'group,x\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,1\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n1,2\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,1\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2\n2,2', '2026-01-29 13:18:17', '2026-01-29 15:02:21', 0);
INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`, `created_at`, `updated_at`, `is_deleted`) VALUES ('script-t9m3puy2ot', 'T检验', '## 测试T检验\n\n测试T检验', 'script-t9m3puy2ot.R', '第8章', NULL, 0, 1, '包含Male和Female两列的CSV文件', 'Male,Female\n54,43\n23,34\n45,65\n54,77\n45,46\n,65', '2026-01-29 14:08:18', '2026-01-29 14:08:18', 0);
INSERT INTO `cr_scripts` (`id`, `name`, `description`, `file_path`, `chapter`, `sort_order`, `supports_variables`, `supports_file_input`, `file_input_desc`, `example_data`, `created_at`, `updated_at`, `is_deleted`) VALUES ('script-t9m7yd51nb', 'Hello World', '## 输出 Hello World\n使用print函数输出 Hello World字符串', 'script-t9m7yd51nb.R', '第7章', NULL, 1, 1, '上传包含Male和Female两列的csv文件', 'Male,Female\n54,43\n23,34\n45,65\n54,77\n45,46\n,65', '2026-01-29 15:39:50', '2026-01-29 15:39:50', 0);
COMMIT;

-- ----------------------------
-- Table structure for cr_user_logs
-- ----------------------------
DROP TABLE IF EXISTS `cr_user_logs`;
CREATE TABLE `cr_user_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `operation_type` varchar(50) NOT NULL COMMENT '操作类型: CREATE_SCRIPT(新增题目), UPDATE_SCRIPT(修改题目), DELETE_SCRIPT(删除题目)',
  `script_id` varchar(64) DEFAULT NULL COMMENT '题目/脚本ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_script_id` (`script_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户操作日志表';

-- ----------------------------
-- Records of cr_user_logs
-- ----------------------------
BEGIN;
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (1, 1, 'UPDATE_SCRIPT', 'drug-efficacy-ttest', '2026-01-26 11:54:52');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (2, 1, 'UPDATE_SCRIPT', 'drug-efficacy-ttest', '2026-01-26 11:55:46');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (3, 1, 'UPDATE_SCRIPT', 'basic-stats', '2026-01-26 12:03:45');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (4, 1, 'CREATE_SCRIPT', 'script-t9kfgqfh87', '2026-01-28 16:26:50');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (5, 1, 'DELETE_SCRIPT', 'script-t9kfgqfh87', '2026-01-28 16:31:25');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (6, 1, 'CREATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 13:18:17');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (7, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 13:24:59');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (8, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 13:25:13');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (9, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 13:30:20');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (10, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 13:32:00');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (11, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 13:51:18');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (12, 1, 'CREATE_SCRIPT', 'script-t9m3puy2ot', '2026-01-29 14:08:18');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (13, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 14:28:23');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (14, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 14:38:53');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (15, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 14:51:21');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (16, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 14:52:16');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (17, 1, 'UPDATE_SCRIPT', 'script-t9m1egjnmj', '2026-01-29 15:02:21');
INSERT INTO `cr_user_logs` (`id`, `user_id`, `operation_type`, `script_id`, `created_at`) VALUES (18, 1, 'CREATE_SCRIPT', 'script-t9m7yd51nb', '2026-01-29 15:39:50');
COMMIT;

-- ----------------------------
-- Table structure for cr_users
-- ----------------------------
DROP TABLE IF EXISTS `cr_users`;
CREATE TABLE `cr_users` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码(加密存储)',
  `user_type` varchar(20) NOT NULL DEFAULT 'WORKER' COMMENT '用户类型: ADMIN(管理员), WORKER(工人)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户信息表';

-- ----------------------------
-- Records of cr_users
-- ----------------------------
BEGIN;
INSERT INTO `cr_users` (`id`, `username`, `password`, `user_type`, `created_at`, `updated_at`) VALUES (1, 'admin', '$2a$10$666SXwEDliXbfd0A2Tw7VuWfyODDhfDmIuGcl1YRi9b2wDjPhVXTi', 'ADMIN', '2026-01-26 11:48:41', '2026-01-26 11:48:41');
INSERT INTO `cr_users` (`id`, `username`, `password`, `user_type`, `created_at`, `updated_at`) VALUES (2, 'worker01', '$2a$10$MNSXTY3gZ9iWLcgFdGFPJO/atV7Xr5Drwnc/wEwwOUPT2GcAYZqZa', 'WORKER', '2026-01-26 12:07:59', '2026-01-26 12:07:59');
INSERT INTO `cr_users` (`id`, `username`, `password`, `user_type`, `created_at`, `updated_at`) VALUES (3, 'worker02', '$2a$10$OLtQ8Iy23dGgjIYUqG7Xs.A6mrSltfd9T9gErG7MNsjfLILYql3oO', 'WORKER', '2026-01-26 12:07:59', '2026-01-26 12:07:59');
INSERT INTO `cr_users` (`id`, `username`, `password`, `user_type`, `created_at`, `updated_at`) VALUES (4, 'worker03', '$2a$10$A5yoq2bevakMzgkYRZcYZuPlxifTw.9SE39A5kN7vKfResKQcRCCu', 'WORKER', '2026-01-26 12:07:59', '2026-01-26 12:07:59');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
