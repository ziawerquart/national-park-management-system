## 生态环境监测业务线 —— 索引设计与适用范围说明

为提升生态环境监测系统在高并发查询场景下的响应性能，
系统针对生态环境监测业务线中的高频访问字段，
结合典型业务查询模式，设计并建立了专用索引。

---

### 1. idx_ed_region_time（EnvironmentalData）

**适用范围：**
- 按区域查询环境监测数据
- 按时间范围进行实时监控与历史回溯
- 支撑环境监测视图与图表展示

**典型查询示例：**
```sql
SELECT *
FROM EnvironmentalData
WHERE region_id = ?
  AND collect_time BETWEEN ? AND ?; 
```


### 2. idx_ed_indicator_time（EnvironmentalData）

**适用范围：**
- 按监测指标进行时间序列分析
- 支撑环境指标趋势研判与统计分析
- 为科研分析提供高效数据访问能力

**典型查询示例：**
```sql
SELECT *
FROM EnvironmentalData
WHERE indicator_id = ?
  AND collect_time >= ?
  ```


### 3. idx_md_region_status（MonitoringDevice）

**适用范围：**

- 查询指定区域内异常设备（故障 / 离线）
- 支撑设备运维巡检与运行状态监控
- 快速定位问题设备

**典型查询示例：**
```sql
SELECT *
FROM MonitoringDevice
WHERE region_id = ?
  AND run_status <> 'normal';
  ```


### 4. idx_alert_time_level（Alert）

**适用范围：**

- 按时间范围查询告警记录
- 按告警等级筛选重点异常事件
- 支撑管理层决策与应急指挥

**典型查询示例：**
```sql
SELECT *
FROM Alert
WHERE alert_time >= ?
  AND alert_level IN ('high', 'critical');
  ```