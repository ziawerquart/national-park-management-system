-- 游客管理系统数据库建表脚本
-- 适用MySQL 8.0.43，字符集utf8mb4

-- ==============================================
-- 1. 创建数据库（不存在则创建）
-- ==============================================
CREATE DATABASE IF NOT EXISTS visitor_management_system
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

-- 切换到目标数据库
USE visitor_management_system;

-- ==============================================
-- 2. 删除旧表（按依赖顺序，避免外键约束报错）
-- ==============================================
DROP TABLE IF EXISTS VisitorTrajectory;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Visitor;
DROP TABLE IF EXISTS FlowControl;

-- ==============================================
-- 3. 创建新表（按外键依赖顺序）
-- ==============================================
-- 3.1 游客信息表（Visitor）- 无外键依赖
CREATE TABLE IF NOT EXISTS Visitor (
    visitor_id VARCHAR(64) NOT NULL COMMENT '游客 ID',
    visitor_name VARCHAR(128) COMMENT '游客姓名',
    id_number VARCHAR(64) COMMENT '身份证号',
    contact_number VARCHAR(32) COMMENT '联系电话',
    entry_time DATE COMMENT '入园时间',
    exit_time DATE COMMENT '离园时间',
    entry_method VARCHAR(32) COMMENT '入园方式',
    PRIMARY KEY (visitor_id),
    UNIQUE KEY uk_id_number (id_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='游客信息表';

-- 3.2 流量控制表（FlowControl）- 无外键依赖（供轨迹表关联）
CREATE TABLE IF NOT EXISTS FlowControl (
    region_id VARCHAR(64) NOT NULL COMMENT '区域 ID',
    daily_capacity INT COMMENT '日承载量',
    current_visitor_count INT COMMENT '当前游客数',
    warning_threshold INT COMMENT '预警阈值',
    flow_status VARCHAR(32) COMMENT '流量状态',
    PRIMARY KEY (region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流量控制表';

-- 3.3 预约信息表（Reservation）- 依赖Visitor表
CREATE TABLE IF NOT EXISTS Reservation (
    reservation_id VARCHAR(64) NOT NULL COMMENT '预约 ID',
    visitor_id VARCHAR(64) COMMENT '游客 ID',
    reservation_date DATE COMMENT '预约日期',
    entry_time_slot VARCHAR(32) COMMENT '入园时段',
    group_size INT COMMENT '同行人数',
    reservation_status VARCHAR(32) COMMENT '预约状态',
    ticket_amount DECIMAL(10,2) COMMENT '门票金额',
    payment_status VARCHAR(32) COMMENT '支付状态',
    PRIMARY KEY (reservation_id),
    KEY fk_reservation_visitor (visitor_id),
    CONSTRAINT fk_reservation_visitor FOREIGN KEY (visitor_id) REFERENCES Visitor(visitor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约信息表';

-- 3.4 游客轨迹表（VisitorTrajectory）- 依赖Visitor+FlowControl表
CREATE TABLE IF NOT EXISTS VisitorTrajectory (
    trajectory_id VARCHAR(64) NOT NULL COMMENT '轨迹 ID',
    visitor_id VARCHAR(64) COMMENT '游客 ID',
    location_time DATETIME COMMENT '定位时间',
    longitude DECIMAL(10,6) COMMENT '经度',
    latitude DECIMAL(10,6) COMMENT '纬度',
    region_id VARCHAR(64) COMMENT '所属区域 ID',
    is_out_of_route BOOLEAN COMMENT '是否偏离路线',
    PRIMARY KEY (trajectory_id),
    KEY fk_trajectory_visitor (visitor_id),
    KEY fk_trajectory_region (region_id),
    CONSTRAINT fk_trajectory_visitor FOREIGN KEY (visitor_id) REFERENCES Visitor(visitor_id),
    CONSTRAINT fk_trajectory_region FOREIGN KEY (region_id) REFERENCES FlowControl(region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='游客轨迹表';

-- 脚本执行完成提示
SELECT '✅ 游客管理系统数据库及表创建完成！' AS '执行结果';