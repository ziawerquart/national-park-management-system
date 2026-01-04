SET NAMES utf8mb4;
USE national_park_db;

-- ==============================================
-- 索引1：idx_ibr_occur_time 非法行为记录-发生时间索引
-- 高频场景：按时间范围查询案件、案件趋势分析、月度/年度统计
-- ==============================================
CREATE INDEX idx_ibr_occur_time ON IllegalBehaviorRecord(occur_time);

-- ==============================================
-- 索引2：idx_ibr_region_status 非法行为记录-区域+处理状态 复合索引
-- 高频场景：按区域筛选案件、按状态筛选案件、区域+状态组合查询（最常用）
-- ==============================================
CREATE INDEX idx_ibr_region_status ON IllegalBehaviorRecord(region_id, process_status);

-- ==============================================
-- 索引3：idx_ibr_law_id 非法行为记录-执法人员ID索引
-- 高频场景：查询指定执法人员承办案件、人员工作量统计
-- ==============================================
CREATE INDEX idx_ibr_law_id ON IllegalBehaviorRecord(law_id);

-- ==============================================
-- 索引4：idx_led_dispatch_law 执法调度表-调度时间+执法人员ID 复合索引
-- 高频场景：按时间范围查询调度记录、统计指定人员调度任务、调度效率分析
-- ==============================================
CREATE INDEX idx_led_dispatch_law ON LawEnforcementDispatch(dispatch_time, law_id);