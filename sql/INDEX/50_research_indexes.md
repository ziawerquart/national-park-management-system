# 科研支撑模块索引说明

## idx_project_status_date

**适用范围：** 按项目状态筛选并按审批日期排序的查询。

**典型查询：**
```sql
SELECT * FROM ResearchProject WHERE project_status = 'ongoing' ORDER BY approval_date;
```

---

## idx_project_leader

**适用范围：** 按负责人查询其负责的所有项目。

**典型查询：**
```sql
SELECT * FROM ResearchProject WHERE leader_id = 'U001';
```

---

## idx_record_project_time

**适用范围：** 按时间范围查询某项目的数据记录。

**典型查询：**
```sql
SELECT * FROM ResearchDataRecord WHERE project_id = 'P001' AND collection_time BETWEEN '2024-01-01' AND '2024-12-31';
```

---

## idx_record_collector

**适用范围：** 查询某采集员的所有数据记录。

**典型查询：**
```sql
SELECT * FROM ResearchDataRecord WHERE collector_id = 'U002';
```

---

## idx_record_region

**适用范围：** 按区域筛选数据记录。

**典型查询：**
```sql
SELECT * FROM ResearchDataRecord WHERE region_id = 'R001';
```

---

## idx_achievement_type_permission

**适用范围：** 按成果类型和共享权限筛选成果。

**典型查询：**
```sql
SELECT * FROM ResearchAchievement WHERE achievement_type = 'paper' AND share_permission = 'public';
```
