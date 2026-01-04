-- ============================================================================
-- 科研支撑模块索引
-- ============================================================================

-- INDEX 1: 项目状态和时间复合索引
CREATE INDEX idx_project_status_time ON ResearchProject(project_status, start_time, end_time);

-- INDEX 2: 项目负责人索引
CREATE INDEX idx_project_leader ON ResearchProject(leader_user_id);

-- INDEX 3: 采集时间和项目复合索引
CREATE INDEX idx_collection_time_project ON ResearchDataCollection(collection_time, project_id);

-- INDEX 4: 成果类型和访问级别复合索引
CREATE INDEX idx_result_type_access ON ResearchResult(result_type, access_level, publish_time);

-- INDEX 5: 监测记录按栖息地和物种索引
CREATE INDEX idx_monitor_habitat_species ON MonitoringRecord(habitat_id, species_id, monitor_time);

-- INDEX 6: 物种保护级别索引
CREATE INDEX idx_species_protection ON Species(protection_level);
