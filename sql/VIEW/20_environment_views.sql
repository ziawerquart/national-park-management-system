/* =====================================================
   视图名称：v_env_realtime_monitoring
   业务线  ：生态环境监测（Environmental Monitoring）
   视图用途：
   - 提供环境监测数据的实时综合查询视图
   - 关联监测指标、监测设备及区域信息
   - 用于监测中心实时监控与异常初筛
   主要使用角色：
   - 监测中心运维人员
   - 系统运行维护人员
   ===================================================== */
CREATE VIEW v_env_realtime_monitoring AS
SELECT
    ed.data_id,                 -- 环境数据唯一标识
    ed.collect_time,             -- 数据采集时间
    r.region_id,                 -- 区域编号
    r.region_name,               -- 区域名称
    mi.indicator_id,             -- 监测指标编号
    mi.indicator_name,           -- 监测指标名称
    mi.unit,                     -- 指标计量单位
    ed.monitor_value,            -- 实际监测值
    mi.upper_limit,              -- 指标上限
    mi.lower_limit,              -- 指标下限
    ed.is_abnormal,              -- 是否异常标识
    ed.data_quality,             -- 数据质量等级
    md.device_id,                -- 监测设备编号
    md.device_type,              -- 设备类型
    md.run_status                -- 设备运行状态
FROM EnvironmentalData ed
LEFT JOIN MonitoringIndicator mi ON ed.indicator_id = mi.indicator_id
LEFT JOIN MonitoringDevice md ON ed.device_id = md.device_id
LEFT JOIN Region r ON ed.region_id = r.region_id;
/* =====================================================
   视图名称：v_env_indicator_analysis
   业务线  ：生态环境监测（Environmental Monitoring）
   视图用途：
   - 从指标与区域维度对环境数据进行统计分析
   - 提供样本数量、均值、最大值、最小值
   - 用于趋势分析、阶段评估与科研分析
   主要使用角色：
   - 环境分析员
   - 科研人员
   ===================================================== */
CREATE VIEW v_env_indicator_analysis AS
SELECT
    mi.indicator_id,             -- 监测指标编号
    mi.indicator_name,           -- 监测指标名称
    mi.unit,                     -- 计量单位
    r.region_id,                 -- 区域编号
    r.region_name,               -- 区域名称
    COUNT(ed.data_id) AS sample_count, -- 样本数量
    AVG(ed.monitor_value) AS avg_value, -- 平均监测值
    MAX(ed.monitor_value) AS max_value, -- 最大监测值
    MIN(ed.monitor_value) AS min_value  -- 最小监测值
FROM EnvironmentalData ed
JOIN MonitoringIndicator mi ON ed.indicator_id = mi.indicator_id
JOIN Region r ON ed.region_id = r.region_id
GROUP BY
    mi.indicator_id,
    mi.indicator_name,
    mi.unit,
    r.region_id,
    r.region_name;
/* =====================================================
   视图名称：v_env_device_operation
   业务线  ：生态环境监测（Environmental Monitoring）
   视图用途：
   - 统一查看环境监测设备运行状态
   - 关联设备所属区域及最近校准时间
   - 支撑设备巡检、维护与运维管理
   主要使用角色：
   - 设备运维工程师
   - 技术保障人员
   ===================================================== */
CREATE VIEW v_env_device_operation AS
SELECT
    md.device_id,                -- 设备编号
    md.device_type,              -- 设备类型
    md.run_status,               -- 当前运行状态
    md.install_time,             -- 安装时间
    md.calibration_cycle,        -- 校准周期（天）
    r.region_id,                 -- 所属区域编号
    r.region_name,               -- 所属区域名称
    MAX(cr.calibration_time) AS last_calibration_time -- 最近一次校准时间
FROM MonitoringDevice md
LEFT JOIN CalibrationRecord cr ON md.device_id = cr.device_id
LEFT JOIN Region r ON md.region_id = r.region_id
GROUP BY
    md.device_id,
    md.device_type,
    md.run_status,
    md.install_time,
    md.calibration_cycle,
    r.region_id,
    r.region_name;
/* =====================================================
   视图名称：v_env_alert_management
   业务线  ：生态环境监测（Environmental Monitoring）
   视图用途：
   - 汇总环境异常数据及告警信息
   - 关联异常指标、设备及区域
   - 为应急响应与管理决策提供数据支持
   主要使用角色：
   - 管理人员
   - 应急指挥与调度人员
   ===================================================== */
CREATE VIEW v_env_alert_management AS
SELECT
    a.alert_id,                  -- 告警编号
    a.alert_time,                -- 告警时间
    a.alert_level,               -- 告警等级
    a.alert_status,              -- 告警处理状态
    ed.data_id,                  -- 对应环境数据编号
    mi.indicator_name,           -- 异常指标名称
    ed.monitor_value,            -- 异常监测值
    r.region_name,               -- 所属区域名称
    md.device_id,                -- 设备编号
    md.device_type               -- 设备类型
FROM Alert a
JOIN EnvironmentalData ed ON a.data_id = ed.data_id
JOIN MonitoringIndicator mi ON ed.indicator_id = mi.indicator_id
LEFT JOIN Region r ON ed.region_id = r.region_id
LEFT JOIN MonitoringDevice md ON ed.device_id = md.device_id;
