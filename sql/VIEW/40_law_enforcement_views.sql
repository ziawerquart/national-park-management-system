SET NAMES utf8mb4;
USE national_park_db;

-- ==============================================
-- 视图1：v_illegal_behavior_detail 非法行为记录详情视图
-- 核心：整合违规记录+监控点+执法人员+区域全量关联数据，一站式查询案件全貌
-- ==============================================
CREATE OR REPLACE VIEW v_illegal_behavior_detail
AS
SELECT
    ibr.record_id,
    ibr.behavior_type,
    ibr.occur_time,
    ibr.region_id,
    r.region_name,
    r.region_type,
    ibr.monitor_id,
    vmp.monitor_range,
    vmp.latitude,
    vmp.longitude,
    ibr.evidence_path,
    ibr.process_status,
    ibr.law_id,
    leo.name AS law_office_name,
    leo.department,
    ibr.process_result,
    ibr.punishment_basis
FROM IllegalBehaviorRecord ibr
LEFT JOIN Region r ON ibr.region_id = r.region_id
LEFT JOIN VideoMonitorPoint vmp ON ibr.monitor_id = vmp.monitor_id
LEFT JOIN LawEnforcementOfficer leo ON ibr.law_id = leo.law_id
ORDER BY ibr.occur_time DESC;

-- ==============================================
-- 视图2：v_law_office_workload 执法人员工作量统计视图
-- 核心：按执法人员分组，统计承办案件总数+各状态案件数，支撑人员工作考核
-- ==============================================
CREATE OR REPLACE VIEW v_law_office_workload
AS
SELECT
    leo.law_id,
    leo.name,
    leo.department,
    COUNT(ibr.record_id) AS total_case_count,
    SUM(CASE WHEN ibr.process_status = 'unprocessed' THEN 1 ELSE 0 END) AS unprocessed_count,
    SUM(CASE WHEN ibr.process_status = 'processing' THEN 1 ELSE 0 END) AS processing_count,
    SUM(CASE WHEN ibr.process_status = 'closed' THEN 1 ELSE 0 END) AS closed_count
FROM LawEnforcementOfficer leo
LEFT JOIN IllegalBehaviorRecord ibr ON leo.law_id = ibr.law_id
GROUP BY leo.law_id, leo.name, leo.department
ORDER BY total_case_count DESC;

-- ==============================================
-- 视图3：v_region_case_stat 区域案件统计视图
-- 核心：按保护区区域分组，统计案件总数+高发违规类型，支撑区域防控调度
-- ==============================================
CREATE OR REPLACE VIEW v_region_case_stat
AS
SELECT
    r.region_id,
    r.region_name,
    r.region_type,
    COUNT(ibr.record_id) AS total_case_num,
    MAX(ibr.occur_time) AS last_case_time,
    (SELECT behavior_type FROM IllegalBehaviorRecord WHERE region_id = r.region_id GROUP BY behavior_type ORDER BY COUNT(*) DESC LIMIT 1) AS high_freq_behavior
FROM Region r
LEFT JOIN IllegalBehaviorRecord ibr ON r.region_id = ibr.region_id
GROUP BY r.region_id, r.region_name, r.region_type
ORDER BY total_case_num DESC;

-- ==============================================
-- 视图4：v_dispatch_efficiency 执法调度效率视图
-- 核心：整合调度记录+违规案件+执法人员，统计响应/办结时长，评估执法效率
-- ==============================================
CREATE OR REPLACE VIEW v_dispatch_efficiency
AS
SELECT
    led.dispatch_id,
    ibr.record_id,
    ibr.behavior_type,
    leo.law_id,
    leo.name AS law_name,
    led.dispatch_time,
    led.response_time,
    led.finish_time,
    led.dispatch_status,
    TIMESTAMPDIFF(MINUTE, led.dispatch_time, led.response_time) AS response_minutes,
    TIMESTAMPDIFF(MINUTE, led.response_time, led.finish_time) AS finish_minutes
FROM LawEnforcementDispatch led
LEFT JOIN IllegalBehaviorRecord ibr ON led.record_id = ibr.record_id
LEFT JOIN LawEnforcementOfficer leo ON led.law_id = leo.law_id
ORDER BY led.dispatch_time DESC;