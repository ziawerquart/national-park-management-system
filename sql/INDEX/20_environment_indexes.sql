/* =====================================================
   索引名称：idx_ed_region_time
   表名    ：EnvironmentalData
   设计目的：
   - 优化按区域 + 时间范围查询环境数据的性能
   - 适用于实时监控与历史数据回溯场景
   ===================================================== */
CREATE INDEX idx_ed_region_time
ON EnvironmentalData (region_id, collect_time);
/* =====================================================
   索引名称：idx_ed_indicator_time
   表名    ：EnvironmentalData
   设计目的：
   - 优化按监测指标 + 时间范围的查询
   - 支撑指标趋势分析与统计计算
   ===================================================== */
CREATE INDEX idx_ed_indicator_time
ON EnvironmentalData (indicator_id, collect_time);
/* =====================================================
   索引名称：idx_md_region_status
   表名    ：MonitoringDevice
   设计目的：
   - 加速按区域 + 设备运行状态的查询
   - 支撑设备运维与状态监控
   ===================================================== */
CREATE INDEX idx_md_region_status
ON MonitoringDevice (region_id, run_status);
/* =====================================================
   索引名称：idx_alert_time_level
   表名    ：Alert
   设计目的：
   - 优化按告警时间与等级的查询
   - 支撑管理层告警分析与应急决策
   ===================================================== */
CREATE INDEX idx_alert_time_level
ON Alert (alert_time, alert_level);
