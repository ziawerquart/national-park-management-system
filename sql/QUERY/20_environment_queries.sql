-- ================================
-- 查询一（实现方式一）：异常环境数据及告警信息查询
-- 使用多表 JOIN 的方式直接完成查询
-- 目的：查询所有异常环境数据，并关联指标、区域及告警信息
-- ================================
EXPLAIN ANALYZE
SELECT
    ed.data_id,                 -- 环境数据唯一标识
    mi.indicator_name,           -- 监测指标名称
    r.region_name,               -- 区域名称
    ed.monitor_value,            -- 监测值
    a.alert_level                -- 告警级别（可能为空）
FROM EnvironmentalData ed
JOIN MonitoringIndicator mi     -- 关联监测指标表
    ON ed.indicator_id = mi.indicator_id
JOIN Region r                   -- 关联区域表
    ON ed.region_id = r.region_id
LEFT JOIN Alert a               -- 左连接告警表，保证异常数据不丢失
    ON ed.data_id = a.data_id
WHERE ed.is_abnormal = TRUE;    -- 仅筛选异常环境数据

-- ================================
-- 查询一（实现方式二）：使用 CTE 的异常环境数据查询
-- 先在 CTE 中过滤异常数据，再进行多表关联
-- 目的：提升可读性，减少 JOIN 参与数据量
-- ================================
EXPLAIN ANALYZE
WITH abnormal_data AS (
    -- 先筛选异常环境数据
    SELECT *
    FROM EnvironmentalData
    WHERE is_abnormal = TRUE
)
SELECT
    ad.data_id,
    mi.indicator_name,
    r.region_name,
    ad.monitor_value,
    a.alert_level
FROM abnormal_data ad
JOIN MonitoringIndicator mi
    ON ad.indicator_id = mi.indicator_id
JOIN Region r
    ON ad.region_id = r.region_id
LEFT JOIN Alert a
    ON ad.data_id = a.data_id;

-- ================================
-- 查询二（实现方式一）：按区域统计异常数据数量
-- 使用 JOIN + GROUP BY 直接统计
-- ================================
EXPLAIN ANALYZE
SELECT
    r.region_name,               -- 区域名称
    COUNT(*) AS abnormal_count   -- 异常数据数量
FROM EnvironmentalData ed
JOIN Region r
    ON ed.region_id = r.region_id
WHERE ed.is_abnormal = TRUE      -- 仅统计异常数据
GROUP BY r.region_name;

-- ================================
-- 查询二（实现方式二）：子查询先统计，再关联区域表
-- 目的：先在事实表中完成聚合，再补充维度信息
-- ================================
EXPLAIN ANALYZE
SELECT
    r.region_name,
    sub.abnormal_count
FROM Region r
JOIN (
    -- 子查询：按区域统计异常数据数量
    SELECT
        region_id,
        COUNT(*) abnormal_count
    FROM EnvironmentalData
    WHERE is_abnormal = TRUE
    GROUP BY region_id
) sub
    ON r.region_id = sub.region_id;

-- ================================
-- 查询三（实现方式一）：查询每个设备的最新监测数据
-- 使用相关子查询获取每个设备的最大采集时间
-- ================================
EXPLAIN ANALYZE
SELECT
    md.device_id,                -- 设备编号
    mi.indicator_name,           -- 指标名称
    ed.monitor_value,            -- 监测值
    ed.collect_time              -- 采集时间
FROM MonitoringDevice md
JOIN EnvironmentalData ed
    ON md.device_id = ed.device_id
JOIN MonitoringIndicator mi
    ON ed.indicator_id = mi.indicator_id
WHERE ed.collect_time = (
    -- 子查询：获取当前设备的最新采集时间
    SELECT MAX(collect_time)
    FROM EnvironmentalData
    WHERE device_id = md.device_id
);

-- ================================
-- 查询三（实现方式二）：使用窗口函数获取最新监测数据
-- 通过 ROW_NUMBER() 避免重复扫描，提高性能
-- ================================
EXPLAIN ANALYZE
SELECT
    device_id,
    indicator_name,
    monitor_value,
    collect_time
FROM (
    SELECT
        md.device_id,
        mi.indicator_name,
        ed.monitor_value,
        ed.collect_time,
        -- 按设备分区，按采集时间倒序排序
        ROW_NUMBER() OVER (
            PARTITION BY md.device_id
            ORDER BY ed.collect_time DESC
        ) rn
    FROM MonitoringDevice md
    JOIN EnvironmentalData ed
        ON md.device_id = ed.device_id
    JOIN MonitoringIndicator mi
        ON ed.indicator_id = mi.indicator_id
) t
WHERE rn = 1;    -- 仅保留每个设备最新的一条记录

-- ================================
-- 查询四（实现方式一）：统计各监测指标异常发生次数
-- 直接在事实表中聚合
-- ================================
EXPLAIN ANALYZE
SELECT
    mi.indicator_name,            -- 指标名称
    COUNT(*) AS abnormal_times    -- 异常发生次数
FROM EnvironmentalData ed
JOIN MonitoringIndicator mi
    ON ed.indicator_id = mi.indicator_id
WHERE ed.is_abnormal = TRUE
GROUP BY mi.indicator_name
ORDER BY abnormal_times DESC;

-- ================================
-- 查询四（实现方式二）：使用 CTE 提前筛选异常记录
-- 减少后续 JOIN 的数据规模
-- ================================
EXPLAIN ANALYZE
WITH abnormal_records AS (
    -- 提前筛选异常记录，仅保留 indicator_id
    SELECT indicator_id
    FROM EnvironmentalData
    WHERE is_abnormal = TRUE
)
SELECT
    mi.indicator_name,
    COUNT(*) abnormal_times
FROM abnormal_records ar
JOIN MonitoringIndicator mi
    ON ar.indicator_id = mi.indicator_id
GROUP BY mi.indicator_name
ORDER BY abnormal_times DESC;

-- ================================
-- 查询五（实现方式一）：检测校准超期的监测设备
-- 使用 HAVING 对聚合结果进行条件判断
-- ================================
EXPLAIN ANALYZE
SELECT
    md.device_id,
    MAX(cr.calibration_time) AS last_calibration
FROM MonitoringDevice md
JOIN CalibrationRecord cr
    ON md.device_id = cr.device_id
GROUP BY md.device_id
HAVING
    -- 最近一次校准时间 + 校准周期 < 当前时间
    DATE_ADD(
        MAX(cr.calibration_time),
        INTERVAL md.calibration_cycle DAY
    ) < NOW();

-- ================================
-- 查询五（实现方式二）：子查询先计算最近校准时间
-- 再在外层进行超期判断
-- ================================
EXPLAIN ANALYZE
SELECT
    device_id,
    last_calibration
FROM (
    SELECT
        md.device_id,
        MAX(cr.calibration_time) AS last_calibration,
        md.calibration_cycle
    FROM MonitoringDevice md
    JOIN CalibrationRecord cr
        ON md.device_id = cr.device_id
    GROUP BY md.device_id
) t
WHERE
    DATE_ADD(
        last_calibration,
        INTERVAL calibration_cycle DAY
    ) < NOW();
