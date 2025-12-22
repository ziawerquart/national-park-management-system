-- 执法设备表（设备状态用ENUM限定值）
CREATE TABLE LawDevice (
    device_id VARCHAR(32) NOT NULL,
    device_status ENUM('正常', '故障'), -- 替代CHECK，直接限定值
    device_type VARCHAR(50),
    device_model VARCHAR(50),
    purchase_date DATE,
    PRIMARY KEY (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 执法人员表
CREATE TABLE LawEnforcementOfficer (
    law_id VARCHAR(32) NOT NULL,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    authority VARCHAR(50),
    contact VARCHAR(30),
    device_id VARCHAR(32),
    PRIMARY KEY (law_id),
    FOREIGN KEY (device_id) REFERENCES LawDevice(device_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 视频监控点表
CREATE TABLE VideoMonitorPoint (
    monitor_id VARCHAR(32) NOT NULL,
    region_id VARCHAR(32),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    monitor_range VARCHAR(100),
    device_id VARCHAR(32),
    storage_cycle INT,
    PRIMARY KEY (monitor_id),
    FOREIGN KEY (device_id) REFERENCES LawDevice(device_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 非法行为记录表（处理状态用ENUM限定值）
CREATE TABLE IllegalBehaviorRecord (
    record_id VARCHAR(32) NOT NULL,
    behavior_type VARCHAR(20),
    occur_time DATETIME,
    region_id VARCHAR(32),
    evidence_path VARCHAR(200),
    process_status ENUM('未处理', '处理中', '已结案'), -- 替代CHECK
    law_id VARCHAR(32),
    process_result VARCHAR(100),
    punishment_basis VARCHAR(100),
    monitor_id VARCHAR(32),
    PRIMARY KEY (record_id),
    FOREIGN KEY (law_id) REFERENCES LawEnforcementOfficer(law_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (monitor_id) REFERENCES VideoMonitorPoint(monitor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 执法调度表（调度状态用ENUM限定值）
CREATE TABLE LawEnforcementDispatch (
    dispatch_id VARCHAR(32) NOT NULL,
    record_id VARCHAR(32),
    law_id VARCHAR(32),
    dispatch_time DATETIME,
    response_time DATETIME,
    finish_time DATETIME,
    dispatch_status ENUM('待响应', '已派单', '已完成'), -- 替代CHECK
    PRIMARY KEY (dispatch_id),
    FOREIGN KEY (record_id) REFERENCES IllegalBehaviorRecord(record_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (law_id) REFERENCES LawEnforcementOfficer(law_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;