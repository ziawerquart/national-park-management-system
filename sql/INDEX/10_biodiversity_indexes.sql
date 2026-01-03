-- Stage4 INDEXes for Biodiversity line (MySQL 8.0)

-- 1) 加速：待核实列表（status过滤 + 时间倒序）
CREATE INDEX idx_mr_status_time ON MonitoringRecord(status, monitoring_time);

-- 2) 加速：按物种查最近记录（species过滤 + 时间范围/排序）
CREATE INDEX idx_mr_species_time ON MonitoringRecord(species_id, monitoring_time);

-- 3) 加速：按设备查最近记录（device过滤 + 时间范围/排序）/ 区域活跃度（通过设备间接汇总）
CREATE INDEX idx_mr_device_time ON MonitoringRecord(device_id, monitoring_time);

-- 4) 加速：栖息地-物种 N:M 关联查询（按habitat查物种、统计每habitat物种数）
CREATE INDEX idx_hps_habitat_species ON HabitatPrimarySpecies(habitat_id, species_id);

-- （可选）如果你经常从 Species -> Habitat 走联表过滤 region，可再加：
-- CREATE INDEX idx_species_habitat ON Species(habitat_id);
