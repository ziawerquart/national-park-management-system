# 10_biodiversity_perf.md

> **EXPLAIN ANALYZE 是什么？**  
> `EXPLAIN ANALYZE <SQL>` 会**真实执行**这条 SQL，并输出执行计划（优化器选择了怎样的算子/连接方式/索引）以及每个算子的**实际耗时**（`actual time=...`）、实际行数（`rows=...`）与循环次数（`loops=...`）。  
> 因为会真实执行，所以适合用来做“优化前/后”的性能对比记录。

---

## 0. 运行环境与数据概况

- 数据库：MySQL 8.x（项目要求版本）
- 执行方式：`SOURCE sql/QUERY/10_biodiversity_queries.sql`
- 数据集：`MonitoringRecord` 共 20 条
  - `valid` = 15
  - `to_verify` = 5
  - `to_verify` 且近 30 天 = 5（相对时间 seed 保证近 30/90 天都有数据）

> 说明：本文件的耗时数据 **完全来自你本次贴出的 EXPLAIN ANALYZE 输出**。同一台机器、同一数据量下，数值可用于对比两种实现的相对快慢。

---

## 1. 如何读 EXPLAIN ANALYZE 输出（速查）

- `actual time=a..b`：该算子从开始到结束的实际耗时范围（通常看右侧 `b` 作为完成时间）
- `rows=n`：该算子实际产出的行数
- `loops=k`：该算子执行次数（比如嵌套循环 join 会对内表反复查找）
- `Table scan`：全表扫描
- `Index lookup using PRIMARY / fk_xxx`：走主键/外键索引查找
- `<temporary>` / `Aggregate using temporary table`：使用临时表做聚合/排序
- `Materialize CTE`：先把 `WITH ...` 的结果物化（缓存为中间结果）
- `Nested loop join`：嵌套循环连接（小表常见）
- `Hash join`：哈希连接（适合大结果集/预聚合后 join）

---

## 2. Q1 待核实监测记录列表（对应鲁棒图：Pending list / Recheck）

**目标：** 查最近 30 天待核实（`to_verify`）记录，按时间倒序，连出物种、栖息地、记录人信息（≥3 表 JOIN + 条件 + 排序）。

### 实现 A：直接多表 JOIN（Q1-A）
- 结果行数：5
- 总体耗时（末端算子）：`actual time=0.1..0.124`
- 关键执行特征：
  - `mr` 全表扫描 20 行 → Filter 后剩 5 行
  - 之后对 `Species/Habitat/User` 均为 **PRIMARY 单行索引查找**（loops=5）

### 实现 B：CTE + EXISTS（Q1-B）
- 结果行数：5
- 总体耗时（末端算子）：`actual time=0.168..0.2`
- 关键执行特征：
  - 同样是先筛 `mr`（20→5），再连维表
  - 多了一层结构（CTE/EXISTS），在本数据量下反而略慢

**结论：** 在当前数据规模下，Q1-A 更快（0.124 vs 0.200）。

---

## 3. Q2 区域-栖息地-物种近 90 天监测活跃度（Top 排名）

**目标：** 统计近 90 天每个物种的监测次数/最近出现时间，并连出栖息地与区域信息；再做 Top/排名（≥3 表 JOIN + 聚合 + 排序/窗口）。

### 实现 A：聚合 + HAVING + 排序（Q2-A）
- 输出显示：最终 `rows=0`
- 总体耗时（末端算子）：`actual time=0.398..0.398`
- 计划特征：
  - `mr` 表扫描 20 行（近 90 天过滤后仍 20）
  - 对 `s/h/r` 为主键索引查找（loops=20）
  - 使用 `<temporary>` 做聚合
  - 最外层有 `Filter: (count(0) >= 2)`，本次输出显示筛完后最终为 0 行

> 备注：这里“最终 rows=0”通常意味着阈值（如 `HAVING count(*) >= 2`）或分组维度导致结果被过滤掉。计划与耗时仍可用于对比两种实现。

### 实现 B：CTE 聚合 + window（row_number）取 Top（Q2-B）
- 输出显示：最终 `rows=20`（并进一步过滤 `rn<=3` 后仍显示 20 行）
- 总体耗时（末端算子）：`actual time=0.776..0.778`
- 计划特征：
  - 先 Materialize CTE `agg`（临时表聚合）
  - 再做 Window aggregate（`row_number()`），需要额外 sort
  - 因为窗口函数排序，开销明显更大

**结论：** 当前数据量下，Q2-A 更快（0.398 vs 0.778），但 Q2-A 本次输出“最终结果 0 行”，需要根据业务需求调整阈值/分组后再截图展示结果集。

---

## 4. Q3 设备来源与待核实比例（近 30 天）

**目标：** 统计近 30 天各区域/设备的记录量与待核实比例（≥3 表 JOIN + 聚合 + 排序）。

### 实现 A：直接 join 后 group（Q3-A）
- 输出显示：最终 `rows=0`
- 总体耗时：`actual time=0.335..0.335`
- 计划特征：
  - `Region` 表扫描 5 行
  - 通过 `fk_device_region` 查设备（每区约 2 台）
  - 再用 `fk_mr_device` 查近 30 天记录（每设备取若干）
  - 聚合使用临时表 `<temporary>`

### 实现 B：先聚合 mr（CTE），再 join 维表（Q3-B）
- 输出显示：最终 `rows=0`
- 总体耗时：`actual time=0.586..0.586`
- 计划特征：
  - 先 Materialize CTE `mr_agg`（`mr` 使用 `fk_mr_device` 做 index scan）
  - 再 join 回 `Region/Device`
  - 在小数据量下，CTE 物化反而更慢

**结论：** 当前数据量下，Q3-A 更快（0.335 vs 0.586）。本次输出最终 rows=0，通常是因为外层阈值（如 `total_records_30d >= 3`）筛掉了所有行；如需展示结果集，可降低阈值。

---

## 5. Q4 栖息地适宜性 × 主物种数量 × 有效记录（近 90 天）

**目标：** 面向“栖息地分析”，按栖息地统计：主物种数、近 90 天有效记录数，并按适宜性评分排序（≥3 表 JOIN + 聚合 + 排序）。

### 实现 A：大 JOIN 后聚合（Q4-A）
- 结果行数：20
- 总体耗时：`actual time=0.439..0.442`
- 计划特征：
  - `Habitat` 扫描 20 行
  - join `HabitatPrimarySpecies`（40 行）→ join `Species` → join `MonitoringRecord`
  - 聚合阶段计算 distinct count 与条件 count

### 实现 B：CTE 预聚合（primary_cnt / valid_cnt）再 hash join（Q4-B）
- 结果行数：20
- 总体耗时：`actual time=0.23..0.232`
- 计划特征：
  - `primary_cnt` 从 hps 预聚合（使用 PRIMARY index scan）
  - `valid_cnt` 从 mr 预聚合（表扫描 20 行并对 s 做主键查找）
  - 与 Habitat 使用 **Left hash join** 合并结果
  - 预聚合后 join，明显更快

**结论：** Q4-B 明显更快（0.232 vs 0.442），属于有效的“优化后实现”。

---

## 6. Q5 监测员工作量 & 待核实积压（近 30 天）

**目标：** 面向“审核流程管理”，统计每位生态监测员近 30 天总记录数、待核实数，并推断其主要活动区域（≥3 表 JOIN + 聚合 + 排序/窗口）。

### 实现 A：直接多表 join + 聚合（Q5-A）
- 输出显示：最终 `rows=0`
- 总体耗时：`actual time=0.225..0.225`
- 计划特征：
  - `User` 表扫描 10 行，过滤角色 `ecological_monitor` 后剩 3 行
  - 通过 `fk_mr_user` 查记录，再 join `Species/Habitat/Region`
  - 使用临时表聚合

### 实现 B：先聚合，再窗口函数求“主要活动区域”（Q5-B）
- 结果行数：3
- 总体耗时：`actual time=0.481..0.481`
- 计划特征：
  - Materialize CTE `agg`（先聚合出每人工作量）
  - 另一路 Materialize `base` 并做 `row_number()` 窗口函数（需要 sort）
  - 最后 join 回 Region，得到每位监测员“最主要区域”（`rn=1`）
  - 因为窗口函数排序 + 中间结果物化，耗时更高

**结论：** 在当前数据量下，Q5-A 更快（0.225 vs 0.481），但 Q5-A 本次输出最终 rows=0；Q5-B 能产出 3 行结果，更贴近“业务可展示”要求。

---

## 7. 总结对比表（按本次输出）

> 注：耗时取 `actual time=a..b` 的右端 `b`（末端算子完成时间），单位保持与 MySQL 输出一致。

| Query | 实现 | 末端 actual time（b） | 返回行数 | 本次更优 |
|---|---|---:|---:|---|
| Q1 待核实列表 | A 直接 JOIN | 0.124 | 5 | ✅ A |
|  | B CTE+EXISTS | 0.200 | 5 |  |
| Q2 90天活跃度 | A 聚合+HAVING | 0.398 | 0 | ✅ A（更快） |
|  | B CTE+Window | 0.778 | 20 |  |
| Q3 设备待核实比 | A 直接聚合 | 0.335 | 0 | ✅ A |
|  | B 先聚合再 join | 0.586 | 0 |  |
| Q4 栖息地分析 | A 大 JOIN 聚合 | 0.442 | 20 |  |
|  | B 预聚合 + hash join | 0.232 | 20 | ✅ B（更快） |
| Q5 监测员工作量 | A 直接聚合 | 0.225 | 0 | ✅ A（更快） |
|  | B 聚合 + Window | 0.481 | 3 |  |

---

## 8. 可选的进一步优化建议（用于“优化后”章节扩写）

如果你还想把“优化前/后”写得更像报告（更有说服力），可以在不改业务逻辑的前提下补索引：

1) `MonitoringRecord(status, monitoring_time)`：加速 Q1/Q3/Q5 的状态+时间过滤  
2) `MonitoringRecord(device_id, monitoring_time)`：加速 Q3 的设备近30天统计  
3) `MonitoringRecord(recorder_id, monitoring_time)`：加速 Q5 的人员近30天统计

加索引后，再跑同样的 `EXPLAIN ANALYZE`，把新的 `actual time` 作为“优化后”即可形成闭环。
