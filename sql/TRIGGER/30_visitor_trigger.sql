-- sql/TRIGGER/30_visitor_trigger.sql

-- 触发器: check_out_of_route
DELIMITER //
CREATE TRIGGER check_out_of_route
BEFORE INSERT ON VisitorTrajectory
FOR EACH ROW
BEGIN
    -- 检查是否越界，如果越界则设置is_out_of_route为TRUE
    -- 规则：在非限制区域的游客轨迹标记为越界
    IF NEW.region_id NOT IN (SELECT region_id FROM Region WHERE region_type = 'restricted') THEN
        SET NEW.is_out_of_route = TRUE;
    ELSE
        SET NEW.is_out_of_route = FALSE;
    END IF;
END //
DELIMITER ;

-- 触发器: log_reservation_status_change
DELIMITER //
CREATE TRIGGER log_reservation_status_change
AFTER UPDATE ON Reservation
FOR EACH ROW
BEGIN
    IF OLD.reservation_status != NEW.reservation_status THEN
        INSERT INTO ReservationStatusLog (reservation_id, old_status, new_status, change_time)
        VALUES (NEW.reservation_id, OLD.reservation_status, NEW.reservation_status, NOW());
    END IF;
END //
DELIMITER ;