-- ============================================================================
-- 科研支撑模块视图
-- ============================================================================

-- VIEW 1: 项目进度总览视图
CREATE OR REPLACE VIEW v_project_progress AS
SELECT 
    p.project_id,
    p.project_name,
    p.project_status,
    p.start_time,
    p.end_time,
    u.name AS leader_name,
    COUNT(DISTINCT c.collection_id) AS collection_count,
    COUNT(DISTINCT r.result_id) AS result_count
FROM ResearchProject p
LEFT JOIN User u ON p.leader_user_id = u.user_id
LEFT JOIN ResearchDataCollection c ON p.project_id = c.project_id
LEFT JOIN ResearchResult r ON p.project_id = r.project_id
GROUP BY p.project_id, p.project_name, p.project_status, p.start_time, p.end_time, u.name;

-- VIEW 2: 数据采集汇总视图
CREATE OR REPLACE VIEW v_collection_summary AS
SELECT 
    c.project_id,
    p.project_name,
    c.data_source,
    COUNT(*) AS collection_count,
    MIN(c.collection_time) AS first_collection,
    MAX(c.collection_time) AS last_collection,
    COUNT(DISTINCT m.record_id) AS monitoring_record_count
FROM ResearchDataCollection c
JOIN ResearchProject p ON c.project_id = p.project_id
LEFT JOIN MonitoringRecord m ON c.collection_id = m.collection_id
GROUP BY c.project_id, p.project_name, c.data_source;

-- VIEW 3: 成果统计视图
CREATE OR REPLACE VIEW v_result_statistics AS
SELECT 
    p.project_id,
    p.project_name,
    r.result_type,
    r.access_level,
    COUNT(*) AS result_count,
    MIN(r.publish_time) AS earliest_publish,
    MAX(r.publish_time) AS latest_publish
FROM ResearchResult r
JOIN ResearchProject p ON r.project_id = p.project_id
GROUP BY p.project_id, p.project_name, r.result_type, r.access_level;

-- VIEW 4: 栖息地物种监测视图
CREATE OR REPLACE VIEW v_habitat_species_monitoring AS
SELECT 
    h.habitat_id,
    h.habitat_name,
    h.region_code,
    s.species_id,
    s.scientific_name,
    s.common_name,
    s.protection_level,
    COUNT(m.record_id) AS monitor_count,
    MAX(m.monitor_time) AS last_monitor_time
FROM Habitat h
JOIN HabitatPrimarySpecies hps ON h.habitat_id = hps.habitat_id
JOIN Species s ON hps.species_id = s.species_id
LEFT JOIN MonitoringRecord m ON h.habitat_id = m.habitat_id AND s.species_id = m.species_id
GROUP BY h.habitat_id, h.habitat_name, h.region_code, s.species_id, s.scientific_name, s.common_name, s.protection_level;
