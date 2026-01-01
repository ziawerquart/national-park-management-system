SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET collation_connection = 'utf8mb4_0900_ai_ci';
-- 创建数据库
CREATE DATABASE IF NOT EXISTS national_park_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- 使用该数据库
USE national_park_db;
/* =====================================================
   业务线一：Shared / Global（全局基础数据）
   说明：
   - 存放系统级共享基础信息
   - 为各业务模块提供统一主数据支撑
   - 不直接承载具体业务过程数据
   涉及表：
   - Region
   - User
   - MonitoringDevice
   ===================================================== */
CREATE TABLE Region (
    region_id   VARCHAR(64) NOT NULL,
    region_name VARCHAR(128),
    region_type VARCHAR(32),
    PRIMARY KEY (region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE User (
    user_id   VARCHAR(64) NOT NULL,
    user_name VARCHAR(128),
    role      VARCHAR(32),
    PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE MonitoringDevice (
    device_id VARCHAR(64) NOT NULL,
    device_type VARCHAR(32),
    install_time DATETIME,
    calibration_cycle INT,
    run_status ENUM('normal','fault','offline'), -- 原“正常/故障/离线”
    communication_protocol VARCHAR(64),
    region_id VARCHAR(64),
    PRIMARY KEY (device_id),
    CONSTRAINT fk_device_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* =====================================================
   业务线二：Biodiversity Monitoring（生物多样性监测）
   说明：
   - 用于管理物种、栖息地及生物监测记录
   - 支撑物种分布分析与生态保护决策
   - 以“物种—栖息地—监测记录”为核心数据链路
   涉及表：
   - Species
   - Habitat
   - HabitatPrimarySpecies
   - MonitoringRecord
   ===================================================== */

CREATE TABLE Habitat (
    habitat_id VARCHAR(64) NOT NULL,
    area_name VARCHAR(128),
    ecological_type VARCHAR(32),
    area_size DECIMAL(10,2),
    core_protection_area VARCHAR(255),
    environment_suitability_score DECIMAL(5,2),
    region_id VARCHAR(64),
    PRIMARY KEY (habitat_id),
    CONSTRAINT fk_habitat_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Species (
    species_id VARCHAR(64) NOT NULL,
    species_name_cn VARCHAR(128),
    species_name_latin VARCHAR(128),
    kingdom VARCHAR(32),
    phylum VARCHAR(32),
    tax_class VARCHAR(32),
    tax_order VARCHAR(32),
    family VARCHAR(32),
    genus VARCHAR(32),
    species VARCHAR(32),
    protection_level ENUM('national_first','national_second','none'), -- 原“国家一级/国家二级/无”
    living_habits TEXT,
    distribution_description VARCHAR(255),
    habitat_id VARCHAR(64),
    PRIMARY KEY (species_id),
    CONSTRAINT fk_species_habitat
        FOREIGN KEY (habitat_id)
        REFERENCES Habitat(habitat_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE HabitatPrimarySpecies (
    habitat_id VARCHAR(64) NOT NULL,
    species_id VARCHAR(64) NOT NULL,
    is_primary BOOLEAN,
    PRIMARY KEY (habitat_id, species_id),
    CONSTRAINT fk_hps_habitat
        FOREIGN KEY (habitat_id)
        REFERENCES Habitat(habitat_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_hps_species
        FOREIGN KEY (species_id)
        REFERENCES Species(species_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE MonitoringRecord (
    record_id VARCHAR(64) NOT NULL,
    species_id VARCHAR(64),
    device_id VARCHAR(64),
    monitoring_time DATETIME,
    longitude DECIMAL(10,6),
    latitude DECIMAL(10,6),
    monitoring_method ENUM('infrared_camera','manual_check','drone'), -- 原“红外相机/人工巡查/无人机”
    image_path VARCHAR(512),
    count_number INT,
    behavior_description VARCHAR(255),
    recorder_id VARCHAR(64),
    status ENUM('valid','to_verify'), -- 原“有效/待核实”
    PRIMARY KEY (record_id),
    CONSTRAINT fk_mr_species
        FOREIGN KEY (species_id)
        REFERENCES Species(species_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_mr_device
        FOREIGN KEY (device_id)
        REFERENCES MonitoringDevice(device_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_mr_user
        FOREIGN KEY (recorder_id)
        REFERENCES User(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* =====================================================
   业务线三：Environmental Monitoring（生态环境监测）
   说明：
   - 管理环境监测指标及采集数据
   - 支撑空气、水质、土壤等环境要素监测
   - 提供异常识别与告警基础数据
   涉及表：
   - MonitoringIndicator
   - EnvironmentalData
   - CalibrationRecord
   - Alert
   ===================================================== */

CREATE TABLE MonitoringIndicator (
    indicator_id VARCHAR(64) NOT NULL,
    indicator_name VARCHAR(128),
    unit VARCHAR(32),
    upper_limit DECIMAL(10,2),
    lower_limit DECIMAL(10,2),
    monitor_frequency ENUM('hour','day','week'), -- 原“小时/日/周”
    PRIMARY KEY (indicator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE EnvironmentalData (
    data_id VARCHAR(64) NOT NULL,
    indicator_id VARCHAR(64),
    device_id VARCHAR(64),
    region_id VARCHAR(64),
    collect_time DATETIME,
    monitor_value DECIMAL(10,2),
    data_quality ENUM('excellent','good','medium','poor'), -- 原“优/良/中/差”
    is_abnormal BOOLEAN,
    PRIMARY KEY (data_id),
    CONSTRAINT fk_ed_indicator
        FOREIGN KEY (indicator_id)
        REFERENCES MonitoringIndicator(indicator_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_ed_device
        FOREIGN KEY (device_id)
        REFERENCES MonitoringDevice(device_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_ed_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE CalibrationRecord (
    record_id VARCHAR(64) NOT NULL,
    device_id VARCHAR(64),
    calibration_time DATETIME,
    technician_id VARCHAR(64),
    remark VARCHAR(255),
    PRIMARY KEY (record_id),
    CONSTRAINT fk_cr_device
        FOREIGN KEY (device_id)
        REFERENCES MonitoringDevice(device_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_cr_user
        FOREIGN KEY (technician_id)
        REFERENCES User(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Alert (
    alert_id VARCHAR(64) NOT NULL,
    data_id VARCHAR(64),
    alert_time DATETIME,
    alert_level VARCHAR(32),
    alert_status VARCHAR(32),
    PRIMARY KEY (alert_id),
    CONSTRAINT fk_alert_data
        FOREIGN KEY (data_id)
        REFERENCES EnvironmentalData(data_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* =====================================================
   业务线四：Visitor Management（游客管理）
   说明：
   - 管理游客基本信息与预约记录
   - 记录游客轨迹，支持行为分析
   - 结合流量控制保障景区承载能力
   涉及表：
   - Visitor
   - Reservation
   - VisitorTrajectory
   - FlowControl
   ===================================================== */

CREATE TABLE Visitor (
    visitor_id VARCHAR(64) NOT NULL,
    visitor_name VARCHAR(128),
    id_number VARCHAR(64) UNIQUE,
    contact_number VARCHAR(32),
    entry_time DATE,
    exit_time DATE,
    entry_method ENUM('online','onsite'), -- 原“线上预约/现场购票”
    PRIMARY KEY (visitor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Reservation (
    reservation_id VARCHAR(64) NOT NULL,
    visitor_id VARCHAR(64),
    reservation_date DATE,
    entry_time_slot VARCHAR(32),
    group_size INT,
    reservation_status ENUM('confirmed','cancelled','completed'), -- 原“已确认/已取消/已完成”
    ticket_amount DECIMAL(10,2),
    payment_status VARCHAR(32),
    PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_visitor
        FOREIGN KEY (visitor_id)
        REFERENCES Visitor(visitor_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE VisitorTrajectory (
    trajectory_id VARCHAR(64) NOT NULL,
    visitor_id VARCHAR(64),
    location_time DATETIME,
    longitude DECIMAL(10,6),
    latitude DECIMAL(10,6),
    region_id VARCHAR(64),
    is_out_of_route BOOLEAN,
    PRIMARY KEY (trajectory_id),
    CONSTRAINT fk_vt_visitor
        FOREIGN KEY (visitor_id)
        REFERENCES Visitor(visitor_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_vt_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE FlowControl (
    region_id VARCHAR(64) NOT NULL,
    daily_capacity INT,
    current_visitor_count INT,
    warning_threshold INT,
    flow_status ENUM('normal','warning','restricted'), -- 原“正常/预警/限流”
    PRIMARY KEY (region_id),
    CONSTRAINT fk_fc_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* =====================================================
   业务线五：Law Enforcement（执法监管）
   说明：
   - 管理执法人员与执法设备
   - 记录违规行为与处理过程
   - 支撑执法调度与案件闭环管理
   涉及表：
   - LawEnforcementOfficer
   - VideoMonitorPoint
   - IllegalBehaviorRecord
   - LawEnforcementDispatch
   ===================================================== */

CREATE TABLE LawEnforcementOfficer (
    law_id VARCHAR(64) NOT NULL,
    name VARCHAR(128),
    department VARCHAR(64),
    authority VARCHAR(64),
    contact VARCHAR(32),
    device_id VARCHAR(64),
    user_id VARCHAR(64),
    PRIMARY KEY (law_id),
    CONSTRAINT fk_le_device
        FOREIGN KEY (device_id)
        REFERENCES MonitoringDevice(device_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_le_user
        FOREIGN KEY (user_id)
        REFERENCES User(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE VideoMonitorPoint (
    monitor_id VARCHAR(64) NOT NULL,
    region_id VARCHAR(64),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    monitor_range VARCHAR(128),
    device_status VARCHAR(32),
    storage_cycle INT,
    PRIMARY KEY (monitor_id),
    CONSTRAINT fk_vmp_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IllegalBehaviorRecord (
    record_id VARCHAR(64) NOT NULL,
    behavior_type VARCHAR(128),
    occur_time DATETIME,
    region_id VARCHAR(64),
    monitor_id VARCHAR(64),
    evidence_path VARCHAR(512),
    process_status ENUM('unprocessed','processing','closed'), -- 原“未处理/处理中/已结案”
    law_id VARCHAR(64),
    process_result VARCHAR(255),
    punishment_basis VARCHAR(128),
    PRIMARY KEY (record_id),
    CONSTRAINT fk_ibr_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_ibr_monitor
        FOREIGN KEY (monitor_id)
        REFERENCES VideoMonitorPoint(monitor_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_ibr_law
        FOREIGN KEY (law_id)
        REFERENCES LawEnforcementOfficer(law_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE LawEnforcementDispatch (
    dispatch_id VARCHAR(64) NOT NULL,
    record_id VARCHAR(64),
    law_id VARCHAR(64),
    dispatch_time DATETIME,
    response_time DATETIME,
    finish_time DATETIME,
    dispatch_status ENUM('pending','dispatched','completed'), -- 原“待响应/已派单/已完成”
    PRIMARY KEY (dispatch_id),
    CONSTRAINT fk_led_record
        FOREIGN KEY (record_id)
        REFERENCES IllegalBehaviorRecord(record_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_led_law
        FOREIGN KEY (law_id)
        REFERENCES LawEnforcementOfficer(law_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* =====================================================
   业务线六：Research Support（科研支撑）
   说明：
   - 管理科研项目全生命周期
   - 记录科研数据采集与验证过程
   - 存储科研成果并控制共享权限
   涉及表：
   - ResearchProject
   - ResearchDataRecord
   - ResearchAchievement
   ===================================================== */

CREATE TABLE ResearchProject (
    project_id VARCHAR(64) NOT NULL,
    project_name VARCHAR(128) UNIQUE,
    leader_id VARCHAR(64),
    apply_organization VARCHAR(128),
    approval_date DATE,
    completion_date DATE,
    project_status ENUM('ongoing','completed','paused'), -- 原“在研/已结题/暂停”
    research_field VARCHAR(128),
    description VARCHAR(255),
    PRIMARY KEY (project_id),
    CONSTRAINT fk_rp_leader
        FOREIGN KEY (leader_id)
        REFERENCES User(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ResearchDataRecord (
    collection_id VARCHAR(64) NOT NULL,
    project_id VARCHAR(64),
    collector_id VARCHAR(64),
    collection_time DATETIME,
    region_id VARCHAR(64),
    collection_content VARCHAR(255),
    data_source ENUM('field','system'), -- 原“实地采集/系统调用”
    sample_id VARCHAR(64),
    monitoring_data_id VARCHAR(64),
    data_file_path VARCHAR(512),
    remarks VARCHAR(255),
    is_verified BOOLEAN,
    verified_by VARCHAR(64),
    verified_at DATETIME,
    PRIMARY KEY (collection_id),
    CONSTRAINT fk_rdr_project
        FOREIGN KEY (project_id)
        REFERENCES ResearchProject(project_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_rdr_collector
        FOREIGN KEY (collector_id)
        REFERENCES User(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_rdr_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_rdr_verifier
        FOREIGN KEY (verified_by)
        REFERENCES User(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ResearchAchievement (
    achievement_id VARCHAR(64) NOT NULL,
    project_id VARCHAR(64),
    achievement_type VARCHAR(32),
    achievement_name VARCHAR(128),
    submit_time DATE,
    file_path VARCHAR(512),
    share_permission ENUM('public','internal','confidential'), -- 原“公开/内部共享/保密”
    PRIMARY KEY (achievement_id),
    CONSTRAINT fk_ra_project
        FOREIGN KEY (project_id)
        REFERENCES ResearchProject(project_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
