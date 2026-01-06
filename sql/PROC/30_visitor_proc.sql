-- sql/PROC/30_visitor_proc.sql

-- 存储过程: generate_reservation_summary
DELIMITER //
CREATE PROCEDURE generate_reservation_summary(IN start_date DATE, IN end_date DATE)
BEGIN
    SELECT
        r.region_name,
        DATE(res.reservation_date) AS reservation_date,
        res.reservation_status,
        COUNT(res.reservation_id) AS reservation_count,
        SUM(res.ticket_amount) AS total_revenue
    FROM Reservation res
    JOIN VisitorTrajectory vt ON res.visitor_id = vt.visitor_id
    JOIN Region r ON vt.region_id = r.region_id
    WHERE res.reservation_date BETWEEN start_date AND end_date
    GROUP BY r.region_name, DATE(res.reservation_date), res.reservation_status
    ORDER BY r.region_name, reservation_date, reservation_status;
END //
DELIMITER ;

-- 存储过程: calculate_real_time_visitor_count
DELIMITER //
CREATE PROCEDURE calculate_real_time_visitor_count()
BEGIN
    SELECT
        r.region_name,
        COUNT(vt.visitor_id) AS current_visitor_count
    FROM Region r
    LEFT JOIN VisitorTrajectory vt ON r.region_id = vt.region_id
    AND vt.location_time >= CURDATE()
    GROUP BY r.region_name;
END //
DELIMITER ;

-- 存储过程: generate_out_of_route_report
DELIMITER //
CREATE PROCEDURE generate_out_of_route_report(IN start_date DATETIME, IN end_date DATETIME)
BEGIN
    SELECT
        v.visitor_name,
        v.contact_number,
        r.region_name,
        vt.location_time,
        vt.longitude,
        vt.latitude
    FROM Visitor v
    JOIN VisitorTrajectory vt ON v.visitor_id = vt.visitor_id
    JOIN Region r ON vt.region_id = r.region_id
    WHERE vt.is_out_of_route = TRUE
    AND vt.location_time BETWEEN start_date AND end_date
    ORDER BY vt.location_time DESC;
END //
DELIMITER ;