# 科研支撑模块索引说明

## idx_project_status_time

**适用范围：** 按项目状态筛选并按时间排序的查询。

**典型查询：**
```sql
SELECT * FROM ResearchProject WHERE project_status = 'InProgress' ORDER BY start_time;
```

---

## idx_project_leader

**适用范围：** 按负责人查询其负责的所有项目。

**典型查询：**
```sql
SELECT * FROM ResearchProject WHERE leader_user_id = 'U001';
```

---

## idx_collection_time_project

**适用范围：** 按时间范围查询某项目的采集记录。

**典型查询：**
```sql
SELECT * FROM ResearchDataCollection WHERE project_id = 'P001' AND collection_time BETWEEN '2024-01-01' AND '2024-12-31';
```

---

## idx_result_type_access

**适用范围：** 按成果类型和访问级别筛选成果。

**典型查询：**
```sql
SELECT * FROM ResearchResult WHERE result_type = 'Paper' AND access_level = 'Public';
```

---

## idx_monitor_habitat_species

**适用范围：** 查询特定栖息地中特定物种的监测记录。

**典型查询：**
```sql
SELECT * FROM MonitoringRecord WHERE habitat_id = 'H001' AND species_id = 'S001' ORDER BY monitor_time DESC;
```

---

## idx_species_protection

**适用范围：** 按保护级别筛选物种。

**典型查询：**
```sql
SELECT * FROM Species WHERE protection_level = 'Endangered';
```
