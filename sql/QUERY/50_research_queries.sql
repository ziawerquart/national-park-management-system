-- ================================================================
-- 科研支撑模块 - 复杂查询集合（带性能分析）
-- 每条查询提供2种实现方式，每种都使用 EXPLAIN ANALYZE 记录性能
-- 使用方法：在MySQL中逐条执行，记录每次的 actual time 和 rows
-- ================================================================

USE wildlife_conservation;

-- ================================================================
-- 查询1: 统计每个项目的数据采集次数、监测记录数和研究成果数
-- 要求: 3表连接 + 聚合 + 排序
-- ================================================================

-- <<<< 实现方式1: 使用子查询预聚合 >>>>
EXPLAIN ANALYZE
SELECT 
    rp.project_id,
    rp.project_name,
    rp.principal_investigator_id,
    rp.project_status,
    COALESCE(dc.collection_count, 0) AS collection_count,
    COALESCE(mr.record_count, 0) AS record_count,
    COALESCE(rr.result_count, 0) AS result_count
FROM ResearchProject rp
LEFT JOIN (
    SELECT project_id, COUNT(*) AS collection_count
    FROM ResearchDataCollection
    GROUP BY project_id
) dc ON rp.project_id = dc.project_id
LEFT JOIN (
    SELECT rdc.project_id, COUNT(mr.record_id) AS record_count
    FROM ResearchDataCollection rdc
    JOIN MonitoringRecord mr ON rdc.collection_id = mr.collection_id
    GROUP BY rdc.project_id
) mr ON rp.project_id = mr.project_id
LEFT JOIN (
    SELECT project_id, COUNT(*) AS result_count
    FROM ResearchResult
    GROUP BY project_id
) rr ON rp.project_id = rr.project_id
WHERE rp.project_status = 'InProgress'
ORDER BY collection_count DESC, record_count DESC;

-- 【记录】实现方式1 - 执行时间: _______ms, 扫描行数: _______

-- <<<< 实现方式2: 使用 LEFT JOIN 直接关联 >>>>
EXPLAIN ANALYZE
SELECT 
    rp.project_id,
    rp.project_name,
    rp.principal_investigator_id,
    rp.project_status,
    COUNT(DISTINCT rdc.collection_id) AS collection_count,
    COUNT(DISTINCT mr.record_id) AS record_count,
    COUNT(DISTINCT rr.result_id) AS result_count
FROM ResearchProject rp
LEFT JOIN ResearchDataCollection rdc ON rp.project_id = rdc.project_id
LEFT JOIN MonitoringRecord mr ON rdc.collection_id = mr.collection_id
LEFT JOIN ResearchResult rr ON rp.project_id = rr.project_id
WHERE rp.project_status = 'InProgress'
GROUP BY rp.project_id, rp.project_name, rp.principal_investigator_id, rp.project_status
ORDER BY collection_count DESC, record_count DESC;

-- 【记录】实现方式2 - 执行时间: _______ms, 扫描行数: _______


-- ================================================================
-- 查询2: 查询每个栖息地的物种多样性及其监测记录统计
-- 要求: 4表连接 + 聚合 + 条件过滤 + 排序
-- ================================================================

-- <<<< 实现方式1: 使用CTE (Common Table Expression) >>>>
EXPLAIN ANALYZE
WITH HabitatSpeciesCount AS (
    SELECT 
        h.habitat_id,
        h.habitat_name,
        h.region_code,
        COUNT(DISTINCT hps.species_id) AS species_count
    FROM Habitat h
    LEFT JOIN HabitatPrimarySpecies hps ON h.habitat_id = hps.habitat_id
    GROUP BY h.habitat_id, h.habitat_name, h.region_code
),
HabitatMonitoringStats AS (
    SELECT 
        h.habitat_id,
        COUNT(DISTINCT mr.record_id) AS monitoring_count,
        COUNT(DISTINCT mr.species_id) AS monitored_species_count
    FROM Habitat h
    LEFT JOIN MonitoringRecord mr ON h.habitat_id = mr.habitat_id
    GROUP BY h.habitat_id
)
SELECT 
    hsc.habitat_id,
    hsc.habitat_name,
    hsc.region_code,
    hsc.species_count,
    COALESCE(hms.monitoring_count, 0) AS monitoring_count,
    COALESCE(hms.monitored_species_count, 0) AS monitored_species_count
FROM HabitatSpeciesCount hsc
LEFT JOIN HabitatMonitoringStats hms ON hsc.habitat_id = hms.habitat_id
WHERE hsc.species_count >= 2
ORDER BY hsc.species_count DESC, monitoring_count DESC;

-- 【记录】实现方式1 - 执行时间: _______ms, 扫描行数: _______

-- <<<< 实现方式2: 使用子查询嵌套 >>>>
EXPLAIN ANALYZE
SELECT 
    h.habitat_id,
    h.habitat_name,
    h.region_code,
    COALESCE(species_stats.species_count, 0) AS species_count,
    COALESCE(monitoring_stats.monitoring_count, 0) AS monitoring_count,
    COALESCE(monitoring_stats.monitored_species_count, 0) AS monitored_species_count
FROM Habitat h
LEFT JOIN (
    SELECT habitat_id, COUNT(DISTINCT species_id) AS species_count
    FROM HabitatPrimarySpecies
    GROUP BY habitat_id
) species_stats ON h.habitat_id = species_stats.habitat_id
LEFT JOIN (
    SELECT 
        habitat_id, 
        COUNT(DISTINCT record_id) AS monitoring_count,
        COUNT(DISTINCT species_id) AS monitored_species_count
    FROM MonitoringRecord
    GROUP BY habitat_id
) monitoring_stats ON h.habitat_id = monitoring_stats.habitat_id
WHERE COALESCE(species_stats.species_count, 0) >= 2
ORDER BY species_count DESC, monitoring_count DESC;

-- 【记录】实现方式2 - 执行时间: _______ms, 扫描行数: _______


-- ================================================================
-- 查询3: 统计每个研究员负责的项目及其数据采集情况
-- 要求: 3表连接 + 聚合 + 条件过滤 + 排序
-- ================================================================

-- <<<< 实现方式1: 使用内连接和分组 >>>>
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.name AS investigator_name,
    u.role,
    COUNT(DISTINCT rp.project_id) AS total_projects,
    SUM(CASE WHEN rp.project_status = 'InProgress' THEN 1 ELSE 0 END) AS ongoing_projects,
    SUM(CASE WHEN rp.project_status = 'Completed' THEN 1 ELSE 0 END) AS completed_projects,
    COUNT(DISTINCT rdc.collection_id) AS total_collections,
    COALESCE(AVG(DATEDIFF(rp.end_time, rp.start_time)), 0) AS avg_project_duration_days
FROM User u
JOIN ResearchProject rp ON u.user_id = rp.principal_investigator_id
LEFT JOIN ResearchDataCollection rdc ON rp.project_id = rdc.project_id
WHERE u.role = 'Researcher'
GROUP BY u.user_id, u.name, u.role
HAVING COUNT(DISTINCT rp.project_id) >= 1
ORDER BY total_projects DESC, total_collections DESC;

-- 【记录】实现方式1 - 执行时间: _______ms, 扫描行数: _______

-- <<<< 实现方式2: 使用子查询和LEFT JOIN >>>>
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.name AS investigator_name,
    u.role,
    proj_stats.total_projects,
    proj_stats.ongoing_projects,
    proj_stats.completed_projects,
    COALESCE(collection_stats.total_collections, 0) AS total_collections,
    proj_stats.avg_project_duration_days
FROM User u
JOIN (
    SELECT 
        principal_investigator_id,
        COUNT(*) AS total_projects,
        SUM(CASE WHEN project_status = 'InProgress' THEN 1 ELSE 0 END) AS ongoing_projects,
        SUM(CASE WHEN project_status = 'Completed' THEN 1 ELSE 0 END) AS completed_projects,
        AVG(DATEDIFF(end_time, start_time)) AS avg_project_duration_days
    FROM ResearchProject
    GROUP BY principal_investigator_id
) proj_stats ON u.user_id = proj_stats.principal_investigator_id
LEFT JOIN (
    SELECT 
        rp.principal_investigator_id,
        COUNT(DISTINCT rdc.collection_id) AS total_collections
    FROM ResearchProject rp
    JOIN ResearchDataCollection rdc ON rp.project_id = rdc.project_id
    GROUP BY rp.principal_investigator_id
) collection_stats ON u.user_id = collection_stats.principal_investigator_id
WHERE u.role = 'Researcher' AND proj_stats.total_projects >= 1
ORDER BY proj_stats.total_projects DESC, total_collections DESC;

-- 【记录】实现方式2 - 执行时间: _______ms, 扫描行数: _______


-- ================================================================
-- 查询4: 查询特定物种在不同栖息地的监测频率和数据分布
-- 要求: 4表连接 + 聚合 + 条件过滤 + 排序
-- ================================================================

-- <<<< 实现方式1: 使用JOIN和聚合函数 >>>>
EXPLAIN ANALYZE
SELECT 
    s.species_id,
    s.scientific_name,
    s.common_name,
    s.protection_level,
    h.habitat_id,
    h.habitat_name,
    h.region_code,
    COUNT(DISTINCT mr.record_id) AS monitoring_count,
    COUNT(DISTINCT rdc.collection_id) AS collection_count,
    MIN(mr.monitor_time) AS first_monitoring_time,
    MAX(mr.monitor_time) AS last_monitoring_time
FROM Species s
JOIN MonitoringRecord mr ON s.species_id = mr.species_id
JOIN Habitat h ON mr.habitat_id = h.habitat_id
JOIN ResearchDataCollection rdc ON mr.collection_id = rdc.collection_id
WHERE s.protection_level IN ('Endangered', 'Vulnerable')
GROUP BY s.species_id, s.scientific_name, s.common_name, s.protection_level,
         h.habitat_id, h.habitat_name, h.region_code
HAVING COUNT(DISTINCT mr.record_id) >= 3
ORDER BY s.protection_level, monitoring_count DESC;

-- 【记录】实现方式1 - 执行时间: _______ms, 扫描行数: _______

-- <<<< 实现方式2: 使用子查询优化（预聚合） >>>>
EXPLAIN ANALYZE
SELECT 
    s.species_id,
    s.scientific_name,
    s.common_name,
    s.protection_level,
    h.habitat_id,
    h.habitat_name,
    h.region_code,
    mr_stats.monitoring_count,
    mr_stats.collection_count,
    mr_stats.first_monitoring_time,
    mr_stats.last_monitoring_time
FROM Species s
JOIN (
    SELECT 
        species_id,
        habitat_id,
        COUNT(DISTINCT record_id) AS monitoring_count,
        COUNT(DISTINCT collection_id) AS collection_count,
        MIN(monitor_time) AS first_monitoring_time,
        MAX(monitor_time) AS last_monitoring_time
    FROM MonitoringRecord
    GROUP BY species_id, habitat_id
    HAVING COUNT(DISTINCT record_id) >= 3
) mr_stats ON s.species_id = mr_stats.species_id
JOIN Habitat h ON mr_stats.habitat_id = h.habitat_id
WHERE s.protection_level IN ('Endangered', 'Vulnerable')
ORDER BY s.protection_level, mr_stats.monitoring_count DESC;

-- 【记录】实现方式2 - 执行时间: _______ms, 扫描行数: _______


-- ================================================================
-- 查询5: 分析研究成果的发布趋势及其关联的数据采集情况
-- 要求: 4表连接 + 聚合 + 时间条件 + 排序
-- ================================================================

-- <<<< 实现方式1: 使用YEAR函数和多表连接 >>>>
EXPLAIN ANALYZE
SELECT 
    YEAR(rr.publish_time) AS publish_year,
    rr.result_type,
    rr.access_level,
    COUNT(DISTINCT rr.result_id) AS result_count,
    COUNT(DISTINCT rp.project_id) AS project_count,
    COUNT(DISTINCT rdc.collection_id) AS collection_count,
    COUNT(DISTINCT mr.record_id) AS monitoring_record_count
FROM ResearchResult rr
JOIN ResearchProject rp ON rr.project_id = rp.project_id
LEFT JOIN ResearchDataCollection rdc ON rp.project_id = rdc.project_id
LEFT JOIN MonitoringRecord mr ON rdc.collection_id = mr.collection_id
WHERE rr.publish_time >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
GROUP BY YEAR(rr.publish_time), rr.result_type, rr.access_level
HAVING COUNT(DISTINCT rr.result_id) >= 1
ORDER BY publish_year DESC, result_count DESC;

-- 【记录】实现方式1 - 执行时间: _______ms, 扫描行数: _______

-- <<<< 实现方式2: 使用CTE分步统计 >>>>
EXPLAIN ANALYZE
WITH ResultStats AS (
    SELECT 
        YEAR(publish_time) AS publish_year,
        result_type,
        access_level,
        project_id,
        COUNT(*) AS result_count
    FROM ResearchResult
    WHERE publish_time >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
    GROUP BY YEAR(publish_time), result_type, access_level, project_id
),
ProjectDataStats AS (
    SELECT 
        rp.project_id,
        COUNT(DISTINCT rdc.collection_id) AS collection_count,
        COUNT(DISTINCT mr.record_id) AS monitoring_record_count
    FROM ResearchProject rp
    LEFT JOIN ResearchDataCollection rdc ON rp.project_id = rdc.project_id
    LEFT JOIN MonitoringRecord mr ON rdc.collection_id = mr.collection_id
    GROUP BY rp.project_id
)
SELECT 
    rs.publish_year,
    rs.result_type,
    rs.access_level,
    SUM(rs.result_count) AS result_count,
    COUNT(DISTINCT rs.project_id) AS project_count,
    SUM(COALESCE(pds.collection_count, 0)) AS collection_count,
    SUM(COALESCE(pds.monitoring_record_count, 0)) AS monitoring_record_count
FROM ResultStats rs
LEFT JOIN ProjectDataStats pds ON rs.project_id = pds.project_id
GROUP BY rs.publish_year, rs.result_type, rs.access_level
HAVING SUM(rs.result_count) >= 1
ORDER BY rs.publish_year DESC, result_count DESC;

-- 【记录】实现方式2 - 执行时间: _______ms, 扫描行数: _______


-- ================================================================
-- 查询6: 分析不同数据来源的采集效率和监测记录质量
-- 要求: 3表连接 + 聚合 + 条件过滤 + 排序
-- ================================================================

-- <<<< 实现方式1: 使用GROUP BY和聚合函数 >>>>
EXPLAIN ANALYZE
SELECT 
    rdc.data_source,
    rp.research_field,
    COUNT(DISTINCT rdc.collection_id) AS total_collections,
    COUNT(DISTINCT mr.record_id) AS total_records,
    ROUND(COUNT(DISTINCT mr.record_id) * 1.0 / COUNT(DISTINCT rdc.collection_id), 2) AS avg_records_per_collection,
    COUNT(DISTINCT mr.species_id) AS unique_species_monitored,
    COUNT(DISTINCT mr.habitat_id) AS unique_habitats_covered
FROM ResearchDataCollection rdc
JOIN ResearchProject rp ON rdc.project_id = rp.project_id
LEFT JOIN MonitoringRecord mr ON rdc.collection_id = mr.collection_id
WHERE rdc.collection_time >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY rdc.data_source, rp.research_field
HAVING COUNT(DISTINCT rdc.collection_id) >= 2
ORDER BY avg_records_per_collection DESC, total_collections DESC;

-- 【记录】实现方式1 - 执行时间: _______ms, 扫描行数: _______

-- <<<< 实现方式2: 使用子查询统计（预聚合） >>>>
EXPLAIN ANALYZE
SELECT 
    collection_stats.data_source,
    rp.research_field,
    collection_stats.total_collections,
    COALESCE(record_stats.total_records, 0) AS total_records,
    ROUND(COALESCE(record_stats.total_records, 0) * 1.0 / collection_stats.total_collections, 2) AS avg_records_per_collection,
    COALESCE(record_stats.unique_species_monitored, 0) AS unique_species_monitored,
    COALESCE(record_stats.unique_habitats_covered, 0) AS unique_habitats_covered
FROM (
    SELECT 
        data_source,
        project_id,
        COUNT(DISTINCT collection_id) AS total_collections
    FROM ResearchDataCollection
    WHERE collection_time >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
    GROUP BY data_source, project_id
) collection_stats
JOIN ResearchProject rp ON collection_stats.project_id = rp.project_id
LEFT JOIN (
    SELECT 
        rdc.data_source,
        rdc.project_id,
        COUNT(DISTINCT mr.record_id) AS total_records,
        COUNT(DISTINCT mr.species_id) AS unique_species_monitored,
        COUNT(DISTINCT mr.habitat_id) AS unique_habitats_covered
    FROM ResearchDataCollection rdc
    JOIN MonitoringRecord mr ON rdc.collection_id = mr.collection_id
    WHERE rdc.collection_time >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
    GROUP BY rdc.data_source, rdc.project_id
) record_stats ON collection_stats.data_source = record_stats.data_source 
                AND collection_stats.project_id = record_stats.project_id
WHERE collection_stats.total_collections >= 2
ORDER BY avg_records_per_collection DESC, collection_stats.total_collections DESC;

-- 【记录】实现方式2 - 执行时间: _______ms, 扫描行数: _______


-- ================================================================
-- 使用说明:
-- 1. 在MySQL中使用 tee 命令记录所有输出
--    mysql> tee ~/Desktop/query_results.log
-- 2. 逐条执行上述查询（复制粘贴执行）
-- 3. 记录每次 EXPLAIN ANALYZE 输出中的关键信息：
--    - actual time=X..Y  (执行时间，单位毫秒)
--    - rows=N            (扫描行数)
-- 4. 将记录的数据填写到 50_research_perf.md 文件中
-- ================================================================