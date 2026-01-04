-- ============================================================================
-- 科研支撑模块视图
-- ============================================================================

-- VIEW 1: 项目进度总览视图
CREATE OR REPLACE VIEW v_project_progress AS
SELECT 
    p.project_id,
    p.project_name,
    p.project_status,
    p.approval_date,
    p.completion_date,
    u.user_name AS leader_name,
    p.research_field,
    COUNT(DISTINCT r.collection_id) AS record_count,
    COUNT(DISTINCT a.achievement_id) AS achievement_count
FROM ResearchProject p
LEFT JOIN `User` u ON p.leader_id = u.user_id
LEFT JOIN ResearchDataRecord r ON p.project_id = r.project_id
LEFT JOIN ResearchAchievement a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name, p.project_status, p.approval_date, p.completion_date, u.user_name, p.research_field;

-- VIEW 2: 数据采集汇总视图
CREATE OR REPLACE VIEW v_record_summary AS
SELECT 
    r.project_id,
    p.project_name,
    r.data_source,
    rg.region_name,
    COUNT(*) AS record_count,
    SUM(r.is_verified) AS verified_count,
    MIN(r.collection_time) AS first_collection,
    MAX(r.collection_time) AS last_collection
FROM ResearchDataRecord r
JOIN ResearchProject p ON r.project_id = p.project_id
JOIN Region rg ON r.region_id = rg.region_id
GROUP BY r.project_id, p.project_name, r.data_source, rg.region_name;

-- VIEW 3: 成果统计视图
CREATE OR REPLACE VIEW v_achievement_statistics AS
SELECT 
    p.project_id,
    p.project_name,
    a.achievement_type,
    a.share_permission,
    COUNT(*) AS achievement_count,
    MIN(a.submit_time) AS earliest_submit,
    MAX(a.submit_time) AS latest_submit
FROM ResearchAchievement a
JOIN ResearchProject p ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name, a.achievement_type, a.share_permission;

-- VIEW 4: 数据采集员工作量视图
CREATE OR REPLACE VIEW v_collector_workload AS
SELECT 
    u.user_id,
    u.user_name,
    COUNT(r.collection_id) AS total_records,
    SUM(r.is_verified) AS verified_records,
    COUNT(DISTINCT r.project_id) AS project_count,
    COUNT(DISTINCT r.region_id) AS region_count,
    MAX(r.collection_time) AS last_collection_time
FROM `User` u
JOIN ResearchDataRecord r ON u.user_id = r.collector_id
GROUP BY u.user_id, u.user_name;
