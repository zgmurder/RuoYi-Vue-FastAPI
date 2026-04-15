-- =============================================
-- 数据建模模块 - 菜单 & 权限 SQL
-- 适用于 RuoYi-Vue3-FastAPI
-- =============================================

-- 1. 顶级菜单: 数据建模
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('数据建模', 0, 10, 'datamodel', 'datamodel/index', 1, 0, 'C', '0', '0', 'datamodel:view', 'chart', 'admin', NOW(), '', NULL, '数据建模工作台');

-- 获取刚插入的菜单ID (假设为变量 @parentId，手动执行时请替换为实际ID)
-- 以下为按钮权限，parent_id 需要设置为上面菜单的ID

-- 2. 数据源相关按钮权限
-- INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
-- VALUES ('数据源查询', @parentId, 1, '', '', 1, 0, 'F', '0', '0', 'datamodel:datasource:list', '#', 'admin', NOW());
-- VALUES ('数据源新增', @parentId, 2, '', '', 1, 0, 'F', '0', '0', 'datamodel:datasource:add', '#', 'admin', NOW());
-- VALUES ('数据源修改', @parentId, 3, '', '', 1, 0, 'F', '0', '0', 'datamodel:datasource:edit', '#', 'admin', NOW());
-- VALUES ('数据源删除', @parentId, 4, '', '', 1, 0, 'F', '0', '0', 'datamodel:datasource:remove', '#', 'admin', NOW());

-- 注意: 实际使用时，建议通过 RuoYi 后台的「菜单管理」UI 来创建菜单，更加方便。
-- 只需要创建一个 "数据建模" 菜单:
--   菜单名称: 数据建模
--   路由地址: datamodel
--   组件路径: datamodel/index
--   菜单类型: 菜单(C)
--   菜单图标: chart
--   权限标识: datamodel:view


-- =============================================
-- 数据建模模块 - 数据表 DDL (MySQL)
-- =============================================

CREATE TABLE IF NOT EXISTS `dm_datasource` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '数据源ID',
  `name` VARCHAR(100) NOT NULL UNIQUE COMMENT '数据源名称',
  `db_type` VARCHAR(50) NOT NULL COMMENT '数据库类型',
  `host` VARCHAR(255) DEFAULT '' COMMENT '主机地址',
  `port` INT DEFAULT 0 COMMENT '端口',
  `database` VARCHAR(255) NOT NULL COMMENT '数据库名',
  `username` VARCHAR(100) DEFAULT '' COMMENT '用户名',
  `password` VARCHAR(255) DEFAULT '' COMMENT '密码',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据建模-数据源';

CREATE TABLE IF NOT EXISTS `dm_seed` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '种子ID',
  `name` VARCHAR(100) NOT NULL COMMENT '种子名称',
  `datasource_id` INT NOT NULL COMMENT '数据源ID',
  `table_name` VARCHAR(255) NOT NULL COMMENT '表名',
  `description` TEXT COMMENT '描述',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据建模-种子';

CREATE TABLE IF NOT EXISTS `dm_operator` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '算子ID',
  `name` VARCHAR(100) NOT NULL COMMENT '算子名称',
  `op_type` VARCHAR(50) NOT NULL COMMENT '算子类型',
  `description` TEXT COMMENT '描述',
  `sql_template` TEXT COMMENT 'SQL模板',
  `is_builtin` TINYINT(1) DEFAULT 0 COMMENT '是否内置',
  `config_schema` TEXT COMMENT '配置schema',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据建模-算子';

CREATE TABLE IF NOT EXISTS `dm_model` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '模型ID',
  `name` VARCHAR(100) NOT NULL COMMENT '模型名称',
  `description` TEXT COMMENT '描述',
  `graph_data` MEDIUMTEXT COMMENT '图数据JSON',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据建模-模型';

CREATE TABLE IF NOT EXISTS `dm_published_api` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'API ID',
  `name` VARCHAR(100) NOT NULL COMMENT 'API名称',
  `path` VARCHAR(255) NOT NULL UNIQUE COMMENT '路径',
  `model_id` INT NOT NULL COMMENT '模型ID',
  `description` TEXT COMMENT '描述',
  `params` TEXT COMMENT '参数定义JSON',
  `enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据建模-已发布API';
