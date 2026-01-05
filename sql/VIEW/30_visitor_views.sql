-- sql/VIEW/30_visitor_views.sql

-- VIEW 1: 预约统计视图
CREATE OR REPLACE VIEW ReservationSummary AS
SELECT
    r.region_name,
    DATE(res.reservation_date) AS reservation_date,
    res.reservation_status,
    COUNT(res.reservation_id) AS reservation_count,
    SUM(res.ticket_amount) AS total_revenue
FROM Reservation res
JOIN VisitorTrajectory vt ON res.visitor_id = vt.visitor_id
JOIN Region r ON vt.region_id = r.region_id
GROUP BY r.region_name, DATE(res.reservation_date), res.reservation_status;

-- VIEW 2: 入园情况视图
CREATE OR REPLACE VIEW VisitorEntrySummary AS
SELECT
    v.visitor_name,
    v.entry_method,
    DATE(v.entry_time) AS entry_date,
    r.region_name,
    vt.location_time
FROM Visitor v
JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
JOIN Region r ON vt.region_id = r.region_id
ORDER BY v.entry_time DESC;

-- VIEW 3: 轨迹/越界视图
CREATE OR REPLACE VIEW OutOfRouteTrajectories AS
SELECT
    v.visitor_name,
    v.contact_number,
    r.region_name,
    vt.location_time,
    vt.longitude,
    vt.latitude,
    vt.is_out_of_route
FROM Visitor v
JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
JOIN Region r ON vt.region_id = r.region_id
WHERE vt.is_out_of_route = TRUE
ORDER BY vt.location_time DESC;

-- VIEW 4: 区域流量控制视图
CREATE OR REPLACE VIEW RegionFlowControlSummary AS
SELECT
    r.region_name,
    fc.daily_capacity,
    fc.current_visitor_count,
    fc.warning_threshold,
    fc.flow_status,
    ROUND(fc.current_visitor_count * 100.0 / fc.daily_capacity, 2) AS occupancy_pct
FROM FlowControl fc
JOIN Region r ON fc.region_id = r.region_id
ORDER BY r.region_name;