-- New API 开发环境数据库初始化脚本
-- 此脚本会在 MySQL 容器启动时自动执行

-- 设置字符集和排序规则
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `new-api` 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `new-api`;

-- 创建开发用户（如果不存在）
CREATE USER IF NOT EXISTS 'newapi'@'%' IDENTIFIED BY 'newapi123';
GRANT ALL PRIVILEGES ON `new-api`.* TO 'newapi'@'%';

-- 创建本地开发用户
CREATE USER IF NOT EXISTS 'newapi'@'localhost' IDENTIFIED BY 'newapi123';
GRANT ALL PRIVILEGES ON `new-api`.* TO 'newapi'@'localhost';

-- 刷新权限
FLUSH PRIVILEGES;

-- 设置时区
SET time_zone = '+08:00';

-- 创建开发环境的一些基础配置（可选）
-- 注意：实际的表结构会由 Go 应用的 GORM 自动创建和迁移

-- 插入一些开发环境的初始配置数据（如果需要）
-- 这些数据会在应用启动后被 GORM 迁移覆盖，这里仅作为参考

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- 显示创建结果
SELECT 'Database initialization completed successfully!' as status;
