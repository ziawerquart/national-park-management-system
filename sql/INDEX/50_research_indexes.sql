-- ============================================================================
-- 科研支撑模块索引
-- ============================================================================

-- INDEX 1: 项目状态和日期复合索引
CREATE INDEX idx_project_status_date ON ResearchProject(project_status, approval_date);

-- INDEX 2: 项目负责人索引
CREATE INDEX idx_project_leader ON ResearchProject(leader_id);

-- INDEX 3: 数据记录按项目和时间索引
CREATE INDEX idx_record_project_time ON ResearchDataRecord(project_id, collection_time);

-- INDEX 4: 数据记录按采集员索引
CREATE INDEX idx_record_collector ON ResearchDataRecord(collector_id);

-- INDEX 5: 数据记录按区域索引
CREATE INDEX idx_record_region ON ResearchDataRecord(region_id);

-- INDEX 6: 成果按类型和权限索引
CREATE INDEX idx_achievement_type_permission ON ResearchAchievement(achievement_type, share_permission);
