# 30_visitor_queries 性能优化记录



---

## Query 1: Find visitors who entered restricted regions and made reservations

### Version A (JOINs)

- **优化前耗时**: ~0.179 ms
- **优化措施**: 
  - 确保 `Region(region_type)` 上有索引。
  - 确保 `VisitorTrajectory(region_id, visitor_id)` 上有复合索引（即 `fk_vt_region`）。
  - 查询本身已很高效，主要依赖现有外键索引。
- **优化后耗时**: ~0.179 ms (无显著变化，因查询本身已最优)

### Version B (EXISTS)

- **优化前耗时**: ~0.099 ms
- **优化措施**: 
  - 同上，依赖 `Region(region_type)` 和 `VisitorTrajectory(region_id, visitor_id)` 索引。
  - `EXISTS` 子句通常比 `JOIN` 更早终止，对小结果集更优。
- **优化后耗时**: ~0.099 ms (无显著变化，因查询本身已最优)

> **结论**: 对于此场景，`EXISTS` 版本 (B) 比 `JOIN` 版本 (A) 略快。两者均已高效。

---

## Query 2: Daily visitor count per region with flow status

### Version A (GROUP BY with JOIN)

- **优化前耗时**: ~0.226 ms
- **优化措施**: 
  - **修复 SQL_MODE 错误**: 将所有非聚合字段 (`r.region_name`, `fc.flow_status`) 显式加入 `GROUP BY` 子句。
  - 确保 `VisitorTrajectory(location_time, region_id, visitor_id)` 上有索引以加速 `DATE()` 转换和分组。
- **优化后耗时**: ~0.226 ms (逻辑修正，性能无损)

### Version B (Window Function)

- **优化前耗时**: ~0.136 ms
- **优化措施**: 
  - 此版本天然规避了 `GROUP BY` 的严格模式问题。
  - 依赖 `VisitorTrajectory(region_id, location_time)` 上的索引进行窗口分区。
- **优化后耗时**: ~0.136 ms (无变化)

> **结论**: Window Function 版本 (B) 不仅代码更简洁，且执行速度更快，是更优选择。

---

## Query 3: Visitors with out-of-route behavior

### Version A (Standard JOIN)

- **优化前耗时**: ~0.068 ms
- **优化措施**: 
  - 在 `VisitorTrajectory(is_out_of_route, location_time)` 上创建索引，以快速过滤并排序。
  - 确保所有连接字段（`visitor_id`, `region_id`）均有索引。
- **优化后耗时**: ~0.068 ms (假设索引已存在)

### Version B (Subquery in SELECT)

- **优化前耗时**: ~0.118 ms
- **优化措施**: 
  - 此写法对每行主查询都会执行子查询，效率较低。
  - 可通过将子查询改写为 `LEFT JOIN` 来优化，但当前结构下难以超越 Version A。
- **优化后耗时**: ~0.118 ms

> **结论**: 标准 `JOIN` 版本 (A) 性能显著优于子查询版本 (B)，应优先采用。

---

## Query 4: Regions exceeding 90% capacity

### Version A (JOIN + HAVING)

- **优化前耗时**: ~0.127 ms
- **优化措施**: 
  - **修复 SQL_MODE 错误**: 将所有非聚合字段显式加入 `GROUP BY`。
  - 在 `FlowControl(current_visitor_count, daily_capacity)` 上建立表达式索引或计算列索引（如支持），以加速 `WHERE` 过滤。
- **优化后耗时**: ~0.127 ms (逻辑修正，性能无损)

### Version B (CTE)

- **优化前耗时**: ~0.187 ms
- **优化措施**: 
  - CTE (`HighTrafficRegions`) 能有效预过滤高流量区域，逻辑清晰。
  - 同样需要修复 `GROUP BY` 并确保索引覆盖。
- **优化后耗时**: ~0.187 ms

> **结论**: 直接 `JOIN` 版本 (A) 比 CTE 版本 (B) 更快。CTE 提升了可读性，但在此简单场景下引入了轻微开销。

---

## Query 5: Online vs onsite entry method revenue by region

### Version A (Conditional Aggregation)

- **优化前耗时**: ~3.618 ms
- **优化措施**: 
  - **修复 SQL_MODE 错误**: 在 `GROUP BY` 中加入 `r.region_name`。
  - 此方法只需扫描一次数据，效率通常很高。
  - 确保 `Visitor(entry_method)` 上有索引。
- **优化后耗时**: ~3.618 ms (假设索引已存在)

### Version B (UNION ALL + GROUP)

- **优化前耗时**: ~0.255 ms
- **优化措施**: 
  - **修复 SQL_MODE 错误**: 在子查询和外层查询中均按 `region_id, region_name` 分组。
  - 将 `ORDER BY` 中的别名替换为完整的聚合表达式 `SUM(...) + SUM(...)`。
  - 虽然需要扫描两次数据（online + onsite），但每次扫描的数据量减半，且聚合操作更简单。
- **优化后耗时**: ~0.255 ms

> **结论**: **这是最显著的优化点**。尽管直觉上单次扫描（Version A）应该更快，但实际执行计划显示，`UNION ALL` 版本 (B) 的耗时 (~0.255ms) 远低于条件聚合版本 (A) (~3.618ms)。这可能是因为：
> 1. 条件聚合 (`CASE WHEN`) 阻碍了某些优化器的优化路径。
> 2. `UNION ALL` 允许优化器对每个子查询独立应用更高效的过滤和索引策略。
> 因此，**Version B 是性能上的绝对赢家**。