/* =====================================================
   10_biodiversity_queries.sql  (MySQL 8.0+)
   生物多样性模块：复杂查询（每条 2 种实现）+ EXPLAIN ANALYZE

   说明：
   - 本文件所有复杂 SQL 都使用 EXPLAIN ANALYZE（会真实执行 SQL）
   - 依据当前 DDL：MonitoringRecord.status ∈ ('valid','to_verify')
     * 'to_verify' 对应“待核实/待复查”队列（鲁棒图中的 pending）
   - 执行前请确保已：
     USE national_park_db;
   ===================================================== */

USE national_park_db;

-- =====================================================
-- Q1. 待核实监测记录列表（对应鲁棒图：Recheck Monitoring Record / Pending list）
-- 目标：给生态监测员展示最近 30 天 status='to_verify' 的记录，
--      带上物种、栖息地、记录人信息，按时间倒序。
-- 涉及表：MonitoringRecord + Species + Habitat + User（4 表）
-- =====================================================

-- Q1-A：直接多表 JOIN
EXPLAIN ANALYZE
SELECT
  mr.record_id,
  mr.monitoring_time,
  mr.monitoring_method,
  mr.count_number,
  mr.behavior_description,
  mr.longitude, mr.latitude,
  mr.status,
  s.species_id,
  s.species_name_cn,
  s.protection_level,
  h.habitat_id,
  h.area_name,
  u.user_id AS recorder_id,
  u.user_name AS recorder_name
FROM MonitoringRecord mr
JOIN Species s            ON s.species_id = mr.species_id
LEFT JOIN Habitat h       ON h.habitat_id = s.habitat_id
LEFT JOIN User u          ON u.user_id = mr.recorder_id
WHERE mr.status = 'to_verify'
  AND mr.monitoring_time >= (NOW() - INTERVAL 30 DAY)
ORDER BY mr.monitoring_time DESC, mr.record_id
LIMIT 50;

-- Q1-B：CTE + EXISTS（避免不必要的宽 JOIN，适合只筛选后再取维表信息）
EXPLAIN ANALYZE
WITH pending AS (
  SELECT mr.record_id, mr.species_id, mr.recorder_id, mr.monitoring_time,
         mr.monitoring_method, mr.count_number, mr.behavior_description,
         mr.longitude, mr.latitude, mr.status
  FROM MonitoringRecord mr
  WHERE mr.status = 'to_verify'
    AND mr.monitoring_time >= (NOW() - INTERVAL 30 DAY)
)
SELECT
  p.record_id,
  p.monitoring_time,
  p.monitoring_method,
  p.count_number,
  p.behavior_description,
  p.longitude, p.latitude,
  p.status,
  s.species_id,
  s.species_name_cn,
  s.protection_level,
  h.habitat_id,
  h.area_name,
  u.user_id AS recorder_id,
  u.user_name AS recorder_name
FROM pending p
JOIN Species s ON s.species_id = p.species_id
LEFT JOIN Habitat h ON h.habitat_id = s.habitat_id
LEFT JOIN User u ON u.user_id = p.recorder_id
WHERE EXISTS (
  SELECT 1
  FROM Species sx
  WHERE sx.species_id = p.species_id
)
ORDER BY p.monitoring_time DESC, p.record_id
LIMIT 50;

-- =====================================================
-- Q2. 栖息地—物种监测活跃度统计（用于报表：物种保护级别/栖息地分布/监测活跃度）
-- 目标：统计每个区域-栖息地下，各物种近 90 天监测次数、有效次数、待核实次数，
--      并只保留监测次数 >= 2 的组合，按总次数倒序。
-- 涉及表：Region + Habitat + Species + MonitoringRecord（4 表）
-- =====================================================

-- Q2-A：条件聚合（conditional aggregation）
EXPLAIN ANALYZE
SELECT
  r.region_id,
  r.region_name,
  h.habitat_id,
  h.area_name,
  s.species_id,
  s.species_name_cn,
  s.protection_level,
  COUNT(*) AS total_records_90d,
  SUM(mr.status = 'valid')     AS valid_records_90d,
  SUM(mr.status = 'to_verify') AS to_verify_records_90d,
  MIN(mr.monitoring_time) AS first_seen_time,
  MAX(mr.monitoring_time) AS last_seen_time
FROM MonitoringRecord mr
JOIN Species s       ON s.species_id = mr.species_id
LEFT JOIN Habitat h  ON h.habitat_id = s.habitat_id
LEFT JOIN Region r   ON r.region_id = h.region_id
WHERE mr.monitoring_time >= (NOW() - INTERVAL 90 DAY)
GROUP BY r.region_id, r.region_name, h.habitat_id, h.area_name,
         s.species_id, s.species_name_cn, s.protection_level
HAVING COUNT(*) >= 2
ORDER BY total_records_90d DESC, last_seen_time DESC
LIMIT 50;

-- Q2-B：窗口函数做“每个栖息地 Top 3 物种”（另一种实现，适合做榜单）
EXPLAIN ANALYZE
WITH agg AS (
  SELECT
    h.habitat_id,
    h.area_name,
    r.region_id,
    r.region_name,
    s.species_id,
    s.species_name_cn,
    s.protection_level,
    COUNT(*) AS total_records_90d,
    SUM(mr.status = 'valid') AS valid_records_90d
  FROM MonitoringRecord mr
  JOIN Species s      ON s.species_id = mr.species_id
  LEFT JOIN Habitat h ON h.habitat_id = s.habitat_id
  LEFT JOIN Region r  ON r.region_id = h.region_id
  WHERE mr.monitoring_time >= (NOW() - INTERVAL 90 DAY)
  GROUP BY h.habitat_id, h.area_name, r.region_id, r.region_name,
           s.species_id, s.species_name_cn, s.protection_level
),
ranked AS (
  SELECT
    a.*,
    ROW_NUMBER() OVER (
      PARTITION BY a.habitat_id
      ORDER BY a.total_records_90d DESC, a.valid_records_90d DESC, a.species_id
    ) AS rn
  FROM agg a
)
SELECT *
FROM ranked
WHERE rn <= 3
ORDER BY region_id, habitat_id, rn;

-- =====================================================
-- Q3. 设备来源与待核实比例（对应“上传监测记录”用例的设备来源追踪）
-- 目标：按 区域 + 设备类型 统计近 30 天的记录量、待核实比例、最近采集时间，
--      只显示记录量 >= 3 的组合。
-- 涉及表：MonitoringDevice + Region + MonitoringRecord（3 表）
-- =====================================================

-- Q3-A：一次 GROUP BY + 条件聚合
EXPLAIN ANALYZE
SELECT
  r.region_id,
  r.region_name,
  d.device_type,
  COUNT(mr.record_id) AS total_records_30d,
  SUM(mr.status = 'to_verify') AS to_verify_records_30d,
  ROUND(SUM(mr.status = 'to_verify') / NULLIF(COUNT(mr.record_id),0), 4) AS to_verify_ratio_30d,
  MAX(mr.monitoring_time) AS last_record_time
FROM MonitoringDevice d
JOIN Region r ON r.region_id = d.region_id
LEFT JOIN MonitoringRecord mr
  ON mr.device_id = d.device_id
 AND mr.monitoring_time >= (NOW() - INTERVAL 30 DAY)
GROUP BY r.region_id, r.region_name, d.device_type
HAVING total_records_30d >= 3
ORDER BY to_verify_ratio_30d DESC, total_records_30d DESC;

-- Q3-B：先聚合 MonitoringRecord，再回连维表（更利于优化索引/减少 JOIN 扫描）
EXPLAIN ANALYZE
WITH mr_agg AS (
  SELECT
    mr.device_id,
    COUNT(*) AS total_records_30d,
    SUM(mr.status = 'to_verify') AS to_verify_records_30d,
    MAX(mr.monitoring_time) AS last_record_time
  FROM MonitoringRecord mr
  WHERE mr.monitoring_time >= (NOW() - INTERVAL 30 DAY)
    AND mr.device_id IS NOT NULL
  GROUP BY mr.device_id
)
SELECT
  r.region_id,
  r.region_name,
  d.device_type,
  SUM(a.total_records_30d) AS total_records_30d,
  SUM(a.to_verify_records_30d) AS to_verify_records_30d,
  ROUND(SUM(a.to_verify_records_30d) / NULLIF(SUM(a.total_records_30d),0), 4) AS to_verify_ratio_30d,
  MAX(a.last_record_time) AS last_record_time
FROM mr_agg a
JOIN MonitoringDevice d ON d.device_id = a.device_id
JOIN Region r ON r.region_id = d.region_id
GROUP BY r.region_id, r.region_name, d.device_type
HAVING total_records_30d >= 3
ORDER BY to_verify_ratio_30d DESC, total_records_30d DESC;

-- =====================================================
-- Q4. 栖息地适宜性 × 主物种 × 监测有效记录（用于“栖息地适宜性分析”报告）
-- 目标：对每个栖息地计算：
--      1) 环境适宜性评分
--      2) 主物种数量（HabitatPrimarySpecies.is_primary = 1）
--      3) 近 90 天有效(valid)监测记录数
--      并按 “适宜性高且有效记录多” 排序。
-- 涉及表：Habitat + HabitatPrimarySpecies + Species + MonitoringRecord（4 表）
-- =====================================================

-- Q4-A：直接多表 LEFT JOIN + COUNT DISTINCT
EXPLAIN ANALYZE
SELECT
  h.habitat_id,
  h.area_name,
  h.ecological_type,
  h.environment_suitability_score,
  COUNT(DISTINCT CASE WHEN hps.is_primary = 1 THEN hps.species_id END) AS primary_species_cnt,
  COUNT(DISTINCT CASE
      WHEN mr.status = 'valid'
       AND mr.monitoring_time >= (NOW() - INTERVAL 90 DAY)
      THEN mr.record_id
  END) AS valid_records_90d
FROM Habitat h
LEFT JOIN HabitatPrimarySpecies hps ON hps.habitat_id = h.habitat_id
LEFT JOIN Species s ON s.species_id = hps.species_id
LEFT JOIN MonitoringRecord mr ON mr.species_id = s.species_id
GROUP BY h.habitat_id, h.area_name, h.ecological_type, h.environment_suitability_score
ORDER BY h.environment_suitability_score DESC, valid_records_90d DESC, primary_species_cnt DESC
LIMIT 20;

-- Q4-B：分别聚合后再回连（避免 COUNT DISTINCT 带来的去重成本）
EXPLAIN ANALYZE
WITH primary_cnt AS (
  SELECT
    hps.habitat_id,
    COUNT(*) AS primary_species_cnt
  FROM HabitatPrimarySpecies hps
  WHERE hps.is_primary = 1
  GROUP BY hps.habitat_id
),
valid_cnt AS (
  SELECT
    s.habitat_id,
    COUNT(*) AS valid_records_90d
  FROM MonitoringRecord mr
  JOIN Species s ON s.species_id = mr.species_id
  WHERE mr.status = 'valid'
    AND mr.monitoring_time >= (NOW() - INTERVAL 90 DAY)
    AND s.habitat_id IS NOT NULL
  GROUP BY s.habitat_id
)
SELECT
  h.habitat_id,
  h.area_name,
  h.ecological_type,
  h.environment_suitability_score,
  COALESCE(pc.primary_species_cnt, 0) AS primary_species_cnt,
  COALESCE(vc.valid_records_90d, 0)   AS valid_records_90d
FROM Habitat h
LEFT JOIN primary_cnt pc ON pc.habitat_id = h.habitat_id
LEFT JOIN valid_cnt vc   ON vc.habitat_id = h.habitat_id
ORDER BY h.environment_suitability_score DESC, valid_records_90d DESC, primary_species_cnt DESC
LIMIT 20;

-- =====================================================
-- Q5. 监测员工作量 & 待核实积压（对应鲁棒图：Upload → Pending → Validate）
-- 目标：统计每位生态监测员在近 30 天：
--      1) 上传记录数
--      2) 待核实(to_verify)数
--      3) 其记录涉及的“保护级别为 national_first”的占比
--      并给出其主要活动区域（按记录数最多的 region）。
-- 涉及表：MonitoringRecord + User + Species + Habitat + Region（5 表）
-- =====================================================

-- Q5-A：多表 JOIN + 条件聚合
EXPLAIN ANALYZE
SELECT
  u.user_id,
  u.user_name,
  u.role,
  r.region_id,
  r.region_name,
  COUNT(*) AS total_records_30d,
  SUM(mr.status = 'to_verify') AS to_verify_records_30d,
  SUM(s.protection_level = 'national_first') AS first_class_records_30d,
  ROUND(
    SUM(s.protection_level = 'national_first') / NULLIF(COUNT(*),0),
    4
  ) AS first_class_ratio_30d,
  MAX(mr.monitoring_time) AS last_upload_time
FROM MonitoringRecord mr
JOIN User u       ON u.user_id = mr.recorder_id
JOIN Species s    ON s.species_id = mr.species_id
LEFT JOIN Habitat h ON h.habitat_id = s.habitat_id
LEFT JOIN Region r  ON r.region_id = h.region_id
WHERE mr.monitoring_time >= (NOW() - INTERVAL 30 DAY)
  AND u.role = 'ecological_monitor'
GROUP BY u.user_id, u.user_name, u.role, r.region_id, r.region_name
HAVING total_records_30d >= 2
ORDER BY to_verify_records_30d DESC, total_records_30d DESC, first_class_ratio_30d DESC;

-- Q5-B：先算“每人主要区域”，再回连做汇总（另一种实现）
EXPLAIN ANALYZE
WITH base AS (
  SELECT
    mr.recorder_id,
    s.protection_level,
    mr.status,
    mr.monitoring_time,
    h.region_id
  FROM MonitoringRecord mr
  JOIN Species s ON s.species_id = mr.species_id
  LEFT JOIN Habitat h ON h.habitat_id = s.habitat_id
  WHERE mr.monitoring_time >= (NOW() - INTERVAL 30 DAY)
),
top_region AS (
  SELECT recorder_id, region_id
  FROM (
    SELECT
      recorder_id,
      region_id,
      COUNT(*) AS cnt,
      ROW_NUMBER() OVER (PARTITION BY recorder_id ORDER BY COUNT(*) DESC, region_id) AS rn
    FROM base
    GROUP BY recorder_id, region_id
  ) x
  WHERE rn = 1
),
agg AS (
  SELECT
    b.recorder_id,
    COUNT(*) AS total_records_30d,
    SUM(b.status = 'to_verify') AS to_verify_records_30d,
    SUM(b.protection_level = 'national_first') AS first_class_records_30d,
    MAX(b.monitoring_time) AS last_upload_time
  FROM base b
  GROUP BY b.recorder_id
)
SELECT
  u.user_id,
  u.user_name,
  u.role,
  tr.region_id,
  r.region_name,
  a.total_records_30d,
  a.to_verify_records_30d,
  a.first_class_records_30d,
  ROUND(a.first_class_records_30d / NULLIF(a.total_records_30d,0), 4) AS first_class_ratio_30d,
  a.last_upload_time
FROM agg a
JOIN User u ON u.user_id = a.recorder_id
LEFT JOIN top_region tr ON tr.recorder_id = a.recorder_id
LEFT JOIN Region r ON r.region_id = tr.region_id
WHERE u.role = 'ecological_monitor'
  AND a.total_records_30d >= 2
ORDER BY a.to_verify_records_30d DESC, a.total_records_30d DESC, first_class_ratio_30d DESC;

-- END
