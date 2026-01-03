# 10_biodiversity_indexes.md（Stage4｜INDEX 适用范围说明）

## idx_mr_status_time（MonitoringRecord(status, monitoring_time)）
- 解决什么业务问题：加速“待核实记录列表”这种 `WHERE status='to_verify'` + `ORDER BY monitoring_time` 的高频查询。
- 适用范围/什么时候用：数据分析师工作台分页；或按状态统计近一段时间的记录变化（`status` + 时间范围）。
- 注意事项/限制条件：如果查询里对 `monitoring_time` 使用函数（如 `DATE(monitoring_time)=...`），可能无法充分利用索引；建议改为时间范围过滤。

## idx_mr_species_time（MonitoringRecord(species_id, monitoring_time)）
- 解决什么业务问题：加速按物种查询“最近一次/最近30天记录”，并支撑按时间排序或时间区间筛选。
- 适用范围/什么时候用：科研/分析按 `species_id` 拉取监测时间序列；或做某物种活跃度趋势。
- 注意事项/限制条件：对 `species_id` 的低选择性（很多记录同一个物种）会导致索引收益下降，但在配合时间范围时仍有效。

## idx_mr_device_time（MonitoringRecord(device_id, monitoring_time)）
- 解决什么业务问题：加速按设备追踪数据质量（某设备最近上传、掉线后是否仍有数据）与按设备汇总。
- 适用范围/什么时候用：运维排查某设备的监测记录；或区域统计时先按设备过滤再汇总。
- 注意事项/限制条件：如果 `device_id` 在记录中大量为 NULL，该索引收益会变小；建议业务上尽量填充 device_id。

## idx_hps_habitat_species（HabitatPrimarySpecies(habitat_id, species_id)）
- 解决什么业务问题：加速 `Habitat <-> Species` 的多对多联表（按栖息地查主要物种、统计每栖息地物种数）。
- 适用范围/什么时候用：`WHERE habitat_id=?` 的物种清单；或对全部栖息地做物种数量聚合。
- 注意事项/限制条件：如果查询只按 `species_id` 反查栖息地（`WHERE species_id=?`），建议再补一个 `(species_id, habitat_id)` 索引。
