SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
-- ai_chat_config DDL
DROP TABLE IF EXISTS `ai_chat_config`;
CREATE TABLE `ai_chat_config` (`chat_config_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "配置主键",
`user_id` BIGINT(20) NOT NULL Comment "用户ID",
`temperature` FLOAT NULL Comment "默认温度",
`add_history_to_context` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "是否添加历史记录(0是, 1否)",
`num_history_runs` INT(4) NULL Comment "历史记录条数",
`system_prompt` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "系统提示词",
`metrics_default_visible` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "默认显示指标(0是, 1否)",
`vision_enabled` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' Comment "是否开启视觉(0是, 1否)",
`image_max_size_mb` INT(4) NULL Comment "图片最大大小(MB)",
`create_time` DATETIME NULL Comment "创建时间",
`update_time` DATETIME NULL Comment "更新时间",
UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
PRIMARY KEY (`chat_config_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 1 ROW_FORMAT = Dynamic COMMENT = "AI对话配置表";
-- ai_models DDL
DROP TABLE IF EXISTS `ai_models`;
CREATE TABLE `ai_models` (`model_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "模型主键",
`model_code` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "模型编码",
`model_name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "模型名称",
`provider` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "提供商",
`model_sort` INT(4) NOT NULL Comment "显示顺序",
`api_key` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "API Key",
`base_url` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "Base URL",
`model_type` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "模型类型",
`max_tokens` INT(11) NULL Comment "最大输出token",
`temperature` FLOAT NULL Comment "默认温度",
`support_reasoning` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' Comment "是否支持推理",
`support_images` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' Comment "是否支持图片",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "模型状态",
`user_id` BIGINT(20) NULL Comment "用户ID",
`dept_id` BIGINT(20) NULL Comment "部门ID",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`model_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 1 ROW_FORMAT = Dynamic COMMENT = "AI模型表";
-- apscheduler_jobs DDL
DROP TABLE IF EXISTS `apscheduler_jobs`;
CREATE TABLE `apscheduler_jobs` (`id` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
`next_run_time` DOUBLE NULL,
`job_state` BLOB NOT NULL,
INDEX `ix_apscheduler_jobs_next_run_time`(`next_run_time` ASC) USING BTREE,
PRIMARY KEY (`id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;
-- dm_datasource DDL
DROP TABLE IF EXISTS `dm_datasource`;
CREATE TABLE `dm_datasource` (`id` INT(11) NOT NULL AUTO_INCREMENT Comment "数据源ID",
`name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "数据源名称",
`db_type` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "数据库类型",
`host` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "主机地址",
`port` INT(11) NULL DEFAULT 0 Comment "端口",
`database` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "数据库名",
`username` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "用户名",
`password` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "密码",
`created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP Comment "创建时间",
`updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) Comment "更新时间",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`is_shared` TINYINT(1) NOT NULL DEFAULT 0 Comment "是否共享",
UNIQUE INDEX `name`(`name` ASC) USING BTREE,
PRIMARY KEY (`id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 2 ROW_FORMAT = Dynamic COMMENT = "数据建模-数据源";
-- dm_model DDL
DROP TABLE IF EXISTS `dm_model`;
CREATE TABLE `dm_model` (`id` INT(11) NOT NULL AUTO_INCREMENT Comment "模型ID",
`name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "模型名称",
`description` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "描述",
`graph_data` MEDIUMTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "图数据JSON",
`created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP Comment "创建时间",
`updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) Comment "更新时间",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`is_shared` TINYINT(1) NOT NULL DEFAULT 0 Comment "是否共享",
PRIMARY KEY (`id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 2 ROW_FORMAT = Dynamic COMMENT = "数据建模-模型";
-- dm_operator DDL
DROP TABLE IF EXISTS `dm_operator`;
CREATE TABLE `dm_operator` (`id` INT(11) NOT NULL AUTO_INCREMENT Comment "算子ID",
`name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "算子名称",
`op_type` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "算子类型",
`description` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "描述",
`sql_template` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "SQL模板",
`is_builtin` TINYINT(1) NULL DEFAULT 0 Comment "是否内置",
`config_schema` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "配置schema",
`created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP Comment "创建时间",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`is_shared` TINYINT(1) NOT NULL DEFAULT 0 Comment "是否共享",
PRIMARY KEY (`id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 11 ROW_FORMAT = Dynamic COMMENT = "数据建模-算子";
-- dm_published_api DDL
DROP TABLE IF EXISTS `dm_published_api`;
CREATE TABLE `dm_published_api` (`id` INT(11) NOT NULL AUTO_INCREMENT Comment "API ID",
`name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "API名称",
`path` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "路径",
`model_id` INT(11) NOT NULL Comment "模型ID",
`description` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "描述",
`params` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "参数定义JSON",
`enabled` TINYINT(1) NULL DEFAULT 1 Comment "是否启用",
`created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP Comment "创建时间",
`updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) Comment "更新时间",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`is_shared` TINYINT(1) NOT NULL DEFAULT 0 Comment "是否共享",
UNIQUE INDEX `path`(`path` ASC) USING BTREE,
PRIMARY KEY (`id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 2 ROW_FORMAT = Dynamic COMMENT = "数据建模-已发布API";
-- dm_seed DDL
DROP TABLE IF EXISTS `dm_seed`;
CREATE TABLE `dm_seed` (`id` INT(11) NOT NULL AUTO_INCREMENT Comment "种子ID",
`name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "种子名称",
`datasource_id` INT(11) NOT NULL Comment "数据源ID",
`table_name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "表名",
`description` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "描述",
`created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP Comment "创建时间",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`is_shared` TINYINT(1) NOT NULL DEFAULT 0 Comment "是否共享",
PRIMARY KEY (`id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 6 ROW_FORMAT = Dynamic COMMENT = "数据建模-种子";
-- gen_table DDL
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table` (`table_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "编号",
`table_name` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "表名称",
`table_comment` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "表描述",
`sub_table_name` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "关联子表的表名",
`sub_table_fk_name` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "子表关联的外键名",
`class_name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "实体类名称",
`tpl_category` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'crud' Comment "使用的模板（crud单表操作 tree树表操作）",
`tpl_web_type` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "前端模板类型（element-ui模版 element-plus模版）",
`package_name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "生成包路径",
`module_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "生成模块名",
`business_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "生成业务名",
`function_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "生成功能名",
`function_author` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "生成功能作者",
`gen_type` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "生成代码方式（0zip压缩包 1自定义路径）",
`gen_path` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '/' Comment "生成路径（不填默认项目路径）",
`options` VARCHAR(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "其它生成选项",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`table_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 1 ROW_FORMAT = Dynamic COMMENT = "代码生成业务表";
-- gen_table_column DDL
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column` (`column_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "编号",
`table_id` BIGINT(20) NULL Comment "归属表编号",
`column_name` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "列名称",
`column_comment` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "列描述",
`column_type` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "列类型",
`python_type` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "PYTHON类型",
`python_field` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "PYTHON字段名",
`is_pk` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否主键（1是）",
`is_increment` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否自增（1是）",
`is_required` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否必填（1是）",
`is_unique` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否唯一（1是）",
`is_insert` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否为插入字段（1是）",
`is_edit` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否编辑字段（1是）",
`is_list` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否列表字段（1是）",
`is_query` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "是否查询字段（1是）",
`query_type` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'EQ' Comment "查询方式（等于、不等于、大于、小于、范围）",
`html_type` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）",
`dict_type` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "字典类型",
`sort` INT(11) NULL Comment "排序",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
PRIMARY KEY (`column_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 1 ROW_FORMAT = Dynamic COMMENT = "代码生成业务表字段";
-- sys_config DDL
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (`config_id` INT(5) NOT NULL AUTO_INCREMENT Comment "参数主键",
`config_name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "参数名称",
`config_key` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "参数键名",
`config_value` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "参数键值",
`config_type` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' Comment "系统内置（Y是 N否）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`config_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 9 ROW_FORMAT = Dynamic COMMENT = "参数配置表";
-- sys_dept DDL
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept` (`dept_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "部门id",
`parent_id` BIGINT(20) NULL DEFAULT 0 Comment "父部门id",
`ancestors` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "祖级列表",
`dept_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "部门名称",
`order_num` INT(4) NULL DEFAULT 0 Comment "显示顺序",
`leader` VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "负责人",
`phone` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "联系电话",
`email` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "邮箱",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "部门状态（0正常 1停用）",
`del_flag` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "删除标志（0代表存在 2代表删除）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
PRIMARY KEY (`dept_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 110 ROW_FORMAT = Dynamic COMMENT = "部门表";
-- sys_dict_data DDL
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data` (`dict_code` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "字典编码",
`dict_sort` INT(4) NULL DEFAULT 0 Comment "字典排序",
`dict_label` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "字典标签",
`dict_value` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "字典键值",
`dict_type` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "字典类型",
`css_class` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "样式属性（其他样式扩展）",
`list_class` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "表格回显样式",
`is_default` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' Comment "是否默认（Y是 N否）",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "状态（0正常 1停用）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`dict_code`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 70 ROW_FORMAT = Dynamic COMMENT = "字典数据表";
-- sys_dict_type DDL
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type` (`dict_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "字典主键",
`dict_name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "字典名称",
`dict_type` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "字典类型",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "状态（0正常 1停用）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE,
PRIMARY KEY (`dict_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 13 ROW_FORMAT = Dynamic COMMENT = "字典类型表";
-- sys_job DDL
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job` (`job_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "任务ID",
`job_name` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' Comment "任务名称",
`job_group` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'default' Comment "任务组名",
`job_executor` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'default' Comment "任务执行器",
`invoke_target` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "调用目标字符串",
`job_args` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "位置参数",
`job_kwargs` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "关键字参数",
`cron_expression` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "cron执行表达式",
`misfire_policy` VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '3' Comment "计划执行错误策略（1立即执行 2执行一次 3放弃执行）",
`concurrent` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' Comment "是否并发执行（0允许 1禁止）",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "状态（0正常 1暂停）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "备注信息",
PRIMARY KEY (`job_id`,
`job_name`,
`job_group`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 4 ROW_FORMAT = Dynamic COMMENT = "定时任务调度表";
-- sys_job_log DDL
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log` (`job_log_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "任务日志ID",
`job_name` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "任务名称",
`job_group` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "任务组名",
`job_executor` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "任务执行器",
`invoke_target` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "调用目标字符串",
`job_args` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "位置参数",
`job_kwargs` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "关键字参数",
`job_trigger` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "任务触发器",
`job_message` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "日志信息",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "执行状态（0正常 1失败）",
`exception_info` VARCHAR(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "异常信息",
`create_time` DATETIME NULL Comment "创建时间",
PRIMARY KEY (`job_log_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 1 ROW_FORMAT = Dynamic COMMENT = "定时任务调度日志表";
-- sys_logininfor DDL
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor` (`info_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "访问ID",
`user_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "用户账号",
`ipaddr` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "登录IP地址",
`login_location` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "登录地点",
`browser` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "浏览器类型",
`os` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "操作系统",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "登录状态（0成功 1失败）",
`msg` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "提示消息",
`login_time` DATETIME NULL Comment "访问时间",
INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE,
INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
PRIMARY KEY (`info_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 17 ROW_FORMAT = Dynamic COMMENT = "系统访问记录";
-- sys_menu DDL
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (`menu_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "菜单ID",
`menu_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "菜单名称",
`parent_id` BIGINT(20) NULL DEFAULT 0 Comment "父菜单ID",
`order_num` INT(4) NULL DEFAULT 0 Comment "显示顺序",
`path` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "路由地址",
`component` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "组件路径",
`query` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "路由参数",
`route_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "路由名称",
`is_frame` INT(1) NULL DEFAULT 1 Comment "是否为外链（0是 1否）",
`is_cache` INT(1) NULL DEFAULT 0 Comment "是否缓存（0缓存 1不缓存）",
`menu_type` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "菜单类型（M目录 C菜单 F按钮）",
`visible` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "菜单状态（0显示 1隐藏）",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "菜单状态（0正常 1停用）",
`perms` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "权限标识",
`icon` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '#' Comment "菜单图标",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "备注",
PRIMARY KEY (`menu_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 2031 ROW_FORMAT = Dynamic COMMENT = "菜单权限表";
-- sys_notice DDL
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice` (`notice_id` INT(4) NOT NULL AUTO_INCREMENT Comment "公告ID",
`notice_title` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "公告标题",
`notice_type` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "公告类型（1通知 2公告）",
`notice_content` LONGBLOB NULL Comment "公告内容",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "公告状态（0正常 1关闭）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`notice_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 3 ROW_FORMAT = Dynamic COMMENT = "通知公告表";
-- sys_oper_log DDL
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log` (`oper_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "日志主键",
`title` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "模块标题",
`business_type` INT(2) NULL DEFAULT 0 Comment "业务类型（0其它 1新增 2修改 3删除）",
`method` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "方法名称",
`request_method` VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "请求方式",
`operator_type` INT(1) NULL DEFAULT 0 Comment "操作类别（0其它 1后台用户 2手机端用户）",
`oper_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "操作人员",
`dept_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "部门名称",
`oper_url` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "请求URL",
`oper_ip` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "主机地址",
`oper_location` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "操作地点",
`oper_param` VARCHAR(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "请求参数",
`json_result` VARCHAR(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "返回参数",
`status` INT(1) NULL DEFAULT 0 Comment "操作状态（0正常 1异常）",
`error_msg` VARCHAR(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "错误消息",
`oper_time` DATETIME NULL Comment "操作时间",
`cost_time` BIGINT(20) NULL DEFAULT 0 Comment "消耗时间",
INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE,
INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
PRIMARY KEY (`oper_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 4 ROW_FORMAT = Dynamic COMMENT = "操作日志记录";
-- sys_post DDL
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post` (`post_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "岗位ID",
`post_code` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "岗位编码",
`post_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "岗位名称",
`post_sort` INT(4) NOT NULL Comment "显示顺序",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "状态（0正常 1停用）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`post_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 5 ROW_FORMAT = Dynamic COMMENT = "岗位信息表";
-- sys_role DDL
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (`role_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "角色ID",
`role_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "角色名称",
`role_key` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "角色权限字符串",
`role_sort` INT(4) NOT NULL Comment "显示顺序",
`data_scope` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' Comment "数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）",
`menu_check_strictly` TINYINT(1) NULL DEFAULT 1 Comment "菜单树选择项是否关联显示",
`dept_check_strictly` TINYINT(1) NULL DEFAULT 1 Comment "部门树选择项是否关联显示",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "角色状态（0正常 1停用）",
`del_flag` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "删除标志（0代表存在 2代表删除）",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`role_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 3 ROW_FORMAT = Dynamic COMMENT = "角色信息表";
-- sys_role_dept DDL
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept` (`role_id` BIGINT(20) NOT NULL Comment "角色ID",
`dept_id` BIGINT(20) NOT NULL Comment "部门ID",
PRIMARY KEY (`role_id`,
`dept_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic COMMENT = "角色和部门关联表";
-- sys_role_menu DDL
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (`role_id` BIGINT(20) NOT NULL Comment "角色ID",
`menu_id` BIGINT(20) NOT NULL Comment "菜单ID",
PRIMARY KEY (`role_id`,
`menu_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic COMMENT = "角色和菜单关联表";
-- sys_user DDL
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (`user_id` BIGINT(20) NOT NULL AUTO_INCREMENT Comment "用户ID",
`dept_id` BIGINT(20) NULL Comment "部门ID",
`user_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "用户账号",
`nick_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL Comment "用户昵称",
`user_type` VARCHAR(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '00' Comment "用户类型（00系统用户）",
`email` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "用户邮箱",
`phonenumber` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "手机号码",
`sex` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "用户性别（0男 1女 2未知）",
`avatar` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "头像地址",
`password` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "密码",
`status` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "帐号状态（0正常 1停用）",
`del_flag` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' Comment "删除标志（0代表存在 2代表删除）",
`login_ip` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "最后登录IP",
`login_date` DATETIME NULL Comment "最后登录时间",
`pwd_update_date` DATETIME NULL Comment "密码最后更新时间",
`create_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "创建者",
`create_time` DATETIME NULL Comment "创建时间",
`update_by` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' Comment "更新者",
`update_time` DATETIME NULL Comment "更新时间",
`remark` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL Comment "备注",
PRIMARY KEY (`user_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci AUTO_INCREMENT = 3 ROW_FORMAT = Dynamic COMMENT = "用户信息表";
-- sys_user_post DDL
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post` (`user_id` BIGINT(20) NOT NULL Comment "用户ID",
`post_id` BIGINT(20) NOT NULL Comment "岗位ID",
PRIMARY KEY (`user_id`,
`post_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic COMMENT = "用户与岗位关联表";
-- sys_user_role DDL
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (`user_id` BIGINT(20) NOT NULL Comment "用户ID",
`role_id` BIGINT(20) NOT NULL Comment "角色ID",
PRIMARY KEY (`user_id`,
`role_id`)) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic COMMENT = "用户和角色关联表";
-- dm_datasource DML
INSERT INTO `dm_datasource` (`id`,`name`,`db_type`,`host`,`port`,`database`,`username`,`password`,`created_at`,`updated_at`,`create_by`,`is_shared`) VALUES (1,'主数据库','mysql','192.168.56.10',3306,'ry-vue','root','Ahope@123','2026-04-10 12:17:58','2026-04-10 22:06:02','admin',0);
-- dm_model DML
INSERT INTO `dm_model` (`id`,`name`,`description`,`graph_data`,`created_at`,`updated_at`,`create_by`,`is_shared`) VALUES (1,'多表left join','多表left join','{"nodes":[{"id":"node_1775803640267_1","type":"seed","position":{"x":-87.30105456475643,"y":24.686643204565925},"data":{"label":"用户表","tableName":"sys_user","seedId":2}},{"id":"node_1775803655740_2","type":"operator","position":{"x":114.28189797060622,"y":23.742706490749086},"data":{"label":"排序 (SORT)","opType":"sort","operatorId":8,"config":{"sortField":"user_id","sortOrder":"DESC"}}},{"id":"node_1775803708079_4","type":"operator","position":{"x":309.0806677475385,"y":26.325659026111722},"data":{"label":"限制 (LIMIT)","opType":"limit","operatorId":9,"config":{"count":1}}},{"id":"node_1775803738581_5","type":"operator","position":{"x":329.4961336724855,"y":183.47082596299634},"data":{"label":"连接 (JOIN)","opType":"join","operatorId":5,"config":{"joinType":"LEFT JOIN","condition":"t1.user_id = t2.user_id"}}},{"id":"node_1775804015703_7","type":"seed","position":{"x":62.950221854527456,"y":214.73351535018293},"data":{"label":"用户角色表","tableName":"sys_user_role","seedId":4}},{"id":"result_1775804115600","type":"result","position":{"x":541.2818979706062,"y":187.4646748476575},"data":{"label":"结果输出"}}],"edges":[{"id":"vueflow__edge-node_1775803640267_1-node_1775803655740_2","source":"node_1775803640267_1","target":"node_1775803655740_2"},{"id":"vueflow__edge-node_1775803655740_2-node_1775803708079_4","source":"node_1775803655740_2","target":"node_1775803708079_4"},{"id":"vueflow__edge-node_1775803708079_4-node_1775803738581_5","source":"node_1775803708079_4","target":"node_1775803738581_5"},{"id":"vueflow__edge-node_1775804015703_7-node_1775803738581_5","source":"node_1775804015703_7","target":"node_1775803738581_5"},{"id":"vueflow__edge-node_1775803738581_5-result_1775804115600","source":"node_1775803738581_5","target":"result_1775804115600"}]}','2026-04-10 14:56:09','2026-04-10 14:56:09','niangao',0);
-- dm_operator DML
INSERT INTO `dm_operator` (`id`,`name`,`op_type`,`description`,`sql_template`,`is_builtin`,`config_schema`,`created_at`,`create_by`,`is_shared`) VALUES (1,'并集 (UNION)','union','取两个集合的并集（去重）','',1,'{}','2026-04-09 20:59:36','',0),(2,'全并集 (UNION ALL)','union_all','取两个集合的并集（不去重）','',1,'{}','2026-04-09 20:59:36','',0),(3,'交集 (INTERSECT)','intersect','取两个集合的交集','',1,'{}','2026-04-09 20:59:36','',0),(4,'差集 (EXCEPT)','except','取第一个集合减去第二个集合','',1,'{}','2026-04-09 20:59:36','',0),(5,'连接 (JOIN)','join','表连接','',1,'{"joinType":"INNER JOIN","condition":"t1.id = t2.id"}','2026-04-09 20:59:36','',0),(6,'过滤 (FILTER)','filter','条件过滤','',1,'{"condition":"1=1"}','2026-04-09 20:59:36','',0),(7,'分组 (GROUP)','group','分组聚合','',1,'{"groupFields":"","aggExpr":"COUNT(*)"}','2026-04-09 20:59:36','',0),(8,'排序 (SORT)','sort','排序','',1,'{"sortField":"id","sortOrder":"ASC"}','2026-04-09 20:59:36','',0),(9,'限制 (LIMIT)','limit','限制返回行数','',1,'{"count":100}','2026-04-09 20:59:36','',0),(10,'自定义SQL','custom','自定义SQL，用 {input1} 引用输入表','',1,'{"sql":"SELECT * FROM {input1}"}','2026-04-09 20:59:36','',0);
-- dm_published_api DML
INSERT INTO `dm_published_api` (`id`,`name`,`path`,`model_id`,`description`,`params`,`enabled`,`created_at`,`updated_at`,`create_by`,`is_shared`) VALUES (1,'查询用户列表','aaaaaa',1,'','[]',1,'2026-04-10 14:57:20','2026-04-10 14:57:41','niangao',0);
-- dm_seed DML
INSERT INTO `dm_seed` (`id`,`name`,`datasource_id`,`table_name`,`description`,`created_at`,`create_by`,`is_shared`) VALUES (1,'dddd',1,'sys_user','','2026-04-10 12:27:12','admin',0),(2,'用户表',1,'sys_user','eee','2026-04-10 14:47:17','niangao',1),(3,'角色表',1,'sys_role','','2026-04-10 14:50:13','niangao',0),(4,'用户角色表',1,'sys_user_role','','2026-04-10 14:53:30','niangao',0),(5,'ffff',1,'sys_user_post','','2026-04-10 16:22:07','niangao',0);
-- sys_config DML
INSERT INTO `sys_config` (`config_id`,`config_name`,`config_key`,`config_value`,`config_type`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,'主框架页-默认皮肤样式名称','sys.index.skinName','skin-blue','Y','admin','2026-04-09 20:59:10','',NULL,'蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),(2,'用户管理-账号初始密码','sys.user.initPassword','123456','Y','admin','2026-04-09 20:59:10','',NULL,'初始化密码 123456'),(3,'主框架页-侧边栏主题','sys.index.sideTheme','theme-dark','Y','admin','2026-04-09 20:59:10','',NULL,'深色主题theme-dark，浅色主题theme-light'),(4,'账号自助-验证码开关','sys.account.captchaEnabled','false','Y','admin','2026-04-09 20:59:10','',NULL,'是否开启验证码功能（true开启，false关闭）'),(5,'账号自助-是否开启用户注册功能','sys.account.registerUser','false','Y','admin','2026-04-09 20:59:10','',NULL,'是否开启注册用户功能（true开启，false关闭）'),(6,'用户登录-黑名单列表','sys.login.blackIPList','','Y','admin','2026-04-09 20:59:10','',NULL,'设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）'),(7,'用户管理-初始密码修改策略','sys.account.initPasswordModify','1','Y','admin','2026-04-09 20:59:10','',NULL,'0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框'),(8,'用户管理-账号密码更新周期','sys.account.passwordValidateDays','0','Y','admin','2026-04-09 20:59:10','',NULL,'密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
-- sys_dept DML
INSERT INTO `sys_dept` (`dept_id`,`parent_id`,`ancestors`,`dept_name`,`order_num`,`leader`,`phone`,`email`,`status`,`del_flag`,`create_by`,`create_time`,`update_by`,`update_time`) VALUES (100,0,'0','集团总公司',0,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(101,100,'0,100','深圳分公司',1,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(102,100,'0,100','长沙分公司',2,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(103,101,'0,100,101','研发部门',1,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(104,101,'0,100,101','市场部门',2,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(105,101,'0,100,101','测试部门',3,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(106,101,'0,100,101','财务部门',4,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(107,101,'0,100,101','运维部门',5,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(108,102,'0,100,102','市场部门',1,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL),(109,102,'0,100,102','财务部门',2,'年糕','15888888888','niangao@qq.com','0','0','admin','2026-04-09 20:59:10','',NULL);
-- sys_dict_data DML
INSERT INTO `sys_dict_data` (`dict_code`,`dict_sort`,`dict_label`,`dict_value`,`dict_type`,`css_class`,`list_class`,`is_default`,`status`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,1,'男','0','sys_user_sex','','','Y','0','admin','2026-04-09 20:59:10','',NULL,'性别男'),(2,2,'女','1','sys_user_sex','','','N','0','admin','2026-04-09 20:59:10','',NULL,'性别女'),(3,3,'未知','2','sys_user_sex','','','N','0','admin','2026-04-09 20:59:10','',NULL,'性别未知'),(4,1,'显示','0','sys_show_hide','','primary','Y','0','admin','2026-04-09 20:59:10','',NULL,'显示菜单'),(5,2,'隐藏','1','sys_show_hide','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'隐藏菜单'),(6,1,'正常','0','sys_normal_disable','','primary','Y','0','admin','2026-04-09 20:59:10','',NULL,'正常状态'),(7,2,'停用','1','sys_normal_disable','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'停用状态'),(8,1,'正常','0','sys_job_status','','primary','Y','0','admin','2026-04-09 20:59:10','',NULL,'正常状态'),(9,2,'暂停','1','sys_job_status','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'停用状态'),(10,1,'默认','default','sys_job_group','','','Y','0','admin','2026-04-09 20:59:10','',NULL,'默认分组'),(11,2,'数据库','sqlalchemy','sys_job_group','','','N','0','admin','2026-04-09 20:59:10','',NULL,'数据库分组'),(12,3,'redis','redis','sys_job_group','','','N','0','admin','2026-04-09 20:59:10','',NULL,'reids分组'),(13,1,'默认','default','sys_job_executor','','','N','0','admin','2026-04-09 20:59:10','',NULL,'线程池'),(14,2,'进程池','processpool','sys_job_executor','','','N','0','admin','2026-04-09 20:59:10','',NULL,'进程池'),(15,1,'是','Y','sys_yes_no','','primary','Y','0','admin','2026-04-09 20:59:10','',NULL,'系统默认是'),(16,2,'否','N','sys_yes_no','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'系统默认否'),(17,1,'通知','1','sys_notice_type','','warning','Y','0','admin','2026-04-09 20:59:10','',NULL,'通知'),(18,2,'公告','2','sys_notice_type','','success','N','0','admin','2026-04-09 20:59:10','',NULL,'公告'),(19,1,'正常','0','sys_notice_status','','primary','Y','0','admin','2026-04-09 20:59:10','',NULL,'正常状态'),(20,2,'关闭','1','sys_notice_status','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'关闭状态'),(21,99,'其他','0','sys_oper_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'其他操作'),(22,1,'新增','1','sys_oper_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'新增操作'),(23,2,'修改','2','sys_oper_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'修改操作'),(24,3,'删除','3','sys_oper_type','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'删除操作'),(25,4,'授权','4','sys_oper_type','','primary','N','0','admin','2026-04-09 20:59:10','',NULL,'授权操作'),(26,5,'导出','5','sys_oper_type','','warning','N','0','admin','2026-04-09 20:59:10','',NULL,'导出操作'),(27,6,'导入','6','sys_oper_type','','warning','N','0','admin','2026-04-09 20:59:10','',NULL,'导入操作'),(28,7,'强退','7','sys_oper_type','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'强退操作'),(29,8,'生成代码','8','sys_oper_type','','warning','N','0','admin','2026-04-09 20:59:10','',NULL,'生成操作'),(30,9,'清空数据','9','sys_oper_type','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'清空操作'),(31,1,'成功','0','sys_common_status','','primary','N','0','admin','2026-04-09 20:59:10','',NULL,'正常状态'),(32,2,'失败','1','sys_common_status','','danger','N','0','admin','2026-04-09 20:59:10','',NULL,'停用状态'),(33,1,'AIMLAPI','AIMLAPI','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'AIMLAPI'),(34,2,'Anthropic','Anthropic','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Anthropic'),(35,3,'Cerebras','Cerebras','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Cerebras'),(36,4,'CerebrasOpenAI','CerebrasOpenAI','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'CerebrasOpenAI'),(37,5,'Cohere','Cohere','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Cohere'),(38,6,'CometAPI','CometAPI','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'CometAPI'),(39,7,'DashScope','DashScope','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'DashScope'),(40,8,'DeepInfra','DeepInfra','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'DeepInfra'),(41,9,'DeepSeek','DeepSeek','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'DeepSeek'),(42,10,'Fireworks','Fireworks','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Fireworks'),(43,11,'Google','Google','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Google'),(44,12,'Groq','Groq','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Groq'),(45,13,'HuggingFace','HuggingFace','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'HuggingFace'),(46,14,'LangDB','LangDB','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'LangDB'),(47,15,'LiteLLM','LiteLLM','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'LiteLLM'),(48,16,'LiteLLMOpenAI','LiteLLMOpenAI','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'LiteLLMOpenAI'),(49,17,'LlamaCpp','LlamaCpp','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'LlamaCpp'),(50,18,'LMStudio','LMStudio','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'LMStudio'),(51,19,'Meta','Meta','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Meta'),(52,20,'Mistral','Mistral','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Mistral'),(53,21,'N1N','N1N','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'N1N'),(54,22,'Nebius','Nebius','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Nebius'),(55,23,'Nexus','Nexus','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Nexus'),(56,24,'Nvidia','Nvidia','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Nvidia'),(57,25,'Ollama','Ollama','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Ollama'),(58,26,'OpenAI','OpenAI','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'OpenAI'),(59,27,'OpenAIResponses','OpenAIResponses','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'OpenAIResponses'),(60,28,'OpenRouter','OpenRouter','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'OpenRouter'),(61,29,'Perplexity','Perplexity','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Perplexity'),(62,30,'Portkey','Portkey','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Portkey'),(63,31,'Requesty','Requesty','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Requesty'),(64,32,'Sambanova','Sambanova','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Sambanova'),(65,33,'SiliconFlow','SiliconFlow','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'SiliconFlow'),(66,34,'Together','Together','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Together'),(67,35,'Vercel','Vercel','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'Vercel'),(68,36,'VLLM','VLLM','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'VLLM'),(69,37,'xAI','xAI','ai_provider_type','','info','N','0','admin','2026-04-09 20:59:10','',NULL,'xAI');
-- sys_dict_type DML
INSERT INTO `sys_dict_type` (`dict_id`,`dict_name`,`dict_type`,`status`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,'用户性别','sys_user_sex','0','admin','2026-04-09 20:59:10','',NULL,'用户性别列表'),(2,'菜单状态','sys_show_hide','0','admin','2026-04-09 20:59:10','',NULL,'菜单状态列表'),(3,'系统开关','sys_normal_disable','0','admin','2026-04-09 20:59:10','',NULL,'系统开关列表'),(4,'任务状态','sys_job_status','0','admin','2026-04-09 20:59:10','',NULL,'任务状态列表'),(5,'任务分组','sys_job_group','0','admin','2026-04-09 20:59:10','',NULL,'任务分组列表'),(6,'任务执行器','sys_job_executor','0','admin','2026-04-09 20:59:10','',NULL,'任务执行器列表'),(7,'系统是否','sys_yes_no','0','admin','2026-04-09 20:59:10','',NULL,'系统是否列表'),(8,'通知类型','sys_notice_type','0','admin','2026-04-09 20:59:10','',NULL,'通知类型列表'),(9,'通知状态','sys_notice_status','0','admin','2026-04-09 20:59:10','',NULL,'通知状态列表'),(10,'操作类型','sys_oper_type','0','admin','2026-04-09 20:59:10','',NULL,'操作类型列表'),(11,'系统状态','sys_common_status','0','admin','2026-04-09 20:59:10','',NULL,'登录状态列表'),(12,'AI模型提供商','ai_provider_type','0','admin','2026-04-09 20:59:10','',NULL,'AI模型提供商列表');
-- sys_job DML
INSERT INTO `sys_job` (`job_id`,`job_name`,`job_group`,`job_executor`,`invoke_target`,`job_args`,`job_kwargs`,`cron_expression`,`misfire_policy`,`concurrent`,`status`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,'系统默认（无参）','default','default','module_task.scheduler_test.job',NULL,NULL,'0/10 * * * * ?','3','1','1','admin','2026-04-09 20:59:10','',NULL,''),(2,'系统默认（有参）','default','default','module_task.scheduler_test.job','test',NULL,'0/15 * * * * ?','3','1','1','admin','2026-04-09 20:59:10','',NULL,''),(3,'系统默认（多参）','default','default','module_task.scheduler_test.job','new','{"test": 111}','0/20 * * * * ?','3','1','1','admin','2026-04-09 20:59:10','',NULL,'');
-- sys_logininfor DML
INSERT INTO `sys_logininfor` (`info_id`,`user_name`,`ipaddr`,`login_location`,`browser`,`os`,`status`,`msg`,`login_time`) VALUES (1,'admin','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 12:17:10'),(2,'niangao','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 12:18:37'),(3,'admin','127.0.0.1','内网IP','curl 8','Other','0','登录成功','2026-04-10 14:08:24'),(4,'admin','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 14:08:46'),(5,'admin','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 14:09:17'),(6,'niangao','127.0.0.1','内网IP','Chrome 146','Windows 10','1','密码错误','2026-04-10 14:09:39'),(7,'niangao','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 14:09:45'),(8,'admin','127.0.0.1','内网IP','curl 8','Other','0','登录成功','2026-04-10 14:25:30'),(9,'admin','127.0.0.1','内网IP','curl 8','Other','0','登录成功','2026-04-10 14:28:37'),(10,'niangao','127.0.0.1','内网IP','Chrome 146','Windows 10','1','密码错误','2026-04-10 14:34:02'),(11,'niangao','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 14:34:07'),(12,'admin','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 16:23:11'),(13,'admin','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 17:10:52'),(14,'admin','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-10 17:11:10'),(15,'admin','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-13 10:01:02'),(16,'niangao','127.0.0.1','内网IP','Chrome 146','Windows 10','0','登录成功','2026-04-13 10:05:26');
-- sys_menu DML
INSERT INTO `sys_menu` (`menu_id`,`menu_name`,`parent_id`,`order_num`,`path`,`component`,`query`,`route_name`,`is_frame`,`is_cache`,`menu_type`,`visible`,`status`,`perms`,`icon`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,'系统管理',0,1,'system',NULL,'','',1,0,'M','0','0','','system','admin','2026-04-09 20:59:10','',NULL,'系统管理目录'),(2,'系统监控',0,2,'monitor',NULL,'','',1,0,'M','0','0','','monitor','admin','2026-04-09 20:59:10','',NULL,'系统监控目录'),(3,'系统工具',0,3,'tool',NULL,'','',1,0,'M','0','0','','tool','admin','2026-04-09 20:59:10','',NULL,'系统工具目录'),(4,'AI 管理',0,4,'ai',NULL,'','',1,0,'M','0','0','','ai-manage','admin','2026-04-09 20:59:10','',NULL,'AI 管理目录'),(99,'若依官网',0,99,'http://ruoyi.vip',NULL,'','',0,0,'M','0','0','','guide','admin','2026-04-09 20:59:10','',NULL,'若依官网地址'),(100,'用户管理',1,1,'user','system/user/index','','',1,0,'C','0','0','system:user:list','user','admin','2026-04-09 20:59:10','',NULL,'用户管理菜单'),(101,'角色管理',1,2,'role','system/role/index','','',1,0,'C','0','0','system:role:list','peoples','admin','2026-04-09 20:59:10','',NULL,'角色管理菜单'),(102,'菜单管理',1,3,'menu','system/menu/index','','',1,0,'C','0','0','system:menu:list','tree-table','admin','2026-04-09 20:59:10','',NULL,'菜单管理菜单'),(103,'部门管理',1,4,'dept','system/dept/index','','',1,0,'C','0','0','system:dept:list','tree','admin','2026-04-09 20:59:10','',NULL,'部门管理菜单'),(104,'岗位管理',1,5,'post','system/post/index','','',1,0,'C','0','0','system:post:list','post','admin','2026-04-09 20:59:10','',NULL,'岗位管理菜单'),(105,'字典管理',1,6,'dict','system/dict/index','','',1,0,'C','0','0','system:dict:list','dict','admin','2026-04-09 20:59:10','',NULL,'字典管理菜单'),(106,'参数设置',1,7,'config','system/config/index','','',1,0,'C','0','0','system:config:list','edit','admin','2026-04-09 20:59:10','',NULL,'参数设置菜单'),(107,'通知公告',1,8,'notice','system/notice/index','','',1,0,'C','0','0','system:notice:list','message','admin','2026-04-09 20:59:10','',NULL,'通知公告菜单'),(108,'日志管理',1,9,'log','','','',1,0,'M','0','0','','log','admin','2026-04-09 20:59:10','',NULL,'日志管理菜单'),(109,'在线用户',2,1,'online','monitor/online/index','','',1,0,'C','0','0','monitor:online:list','online','admin','2026-04-09 20:59:10','',NULL,'在线用户菜单'),(110,'定时任务',2,2,'job','monitor/job/index','','',1,0,'C','0','0','monitor:job:list','job','admin','2026-04-09 20:59:10','',NULL,'定时任务菜单'),(111,'数据监控',2,3,'druid','monitor/druid/index','','',1,0,'C','0','0','monitor:druid:list','druid','admin','2026-04-09 20:59:10','',NULL,'数据监控菜单'),(112,'服务监控',2,4,'server','monitor/server/index','','',1,0,'C','0','0','monitor:server:list','server','admin','2026-04-09 20:59:10','',NULL,'服务监控菜单'),(113,'缓存监控',2,5,'cache','monitor/cache/index','','',1,0,'C','0','0','monitor:cache:list','redis','admin','2026-04-09 20:59:10','',NULL,'缓存监控菜单'),(114,'缓存列表',2,6,'cacheList','monitor/cache/list','','',1,0,'C','0','0','monitor:cache:list','redis-list','admin','2026-04-09 20:59:10','',NULL,'缓存列表菜单'),(115,'表单构建',3,1,'build','tool/build/index','','',1,0,'C','0','0','tool:build:list','build','admin','2026-04-09 20:59:10','',NULL,'表单构建菜单'),(116,'代码生成',3,2,'gen','tool/gen/index','','',1,0,'C','0','0','tool:gen:list','code','admin','2026-04-09 20:59:10','',NULL,'代码生成菜单'),(117,'系统接口',3,3,'swagger','tool/swagger/index','','',1,0,'C','0','0','tool:swagger:list','swagger','admin','2026-04-09 20:59:10','',NULL,'系统接口菜单'),(118,'模型管理',4,1,'model','ai/model/index','','',1,0,'C','0','0','ai:model:list','ai-model','admin','2026-04-09 20:59:10','',NULL,'模型管理菜单'),(119,'AI 对话',4,2,'chat','ai/chat/index','','',1,0,'C','0','0','ai:chat:list','ai-chat','admin','2026-04-09 20:59:10','',NULL,'AI 对话菜单'),(500,'操作日志',108,1,'operlog','monitor/operlog/index','','',1,0,'C','0','0','monitor:operlog:list','form','admin','2026-04-09 20:59:10','',NULL,'操作日志菜单'),(501,'登录日志',108,2,'logininfor','monitor/logininfor/index','','',1,0,'C','0','0','monitor:logininfor:list','logininfor','admin','2026-04-09 20:59:10','',NULL,'登录日志菜单'),(1000,'用户查询',100,1,'','','','',1,0,'F','0','0','system:user:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1001,'用户新增',100,2,'','','','',1,0,'F','0','0','system:user:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1002,'用户修改',100,3,'','','','',1,0,'F','0','0','system:user:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1003,'用户删除',100,4,'','','','',1,0,'F','0','0','system:user:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1004,'用户导出',100,5,'','','','',1,0,'F','0','0','system:user:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1005,'用户导入',100,6,'','','','',1,0,'F','0','0','system:user:import','#','admin','2026-04-09 20:59:10','',NULL,''),(1006,'重置密码',100,7,'','','','',1,0,'F','0','0','system:user:resetPwd','#','admin','2026-04-09 20:59:10','',NULL,''),(1007,'角色查询',101,1,'','','','',1,0,'F','0','0','system:role:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1008,'角色新增',101,2,'','','','',1,0,'F','0','0','system:role:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1009,'角色修改',101,3,'','','','',1,0,'F','0','0','system:role:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1010,'角色删除',101,4,'','','','',1,0,'F','0','0','system:role:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1011,'角色导出',101,5,'','','','',1,0,'F','0','0','system:role:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1012,'菜单查询',102,1,'','','','',1,0,'F','0','0','system:menu:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1013,'菜单新增',102,2,'','','','',1,0,'F','0','0','system:menu:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1014,'菜单修改',102,3,'','','','',1,0,'F','0','0','system:menu:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1015,'菜单删除',102,4,'','','','',1,0,'F','0','0','system:menu:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1016,'部门查询',103,1,'','','','',1,0,'F','0','0','system:dept:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1017,'部门新增',103,2,'','','','',1,0,'F','0','0','system:dept:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1018,'部门修改',103,3,'','','','',1,0,'F','0','0','system:dept:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1019,'部门删除',103,4,'','','','',1,0,'F','0','0','system:dept:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1020,'岗位查询',104,1,'','','','',1,0,'F','0','0','system:post:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1021,'岗位新增',104,2,'','','','',1,0,'F','0','0','system:post:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1022,'岗位修改',104,3,'','','','',1,0,'F','0','0','system:post:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1023,'岗位删除',104,4,'','','','',1,0,'F','0','0','system:post:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1024,'岗位导出',104,5,'','','','',1,0,'F','0','0','system:post:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1025,'字典查询',105,1,'#','','','',1,0,'F','0','0','system:dict:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1026,'字典新增',105,2,'#','','','',1,0,'F','0','0','system:dict:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1027,'字典修改',105,3,'#','','','',1,0,'F','0','0','system:dict:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1028,'字典删除',105,4,'#','','','',1,0,'F','0','0','system:dict:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1029,'字典导出',105,5,'#','','','',1,0,'F','0','0','system:dict:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1030,'参数查询',106,1,'#','','','',1,0,'F','0','0','system:config:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1031,'参数新增',106,2,'#','','','',1,0,'F','0','0','system:config:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1032,'参数修改',106,3,'#','','','',1,0,'F','0','0','system:config:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1033,'参数删除',106,4,'#','','','',1,0,'F','0','0','system:config:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1034,'参数导出',106,5,'#','','','',1,0,'F','0','0','system:config:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1035,'公告查询',107,1,'#','','','',1,0,'F','0','0','system:notice:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1036,'公告新增',107,2,'#','','','',1,0,'F','0','0','system:notice:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1037,'公告修改',107,3,'#','','','',1,0,'F','0','0','system:notice:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1038,'公告删除',107,4,'#','','','',1,0,'F','0','0','system:notice:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1039,'操作查询',500,1,'#','','','',1,0,'F','0','0','monitor:operlog:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1040,'操作删除',500,2,'#','','','',1,0,'F','0','0','monitor:operlog:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1041,'日志导出',500,3,'#','','','',1,0,'F','0','0','monitor:operlog:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1042,'登录查询',501,1,'#','','','',1,0,'F','0','0','monitor:logininfor:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1043,'登录删除',501,2,'#','','','',1,0,'F','0','0','monitor:logininfor:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1044,'日志导出',501,3,'#','','','',1,0,'F','0','0','monitor:logininfor:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1045,'账户解锁',501,4,'#','','','',1,0,'F','0','0','monitor:logininfor:unlock','#','admin','2026-04-09 20:59:10','',NULL,''),(1046,'在线查询',109,1,'#','','','',1,0,'F','0','0','monitor:online:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1047,'批量强退',109,2,'#','','','',1,0,'F','0','0','monitor:online:batchLogout','#','admin','2026-04-09 20:59:10','',NULL,''),(1048,'单条强退',109,3,'#','','','',1,0,'F','0','0','monitor:online:forceLogout','#','admin','2026-04-09 20:59:10','',NULL,''),(1049,'任务查询',110,1,'#','','','',1,0,'F','0','0','monitor:job:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1050,'任务新增',110,2,'#','','','',1,0,'F','0','0','monitor:job:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1051,'任务修改',110,3,'#','','','',1,0,'F','0','0','monitor:job:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1052,'任务删除',110,4,'#','','','',1,0,'F','0','0','monitor:job:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1053,'状态修改',110,5,'#','','','',1,0,'F','0','0','monitor:job:changeStatus','#','admin','2026-04-09 20:59:10','',NULL,''),(1054,'任务导出',110,6,'#','','','',1,0,'F','0','0','monitor:job:export','#','admin','2026-04-09 20:59:10','',NULL,''),(1055,'生成查询',116,1,'#','','','',1,0,'F','0','0','tool:gen:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1056,'生成修改',116,2,'#','','','',1,0,'F','0','0','tool:gen:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1057,'生成删除',116,3,'#','','','',1,0,'F','0','0','tool:gen:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(1058,'导入代码',116,4,'#','','','',1,0,'F','0','0','tool:gen:import','#','admin','2026-04-09 20:59:10','',NULL,''),(1059,'预览代码',116,5,'#','','','',1,0,'F','0','0','tool:gen:preview','#','admin','2026-04-09 20:59:10','',NULL,''),(1060,'生成代码',116,6,'#','','','',1,0,'F','0','0','tool:gen:code','#','admin','2026-04-09 20:59:10','',NULL,''),(1061,'模型查询',118,1,'#','','','',1,0,'F','0','0','ai:model:query','#','admin','2026-04-09 20:59:10','',NULL,''),(1062,'模型新增',118,2,'#','','','',1,0,'F','0','0','ai:model:add','#','admin','2026-04-09 20:59:10','',NULL,''),(1063,'模型修改',118,3,'#','','','',1,0,'F','0','0','ai:model:edit','#','admin','2026-04-09 20:59:10','',NULL,''),(1064,'模型删除',118,4,'#','','','',1,0,'F','0','0','ai:model:remove','#','admin','2026-04-09 20:59:10','',NULL,''),(2001,'数据建模',0,6,'datamodel',NULL,NULL,'',1,0,'M','0','0','','chart','admin','2026-04-09 21:08:59','',NULL,''),(2002,'建模工作台',2001,1,'workbench','datamodel/workbench',NULL,'',1,0,'C','0','0','datamodel:workbench:view','example','admin','2026-04-09 21:08:59','',NULL,''),(2003,'数据源管理',2001,2,'datasource','datamodel/datasource/index',NULL,'',1,0,'C','0','0','datamodel:datasource:list','server','admin','2026-04-09 21:08:59','',NULL,''),(2004,'数据源查询',2003,1,'',NULL,NULL,'',1,0,'F','0','0','datamodel:datasource:list','#','admin','2026-04-09 21:08:59','',NULL,''),(2005,'数据源新增',2003,2,'',NULL,NULL,'',1,0,'F','0','0','datamodel:datasource:add','#','admin','2026-04-09 21:08:59','',NULL,''),(2006,'数据源修改',2003,3,'',NULL,NULL,'',1,0,'F','0','0','datamodel:datasource:edit','#','admin','2026-04-09 21:08:59','',NULL,''),(2007,'数据源删除',2003,4,'',NULL,NULL,'',1,0,'F','0','0','datamodel:datasource:remove','#','admin','2026-04-09 21:08:59','',NULL,''),(2008,'连接测试',2003,5,'',NULL,NULL,'',1,0,'F','0','0','datamodel:datasource:test','#','admin','2026-04-09 21:08:59','',NULL,''),(2009,'种子管理',2001,3,'seed','datamodel/seed/index',NULL,'',1,0,'C','0','0','datamodel:seed:list','tree','admin','2026-04-09 21:08:59','',NULL,''),(2010,'种子查询',2009,1,'',NULL,NULL,'',1,0,'F','0','0','datamodel:seed:list','#','admin','2026-04-09 21:08:59','',NULL,''),(2011,'种子新增',2009,2,'',NULL,NULL,'',1,0,'F','0','0','datamodel:seed:add','#','admin','2026-04-09 21:08:59','',NULL,''),(2012,'种子修改',2009,3,'',NULL,NULL,'',1,0,'F','0','0','datamodel:seed:edit','#','admin','2026-04-09 21:08:59','',NULL,''),(2013,'种子删除',2009,4,'',NULL,NULL,'',1,0,'F','0','0','datamodel:seed:remove','#','admin','2026-04-09 21:08:59','',NULL,''),(2014,'数据预览',2009,5,'',NULL,NULL,'',1,0,'F','0','0','datamodel:seed:preview','#','admin','2026-04-09 21:08:59','',NULL,''),(2015,'模型管理',2001,4,'model','datamodel/model/index',NULL,'',1,0,'C','0','0','datamodel:model:list','cascader','admin','2026-04-09 21:08:59','',NULL,''),(2016,'模型查询',2015,1,'',NULL,NULL,'',1,0,'F','0','0','datamodel:model:list','#','admin','2026-04-09 21:08:59','',NULL,''),(2017,'模型新增',2015,2,'',NULL,NULL,'',1,0,'F','0','0','datamodel:model:add','#','admin','2026-04-09 21:08:59','',NULL,''),(2018,'模型修改',2015,3,'',NULL,NULL,'',1,0,'F','0','0','datamodel:model:edit','#','admin','2026-04-09 21:08:59','',NULL,''),(2019,'模型删除',2015,4,'',NULL,NULL,'',1,0,'F','0','0','datamodel:model:remove','#','admin','2026-04-09 21:08:59','',NULL,''),(2020,'模型执行',2015,5,'',NULL,NULL,'',1,0,'F','0','0','datamodel:model:execute','#','admin','2026-04-09 21:08:59','',NULL,''),(2021,'API管理',2001,5,'api','datamodel/api/index',NULL,'',1,0,'C','0','0','datamodel:api:list','swagger','admin','2026-04-09 21:08:59','',NULL,''),(2022,'API查询',2021,1,'',NULL,NULL,'',1,0,'F','0','0','datamodel:api:list','#','admin','2026-04-09 21:08:59','',NULL,''),(2023,'API新增',2021,2,'',NULL,NULL,'',1,0,'F','0','0','datamodel:api:add','#','admin','2026-04-09 21:08:59','',NULL,''),(2024,'API修改',2021,3,'',NULL,NULL,'',1,0,'F','0','0','datamodel:api:edit','#','admin','2026-04-09 21:08:59','',NULL,''),(2025,'API删除',2021,4,'',NULL,NULL,'',1,0,'F','0','0','datamodel:api:remove','#','admin','2026-04-09 21:08:59','',NULL,''),(2026,'算子管理',2001,6,'operator','datamodel/operator/index',NULL,'',1,0,'C','0','0','datamodel:operator:list','component','admin','2026-04-10 14:39:39','',NULL,'算子管理菜单'),(2027,'算子查询',2026,1,'',NULL,NULL,'',1,0,'F','0','0','datamodel:operator:list','#','admin','2026-04-10 14:39:39','',NULL,'算子查询按钮'),(2028,'算子新增',2026,2,'',NULL,NULL,'',1,0,'F','0','0','datamodel:operator:add','#','admin','2026-04-10 14:39:39','',NULL,'算子新增按钮'),(2029,'算子修改',2026,3,'',NULL,NULL,'',1,0,'F','0','0','datamodel:operator:edit','#','admin','2026-04-10 14:39:39','',NULL,'算子修改按钮'),(2030,'算子删除',2026,4,'',NULL,NULL,'',1,0,'F','0','0','datamodel:operator:remove','#','admin','2026-04-10 14:39:39','',NULL,'算子删除按钮');
-- sys_notice DML
INSERT INTO `sys_notice` (`notice_id`,`notice_title`,`notice_type`,`notice_content`,`status`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,'温馨提醒：2018-07-01 vfadmin新版本发布啦','2',0xe696b0e78988e69cace58685e5aeb9,'0','admin','2026-04-09 20:59:10','',NULL,'管理员'),(2,'维护通知：2018-07-01 vfadmin系统凌晨维护','1',0xe7bbb4e68aa4e58685e5aeb9,'0','admin','2026-04-09 20:59:10','',NULL,'管理员');
-- sys_oper_log DML
INSERT INTO `sys_oper_log` (`oper_id`,`title`,`business_type`,`method`,`request_method`,`operator_type`,`oper_name`,`dept_name`,`oper_url`,`oper_ip`,`oper_location`,`oper_param`,`json_result`,`status`,`error_msg`,`oper_time`,`cost_time`) VALUES (1,'角色管理',4,'module_admin.controller.role_controller.edit_system_role_datascope()','PUT',1,'admin','研发部门','/dev-api/system/role/dataScope','127.0.0.1','内网IP','{\n  "json_body": {\n    "roleId": 2,\n    "roleName": "普通角色",\n    "roleKey": "common",\n    "roleSort": 2,\n    "dataScope": "1",\n    "menuCheckStrictly": true,\n    "deptCheckStrictly": true,\n    "status": "0",\n    "delFlag": "0",\n    "createBy": "admin",\n    "createTime": "2026-04-09T20:59:10",\n    "updateBy": "",\n    "updateTime": null,\n    "remark": "普通角色",\n    "admin": false,\n    "deptIds": []\n  }\n}','{"code": 200, "msg": "分配成功", "success": true, "time": "2026-04-10T14:31:54.834763"}',0,'','2026-04-10 14:31:55',13),(2,'角色管理',4,'module_admin.controller.role_controller.edit_system_role_datascope()','PUT',1,'admin','研发部门','/dev-api/system/role/dataScope','127.0.0.1','内网IP','{\n  "json_body": {\n    "roleId": 2,\n    "roleName": "普通角色",\n    "roleKey": "common",\n    "roleSort": 2,\n    "dataScope": "2",\n    "menuCheckStrictly": true,\n    "deptCheckStrictly": true,\n    "status": "0",\n    "delFlag": "0",\n    "createBy": "admin",\n    "createTime": "2026-04-09T20:59:10",\n    "updateBy": "admin",\n    "updateTime": "2026-04-10T14:31:55",\n    "remark": "普通角色",\n    "admin": false,\n    "deptIds": [\n      100,\n      101,\n      103,\n      104,\n      105,\n      106,\n      107,\n      102,\n      108,\n      109\n    ]\n  }\n}','{"code": 200, "msg": "分配成功", "success": true, "time": "2026-04-10T14:35:33.028620"}',0,'','2026-04-10 14:35:33',16),(3,'角色管理',2,'module_admin.controller.role_controller.edit_system_role()','PUT',1,'admin','研发部门','/dev-api/system/role','127.0.0.1','内网IP','{\n  "json_body": {\n    "roleId": 2,\n    "roleName": "普通角色",\n    "roleKey": "common",\n    "roleSort": 2,\n    "dataScope": "2",\n    "menuCheckStrictly": true,\n    "deptCheckStrictly": true,\n    "status": "0",\n    "delFlag": "0",\n    "createBy": "admin",\n    "createTime": "2026-04-09T20:59:10",\n    "updateBy": "admin",\n    "updateTime": "2026-04-10T14:35:33",\n    "remark": "普通角色",\n    "admin": false,\n    "menuIds": [\n      1,\n      100,\n      1000,\n      1001,\n      1002,\n      1003,\n      1004,\n      1005,\n      1006,\n      101,\n      1007,\n      1008,\n      1009,\n      1010,\n      1011,\n      102,\n      1012,\n      1013,\n      1014,\n      1015,\n      103,\n      1016,\n      1017,\n      1018,\n      1019,\n      104,\n      1020,\n      1021,\n      1022,\n      1023,\n      1024,\n      105,\n      1025,\n      1026,\n      1027,\n      1028,\n      1029,\n      106,\n      1030,\n      1031,\n      1032,\n      1033,\n      1034,\n      107,\n      1035,\n      1036,\n      1037,\n      1038,\n      108,\n      500,\n      1039,\n      1040,\n      1041,\n      501,\n      1042,\n      1043,\n      1044,\n      1045,\n      2,\n      109,\n      1046,\n      1047,\n      1048,\n      110,\n      1049,\n      1050,\n      1051,\n      1052,\n      1053,\n      1054,\n      111,\n      112,\n      113,\n      114,\n      3,\n      115,\n      116,\n      1055,\n      1056,\n      1057,\n      1058,\n      1059,\n      1060,\n      117,\n      4,\n      118,\n      1061,\n      1062,\n      1063,\n      1064,\n      119,\n      2001,\n      2002,\n      2003,\n      2004,\n      2005,\n      2006,\n      2007,\n      2008,\n      2009,\n      2010,\n      2011,\n      2012,\n      2013,\n      2014,\n      2015,\n      2016,\n      2017,\n      2018,\n      2019,\n      2020,\n      2021,\n      2022,\n      2023,\n      2024,\n      2025,\n      99\n    ]\n  }\n}','{"code": 200, "msg": "更新成功", "success": true, "time": "2026-04-10T14:37:56.219868"}',0,'','2026-04-10 14:37:56',25);
-- sys_post DML
INSERT INTO `sys_post` (`post_id`,`post_code`,`post_name`,`post_sort`,`status`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,'ceo','董事长',1,'0','admin','2026-04-09 20:59:10','',NULL,''),(2,'se','项目经理',2,'0','admin','2026-04-09 20:59:10','',NULL,''),(3,'hr','人力资源',3,'0','admin','2026-04-09 20:59:10','',NULL,''),(4,'user','普通员工',4,'0','admin','2026-04-09 20:59:10','',NULL,'');
-- sys_role DML
INSERT INTO `sys_role` (`role_id`,`role_name`,`role_key`,`role_sort`,`data_scope`,`menu_check_strictly`,`dept_check_strictly`,`status`,`del_flag`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,'超级管理员','admin',1,'1',1,1,'0','0','admin','2026-04-09 20:59:10','',NULL,'超级管理员'),(2,'普通角色','common',2,'2',1,1,'0','0','admin','2026-04-09 20:59:10','admin','2026-04-10 14:37:56','普通角色');
-- sys_role_dept DML
INSERT INTO `sys_role_dept` (`role_id`,`dept_id`) VALUES (2,100),(2,101),(2,102),(2,103),(2,104),(2,105),(2,106),(2,107),(2,108),(2,109);
-- sys_role_menu DML
INSERT INTO `sys_role_menu` (`role_id`,`menu_id`) VALUES (1,2001),(1,2002),(1,2003),(1,2004),(1,2005),(1,2006),(1,2007),(1,2008),(1,2009),(1,2010),(1,2011),(1,2012),(1,2013),(1,2014),(1,2015),(1,2016),(1,2017),(1,2018),(1,2019),(1,2020),(1,2021),(1,2022),(1,2023),(1,2024),(1,2025),(2,1),(2,2),(2,3),(2,4),(2,99),(2,100),(2,101),(2,102),(2,103),(2,104),(2,105),(2,106),(2,107),(2,108),(2,109),(2,110),(2,111),(2,112),(2,113),(2,114),(2,115),(2,116),(2,117),(2,118),(2,119),(2,500),(2,501),(2,1000),(2,1001),(2,1002),(2,1003),(2,1004),(2,1005),(2,1006),(2,1007),(2,1008),(2,1009),(2,1010),(2,1011),(2,1012),(2,1013),(2,1014),(2,1015),(2,1016),(2,1017),(2,1018),(2,1019),(2,1020),(2,1021),(2,1022),(2,1023),(2,1024),(2,1025),(2,1026),(2,1027),(2,1028),(2,1029),(2,1030),(2,1031),(2,1032),(2,1033),(2,1034),(2,1035),(2,1036),(2,1037),(2,1038),(2,1039),(2,1040),(2,1041),(2,1042),(2,1043),(2,1044),(2,1045),(2,1046),(2,1047),(2,1048),(2,1049),(2,1050),(2,1051),(2,1052),(2,1053),(2,1054),(2,1055),(2,1056),(2,1057),(2,1058),(2,1059),(2,1060),(2,1061),(2,1062),(2,1063),(2,1064),(2,2001),(2,2002),(2,2003),(2,2004),(2,2005),(2,2006),(2,2007),(2,2008),(2,2009),(2,2010),(2,2011),(2,2012),(2,2013),(2,2014),(2,2015),(2,2016),(2,2017),(2,2018),(2,2019),(2,2020),(2,2021),(2,2022),(2,2023),(2,2024),(2,2025),(2,2026),(2,2027),(2,2028),(2,2029),(2,2030);
-- sys_user DML
INSERT INTO `sys_user` (`user_id`,`dept_id`,`user_name`,`nick_name`,`user_type`,`email`,`phonenumber`,`sex`,`avatar`,`password`,`status`,`del_flag`,`login_ip`,`login_date`,`pwd_update_date`,`create_by`,`create_time`,`update_by`,`update_time`,`remark`) VALUES (1,103,'admin','超级管理员','00','niangao@163.com','15888888888','1','','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','0','0','127.0.0.1','2026-04-13 10:01:02','2026-04-09 20:59:10','admin','2026-04-09 20:59:10','',NULL,'管理员'),(2,105,'niangao','年糕','00','niangao@qq.com','15666666666','1','','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','0','0','127.0.0.1','2026-04-13 10:05:26','2026-04-09 20:59:10','admin','2026-04-09 20:59:10','',NULL,'测试员');
-- sys_user_post DML
INSERT INTO `sys_user_post` (`user_id`,`post_id`) VALUES (1,1),(2,2);
-- sys_user_role DML
INSERT INTO `sys_user_role` (`user_id`,`role_id`) VALUES (1,1),(2,2);
SET FOREIGN_KEY_CHECKS = 1;
