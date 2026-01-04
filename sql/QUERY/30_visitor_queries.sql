-- 游客管理系统复杂SQL查询
-- 包含至少3表连接，含聚合/条件/排序（至少两类）
-- 每条SQL提供2种实现方式并记录耗时

-- 查询1: 获取每个区域的游客轨迹数量、平均停留时长和偏离路线统计
-- 方法1: 使用子查询和聚合函数
EXPLAIN ANALYZE
SELECT
    fc.region_id,
    fc.flow_status,
    COUNT(vt.trajectory_id) as trajectory_count,
    AVG(TIMESTAMPDIFF(MINUTE, v.entry_time, v.exit_time)) as avg_stay_minutes,
    SUM(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_count,
    COUNT(DISTINCT vt.visitor_id) as unique_visitors
FROM FlowControl fc
LEFT JOIN VisitorTrajectory vt ON fc.region_id = vt.region_id
LEFT JOIN Visitor v ON vt.visitor_id = v.visitor_id
GROUP BY fc.region_id, fc.flow_status
HAVING trajectory_count > 0
ORDER BY trajectory_count DESC, avg_stay_minutes DESC;

-- 方法2: 使用窗口函数和CTE
EXPLAIN ANALYZE
WITH trajectory_stats AS (
    SELECT
        fc.region_id,
        fc.flow_status,
        vt.visitor_id,
        vt.trajectory_id,
        vt.is_out_of_route,
        v.entry_time,
        v.exit_time,
        TIMESTAMPDIFF(MINUTE, v.entry_time, v.exit_time) as stay_minutes
    FROM FlowControl fc
    LEFT JOIN VisitorTrajectory vt ON fc.region_id = vt.region_id
    LEFT JOIN Visitor v ON vt.visitor_id = v.visitor_id
),
region_agg AS (
    SELECT
        region_id,
        flow_status,
        COUNT(trajectory_id) as trajectory_count,
        AVG(stay_minutes) as avg_stay_minutes,
        SUM(CASE WHEN is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_count,
        COUNT(DISTINCT visitor_id) as unique_visitors
    FROM trajectory_stats
    GROUP BY region_id, flow_status
)
SELECT * FROM region_agg
WHERE trajectory_count > 0
ORDER BY trajectory_count DESC, avg_stay_minutes DESC;

-- 查询2: 获取预约状态为确认的游客的详细信息、预约统计和轨迹偏离情况
-- 方法1: 直接JOIN和聚合
EXPLAIN ANALYZE
SELECT
    v.visitor_id,
    v.visitor_name,
    v.contact_number,
    r.reservation_date,
    r.entry_time_slot,
    r.group_size,
    r.ticket_amount,
    COUNT(vt.trajectory_id) as trajectory_count,
    AVG(vt.is_out_of_route) as avg_out_of_route_rate,
    MAX(vt.location_time) as last_location_time
FROM Visitor v
INNER JOIN Reservation r ON v.visitor_id = r.visitor_id
LEFT JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
WHERE r.reservation_status = 'CONFIRMED'
GROUP BY v.visitor_id, v.visitor_name, v.contact_number, r.reservation_date, r.entry_time_slot, r.group_size, r.ticket_amount
ORDER BY r.reservation_date DESC, r.ticket_amount DESC
LIMIT 10;

-- 方法2: 使用EXISTS子查询和窗口函数
EXPLAIN ANALYZE
SELECT
    v.visitor_id,
    v.visitor_name,
    v.contact_number,
    r.reservation_date,
    r.entry_time_slot,
    r.group_size,
    r.ticket_amount,
    trajectory_stats.trajectory_count,
    trajectory_stats.avg_out_of_route_rate,
    trajectory_stats.last_location_time
FROM Visitor v
INNER JOIN Reservation r ON v.visitor_id = r.visitor_id
LEFT JOIN (
    SELECT
        visitor_id,
        COUNT(trajectory_id) as trajectory_count,
        AVG(is_out_of_route) as avg_out_of_route_rate,
        MAX(location_time) as last_location_time
    FROM VisitorTrajectory
    GROUP BY visitor_id
) trajectory_stats ON v.visitor_id = trajectory_stats.visitor_id
WHERE EXISTS (
    SELECT 1 FROM Reservation r2
    WHERE r2.visitor_id = v.visitor_id
    AND r2.reservation_status = 'CONFIRMED'
)
ORDER BY r.reservation_date DESC, r.ticket_amount DESC
LIMIT 10;

-- 查询3: 获取各区域流量状态统计和预约趋势分析
-- 方法1: 使用多表JOIN和聚合
EXPLAIN ANALYZE
SELECT
    fc.region_id,
    fc.flow_status,
    fc.daily_capacity,
    fc.current_visitor_count,
    fc.warning_threshold,
    COUNT(r.reservation_id) as reservation_count,
    SUM(r.ticket_amount) as total_revenue,
    AVG(r.group_size) as avg_group_size,
    COUNT(DISTINCT vt.visitor_id) as visitors_with_trajectory
FROM FlowControl fc
LEFT JOIN VisitorTrajectory vt ON fc.region_id = vt.region_id
LEFT JOIN Visitor v ON vt.visitor_id = v.visitor_id
LEFT JOIN Reservation r ON v.visitor_id = r.visitor_id AND r.reservation_status = 'CONFIRMED'
GROUP BY fc.region_id, fc.flow_status, fc.daily_capacity, fc.current_visitor_count, fc.warning_threshold
HAVING total_revenue > 0 OR reservation_count > 0
ORDER BY fc.daily_capacity DESC, total_revenue DESC;

-- 方法2: 使用CTE和UNION ALL
EXPLAIN ANALYZE
WITH region_reservation_stats AS (
    SELECT
        fc.region_id,
        fc.flow_status,
        fc.daily_capacity,
        fc.current_visitor_count,
        fc.warning_threshold,
        COUNT(r.reservation_id) as reservation_count,
        SUM(r.ticket_amount) as total_revenue,
        AVG(r.group_size) as avg_group_size,
        COUNT(DISTINCT vt.visitor_id) as visitors_with_trajectory
    FROM FlowControl fc
    LEFT JOIN VisitorTrajectory vt ON fc.region_id = vt.region_id
    LEFT JOIN Visitor v ON vt.visitor_id = v.visitor_id
    LEFT JOIN Reservation r ON v.visitor_id = r.visitor_id AND r.reservation_status = 'CONFIRMED'
    GROUP BY fc.region_id, fc.flow_status, fc.daily_capacity, fc.current_visitor_count, fc.warning_threshold
)
SELECT * FROM region_reservation_stats
WHERE total_revenue > 0 OR reservation_count > 0
ORDER BY daily_capacity DESC, total_revenue DESC;

-- 查询4: 获取游客轨迹偏离路线的详细统计和支付状态分析
-- 方法1: 使用多表连接和条件聚合
EXPLAIN ANALYZE
SELECT
    v.visitor_id,
    v.visitor_name,
    v.entry_time,
    v.exit_time,
    r.payment_status,
    r.reservation_status,
    COUNT(vt.trajectory_id) as total_trajectories,
    SUM(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_count,
    AVG(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_rate,
    MIN(vt.location_time) as first_location_time,
    MAX(vt.location_time) as last_location_time
FROM Visitor v
INNER JOIN Reservation r ON v.visitor_id = r.visitor_id
LEFT JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
WHERE vt.is_out_of_route = 1 OR vt.trajectory_id IS NOT NULL
GROUP BY v.visitor_id, v.visitor_name, v.entry_time, v.exit_time, r.payment_status, r.reservation_status
HAVING out_of_route_count > 0
ORDER BY out_of_route_count DESC, out_of_route_rate DESC
LIMIT 15;

-- 方法2: 使用子查询和条件判断
EXPLAIN ANALYZE
SELECT
    visitor_stats.visitor_id,
    visitor_stats.visitor_name,
    visitor_stats.entry_time,
    visitor_stats.exit_time,
    visitor_stats.payment_status,
    visitor_stats.reservation_status,
    visitor_stats.total_trajectories,
    visitor_stats.out_of_route_count,
    visitor_stats.out_of_route_rate,
    visitor_stats.first_location_time,
    visitor_stats.last_location_time
FROM (
    SELECT
        v.visitor_id,
        v.visitor_name,
        v.entry_time,
        v.exit_time,
        r.payment_status,
        r.reservation_status,
        COUNT(vt.trajectory_id) as total_trajectories,
        SUM(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_count,
        AVG(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_rate,
        MIN(vt.location_time) as first_location_time,
        MAX(vt.location_time) as last_location_time
    FROM Visitor v
    INNER JOIN Reservation r ON v.visitor_id = r.visitor_id
    LEFT JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
    WHERE vt.is_out_of_route = 1 OR vt.trajectory_id IS NOT NULL
    GROUP BY v.visitor_id, v.visitor_name, v.entry_time, v.exit_time, r.payment_status, r.reservation_status
) visitor_stats
WHERE visitor_stats.out_of_route_count > 0
ORDER BY out_of_route_count DESC, out_of_route_rate DESC
LIMIT 15;

-- 查询5: 获取各时间段游客流量趋势和区域承载分析
-- 方法1: 使用时间分组和多表聚合
EXPLAIN ANALYZE
SELECT
    DATE(vt.location_time) as visit_date,
    HOUR(vt.location_time) as visit_hour,
    fc.flow_status,
    fc.daily_capacity,
    COUNT(DISTINCT vt.visitor_id) as unique_visitors,
    COUNT(vt.trajectory_id) as total_trajectories,
    AVG(fc.current_visitor_count) as avg_current_count,
    SUM(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_trajectories,
    AVG(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_rate
FROM VisitorTrajectory vt
INNER JOIN FlowControl fc ON vt.region_id = fc.region_id
INNER JOIN Visitor v ON vt.visitor_id = v.visitor_id
WHERE vt.location_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(vt.location_time), HOUR(vt.location_time), fc.flow_status, fc.daily_capacity
ORDER BY visit_date DESC, visit_hour ASC
LIMIT 20;

-- 方法2: 使用窗口函数和时间维度分析
EXPLAIN ANALYZE
SELECT
    visit_summary.visit_date,
    visit_summary.visit_hour,
    visit_summary.flow_status,
    visit_summary.daily_capacity,
    visit_summary.unique_visitors,
    visit_summary.total_trajectories,
    visit_summary.avg_current_count,
    visit_summary.out_of_route_trajectories,
    visit_summary.out_of_route_rate
FROM (
    SELECT
        DATE(vt.location_time) as visit_date,
        HOUR(vt.location_time) as visit_hour,
        fc.flow_status,
        fc.daily_capacity,
        COUNT(DISTINCT vt.visitor_id) as unique_visitors,
        COUNT(vt.trajectory_id) as total_trajectories,
        AVG(fc.current_visitor_count) as avg_current_count,
        SUM(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_trajectories,
        AVG(CASE WHEN vt.is_out_of_route = 1 THEN 1 ELSE 0 END) as out_of_route_rate,
        ROW_NUMBER() OVER (ORDER BY DATE(vt.location_time) DESC, HOUR(vt.location_time) ASC) as rn
    FROM VisitorTrajectory vt
    INNER JOIN FlowControl fc ON vt.region_id = fc.region_id
    INNER JOIN Visitor v ON vt.visitor_id = v.visitor_id
    WHERE vt.location_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY DATE(vt.location_time), HOUR(vt.location_time), fc.flow_status, fc.daily_capacity
) visit_summary
WHERE rn <= 20
ORDER BY visit_date DESC, visit_hour ASC;