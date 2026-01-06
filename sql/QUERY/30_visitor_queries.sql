-- sql/QUERY/30_visitor_queries.sql

-- Query 1: Find visitors who entered restricted regions and made reservations
-- Version A: Using JOINs
EXPLAIN ANALYZE
SELECT
    v.visitor_name,
    r.region_name,
    res.reservation_date,
    res.ticket_amount
FROM Visitor v
JOIN Reservation res ON v.visitor_id = res.visitor_id
JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
JOIN Region r ON vt.region_id = r.region_id
WHERE r.region_type = 'restricted'
ORDER BY res.ticket_amount DESC;

-- Version B: Using EXISTS
EXPLAIN ANALYZE
SELECT
    v.visitor_name,
    (SELECT r.region_name FROM Region r JOIN VisitorTrajectory vt ON r.region_id = vt.region_id WHERE vt.visitor_id = v.visitor_id AND r.region_type = 'restricted' LIMIT 1) AS region_name,
    res.reservation_date,
    res.ticket_amount
FROM Visitor v
JOIN Reservation res ON v.visitor_id = res.visitor_id
WHERE EXISTS (
    SELECT 1 FROM VisitorTrajectory vt
    JOIN Region r ON vt.region_id = r.region_id
    WHERE vt.visitor_id = v.visitor_id AND r.region_type = 'restricted'
)
ORDER BY res.ticket_amount DESC;


-- Query 2: Daily visitor count per region with flow status
-- Version A: GROUP BY with JOIN — FIXED: include all non-aggregate columns in GROUP BY
EXPLAIN ANALYZE
SELECT
    r.region_name,
    fc.flow_status,
    DATE(vt.location_time) AS visit_date,
    COUNT(DISTINCT vt.visitor_id) AS daily_visitors
FROM VisitorTrajectory vt
JOIN Region r ON vt.region_id = r.region_id
JOIN FlowControl fc ON r.region_id = fc.region_id
GROUP BY r.region_id, r.region_name, fc.flow_status, DATE(vt.location_time)
HAVING daily_visitors > 1
ORDER BY visit_date DESC, daily_visitors DESC;

-- Version B: Window function alternative (not better here, but for comparison)
-- This version does NOT use GROUP BY, so it's safe
EXPLAIN ANALYZE
SELECT DISTINCT
    r.region_name,
    fc.flow_status,
    DATE(vt.location_time) AS visit_date,
    COUNT(vt.visitor_id) OVER (PARTITION BY r.region_id, DATE(vt.location_time)) AS daily_visitors
FROM VisitorTrajectory vt
JOIN Region r ON vt.region_id = r.region_id
JOIN FlowControl fc ON r.region_id = fc.region_id
ORDER BY visit_date DESC, daily_visitors DESC;


-- Query 3: Visitors with out-of-route behavior and their reservation details
-- No GROUP BY → no issue
EXPLAIN ANALYZE
SELECT
    v.visitor_name,
    v.contact_number,
    res.entry_time_slot,
    vt.location_time,
    r.region_name
FROM Visitor v
JOIN Reservation res ON v.visitor_id = res.visitor_id
JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
JOIN Region r ON vt.region_id = r.region_id
WHERE vt.is_out_of_route = TRUE
ORDER BY vt.location_time DESC;

-- Version B: Subquery in SELECT — also no GROUP BY
EXPLAIN ANALYZE
SELECT
    v.visitor_name,
    v.contact_number,
    (SELECT entry_time_slot FROM Reservation WHERE visitor_id = v.visitor_id LIMIT 1) AS entry_time_slot,
    vt.location_time,
    (SELECT region_name FROM Region WHERE region_id = vt.region_id) AS region_name
FROM Visitor v
JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
WHERE vt.is_out_of_route = TRUE
ORDER BY vt.location_time DESC;


-- Query 4: Regions exceeding 90% capacity with visitor names
-- Version A: JOIN + HAVING — FIXED: include all non-aggregate in GROUP BY
EXPLAIN ANALYZE
SELECT
    r.region_name,
    fc.current_visitor_count,
    fc.daily_capacity,
    ROUND(fc.current_visitor_count * 100.0 / fc.daily_capacity, 2) AS occupancy_pct,
    GROUP_CONCAT(DISTINCT v.visitor_name ORDER BY v.visitor_name) AS visitors
FROM FlowControl fc
JOIN Region r ON fc.region_id = r.region_id
JOIN VisitorTrajectory vt ON r.region_id = vt.region_id
JOIN Visitor v ON vt.visitor_id = v.visitor_id
WHERE fc.current_visitor_count > 0.9 * fc.daily_capacity
GROUP BY r.region_id, r.region_name, fc.current_visitor_count, fc.daily_capacity
ORDER BY occupancy_pct DESC;

-- Version B: CTE approach — FIXED similarly
EXPLAIN ANALYZE
WITH HighTrafficRegions AS (
    SELECT region_id, current_visitor_count, daily_capacity
    FROM FlowControl
    WHERE current_visitor_count > 0.9 * daily_capacity
)
SELECT
    r.region_name,
    htr.current_visitor_count,
    htr.daily_capacity,
    ROUND(htr.current_visitor_count * 100.0 / htr.daily_capacity, 2) AS occupancy_pct,
    GROUP_CONCAT(DISTINCT v.visitor_name ORDER BY v.visitor_name) AS visitors
FROM HighTrafficRegions htr
JOIN Region r ON htr.region_id = r.region_id
JOIN VisitorTrajectory vt ON r.region_id = vt.region_id
JOIN Visitor v ON vt.visitor_id = v.visitor_id
GROUP BY r.region_id, r.region_name, htr.current_visitor_count, htr.daily_capacity
ORDER BY occupancy_pct DESC;


-- Query 5: Online vs onsite entry method revenue by region
-- Version A: Conditional aggregation — ALREADY CORRECT (GROUP BY r.region_id, and other fields are aggregated)
-- But to be safe, include region_name in GROUP BY or ensure functional dependency.
-- Since region_id → region_name (assuming region_id is PK), it's logically fine,
-- but MySQL may still complain. So include region_name in GROUP BY.
EXPLAIN ANALYZE
SELECT
    r.region_name,
    SUM(CASE WHEN v.entry_method = 'online' THEN res.ticket_amount ELSE 0 END) AS online_revenue,
    SUM(CASE WHEN v.entry_method = 'onsite' THEN res.ticket_amount ELSE 0 END) AS onsite_revenue,
    COUNT(res.reservation_id) AS total_reservations
FROM Reservation res
JOIN Visitor v ON res.visitor_id = v.visitor_id
JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
JOIN Region r ON vt.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY (online_revenue + onsite_revenue) DESC;

-- Version B: UNION ALL + GROUP — FIXED: group by region_id and region_name, and fix ORDER BY
EXPLAIN ANALYZE
SELECT
    region_name,
    SUM(online_revenue) AS online_revenue,
    SUM(onsite_revenue) AS onsite_revenue,
    SUM(total_reservations) AS total_reservations
FROM (
    SELECT
        r.region_id,
        r.region_name,
        SUM(res.ticket_amount) AS online_revenue,
        0 AS onsite_revenue,
        COUNT(res.reservation_id) AS total_reservations
    FROM Reservation res
    JOIN Visitor v ON res.visitor_id = v.visitor_id
    JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
    JOIN Region r ON vt.region_id = r.region_id
    WHERE v.entry_method = 'online'
    GROUP BY r.region_id, r.region_name

    UNION ALL

    SELECT
        r.region_id,
        r.region_name,
        0 AS online_revenue,
        SUM(res.ticket_amount) AS onsite_revenue,
        COUNT(res.reservation_id) AS total_reservations
    FROM Reservation res
    JOIN Visitor v ON res.visitor_id = v.visitor_id
    JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
    JOIN Region r ON vt.region_id = r.region_id
    WHERE v.entry_method = 'onsite'
    GROUP BY r.region_id, r.region_name
) t
GROUP BY t.region_id, t.region_name
ORDER BY (SUM(t.online_revenue) + SUM(t.onsite_revenue)) DESC;