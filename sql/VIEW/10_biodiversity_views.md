# 10_biodiversity_views.md（Stage4｜VIEW 适用范围说明）

## v_bio_records_to_verify（数据分析师：待核实记录工作台）
- 解决什么业务问题：把 `MonitoringRecord.status='to_verify'` 的记录一次性联表到物种、设备、区域、提交人，便于数据分析师集中核验与回溯来源。
- 适用范围/什么时候用：分析师每天拉取待核实列表（按 `monitoring_time` 倒序筛选/分页），或按 `region_id / species_id / device_id` 进一步过滤。
- 注意事项/限制条件：区域字段使用 `COALESCE(device.region_id, habitat.region_id)` 推断；若设备与物种栖息地同时缺失 region，会得到 NULL；如需强排序请在查询时加 `ORDER BY`.

## v_bio_species_protection_stats（管理层：保护级别物种数量统计）
- 解决什么业务问题：快速得到不同 `Species.protection_level` 下的物种数量，用于保护等级结构盘点与报表。
- 适用范围/什么时候用：管理人员做“一级/二级/无”保护等级统计，或对比不同时间点导入后的物种数量变化（结合历史表/快照时使用）。
- 注意事项/限制条件：该视图只统计 `Species` 表当前数据；如果存在重复物种或同物种多条记录，会直接计入数量。

## v_bio_habitat_primary_species_summary（生态/科研：栖息地主要物种概览）
- 解决什么业务问题：把 `Habitat` 与 N:M 中间表 `HabitatPrimarySpecies` 联合，汇总每个栖息地的“主要物种数量”和“主要物种中文名列表”。
- 适用范围/什么时候用：生态监测/科研在做栖息地规划、重点物种清单输出时，按 `habitat_id` 或 `region_id` 查询。
- 注意事项/限制条件：使用 `GROUP_CONCAT` 输出列表，受 `group_concat_max_len` 影响；当主要物种过多时列表可能截断，可改为只输出 count 或在会话提高该参数。

## v_bio_region_last30d_monitoring_stats（管理层/分析：近 30 天区域监测活跃度）
- 解决什么业务问题：按天统计近 30 天各区域的监测记录量、覆盖物种数、设备数，以及 `valid/to_verify` 结构，支持快速发现异常波动。
- 适用范围/什么时候用：管理人员查看区域监测强度（`record_count`），分析师定位待核实积压（`to_verify_count`）的日期/区域。
- 注意事项/限制条件：该视图依赖 `NOW()`，结果会随时间滚动变化；区域同样使用 `COALESCE(device.region_id, habitat.region_id)` 推断，需保证设备/栖息地至少一侧能关联到 Region。
