SET NAMES utf8mb4;
USE national_park_db;

-- ==============================================
-- 存储过程：proc_law_enforcement_statistic
-- 功能：多维度执法监管统计（区域案件量、执法人员工作量、调度效率）
-- ✅ 核心修复：1.默认统计全量数据 2.优化关联逻辑 3.保留零除防护
-- ✅ 适配测试库：直接统计历史案件，无需手动传参，执行即出有效结果
-- ==============================================
DELIMITER //
CREATE PROCEDURE proc_law_enforcement_statistic(
    IN start_time DATETIME,  -- 统计开始时间（NULL=统计全量）
    IN end_time DATETIME     -- 统计结束时间（NULL=统计全量）
)
BEGIN
    -- ✅ 修复点1：入参默认值改为【统计全量数据】（适配测试库无近期数据场景）
    -- 传NULL=统计所有历史数据 | 传时间=统计指定时间段
    SET @start = IF(start_time IS NULL, '1970-01-01 00:00:00', start_time);
    SET @end = IF(end_time IS NULL, NOW(), end_time);

    -- 结果集1：【各区域案件统计】全量/指定时段，区域案件量+高发类型+结案率
    DROP TEMPORARY TABLE IF EXISTS temp_region_stat;
    CREATE TEMPORARY TABLE temp_region_stat AS
    SELECT
        r.region_id,
        r.region_name,
        COUNT(ibr.record_id) AS case_count,
        IFNULL((SELECT behavior_type FROM IllegalBehaviorRecord 
                WHERE region_id = r.region_id AND occur_time BETWEEN @start AND @end 
                GROUP BY behavior_type ORDER BY COUNT(*) DESC LIMIT 1), 'No Record') AS high_freq_behavior,
        CONCAT(ROUND(IF(COUNT(ibr.record_id)=0,0,SUM(CASE WHEN ibr.process_status = 'closed' THEN 1 ELSE 0 END)/COUNT(ibr.record_id)*100),2),'%') AS close_rate
    FROM Region r
    LEFT JOIN IllegalBehaviorRecord ibr ON r.region_id = ibr.region_id
    WHERE ibr.occur_time BETWEEN @start AND @end OR ibr.occur_time IS NULL
    GROUP BY r.region_id, r.region_name
    ORDER BY case_count DESC;
    SELECT '=== 【结果1：各区域案件统计】 ===' AS title;
    SELECT * FROM temp_region_stat;

    -- 结果集2：【执法人员工作量TOP10】全量/指定时段，办案数+结案数+办结率
    DROP TEMPORARY TABLE IF EXISTS temp_office_rank;
    CREATE TEMPORARY TABLE temp_office_rank AS
    SELECT
        leo.law_id,
        leo.name,
        leo.department,
        COUNT(ibr.record_id) AS handle_case_count,
        SUM(CASE WHEN ibr.process_status = 'closed' THEN 1 ELSE 0 END) AS close_case_count,
        CONCAT(ROUND(IF(COUNT(ibr.record_id)=0,0,SUM(CASE WHEN ibr.process_status = 'closed' THEN 1 ELSE 0 END)/COUNT(ibr.record_id)*100),2),'%') AS close_rate
    FROM LawEnforcementOfficer leo
    LEFT JOIN IllegalBehaviorRecord ibr ON leo.law_id = ibr.law_id
    WHERE ibr.occur_time BETWEEN @start AND @end OR ibr.occur_time IS NULL
    GROUP BY leo.law_id, leo.name, leo.department
    ORDER BY handle_case_count DESC LIMIT 10;
    SELECT '=== 【结果2：执法人员工作量TOP10】 ===' AS title;
    SELECT * FROM temp_office_rank;

    -- 结果集3：【调度效率统计】全量/指定时段，调度数+完成率+平均时长
    SELECT '=== 【结果3：执法调度效率统计】 ===' AS title;
    SELECT
        COUNT(dispatch_id) AS total_dispatch_count,
        SUM(CASE WHEN dispatch_status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
        CONCAT(ROUND(IF(COUNT(dispatch_id)=0,0,SUM(CASE WHEN dispatch_status = 'completed' THEN 1 ELSE 0 END)/COUNT(dispatch_id)*100),2),'%') AS dispatch_complete_rate,
        CONCAT(ROUND(IFNULL(AVG(TIMESTAMPDIFF(MINUTE, dispatch_time, response_time)),0),2),' 分钟') AS avg_response_time,
        CONCAT(ROUND(IFNULL(AVG(TIMESTAMPDIFF(MINUTE, response_time, finish_time)),0),2),' 分钟') AS avg_finish_time
    FROM LawEnforcementDispatch
    WHERE dispatch_time BETWEEN @start AND @end OR dispatch_time IS NULL;

    -- 清理临时表
    DROP TEMPORARY TABLE IF EXISTS temp_region_stat;
    DROP TEMPORARY TABLE IF EXISTS temp_office_rank;
END //
DELIMITER ;

