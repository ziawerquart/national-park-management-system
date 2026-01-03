-- Stage4 Trigger for Biodiversity line (MySQL 8.0)
DROP TRIGGER IF EXISTS trg_mr_before_insert;
DELIMITER $$

CREATE TRIGGER trg_mr_before_insert
BEFORE INSERT ON MonitoringRecord
FOR EACH ROW
BEGIN
    -- 1) 业务规则：新记录默认进入待核实队列
    IF NEW.status IS NULL OR NEW.status = '' THEN
        SET NEW.status = 'to_verify';
    END IF;

    -- 2) 数据质量：经纬度范围校验
    IF NEW.longitude IS NOT NULL AND (NEW.longitude < -180 OR NEW.longitude > 180) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'longitude out of range (-180..180)';
    END IF;

    IF NEW.latitude IS NOT NULL AND (NEW.latitude < -90 OR NEW.latitude > 90) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'latitude out of range (-90..90)';
    END IF;

    -- 3) 数据质量：monitoring_time 必填
    IF NEW.monitoring_time IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'monitoring_time is required';
    END IF;
END$$

DELIMITER ;
