-- Stage4 Stored Procedure for Biodiversity line (MySQL 8.0)
DROP PROCEDURE IF EXISTS sp_submit_monitoring_record;
DELIMITER $$

CREATE PROCEDURE sp_submit_monitoring_record(
    IN  p_species_id VARCHAR(64),
    IN  p_device_id  VARCHAR(64),
    IN  p_monitoring_time DATETIME,
    IN  p_longitude DECIMAL(10,6),
    IN  p_latitude  DECIMAL(10,6),
    IN  p_monitoring_method VARCHAR(32),
    IN  p_image_path VARCHAR(512),
    IN  p_count_number INT,
    IN  p_behavior_description VARCHAR(255),
    IN  p_recorder_id VARCHAR(64),
    OUT p_record_id VARCHAR(64)
)
BEGIN
    -- 1) 基本参数校验
    IF p_species_id IS NULL OR p_species_id = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'species_id is required';
    END IF;

    IF p_monitoring_time IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'monitoring_time is required';
    END IF;

    IF p_longitude IS NOT NULL AND (p_longitude < -180 OR p_longitude > 180) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'longitude out of range (-180..180)';
    END IF;

    IF p_latitude IS NOT NULL AND (p_latitude < -90 OR p_latitude > 90) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'latitude out of range (-90..90)';
    END IF;

    
    -- monitoring_method 取值校验（与 MonitoringRecord.monitoring_method ENUM 保持一致）
    IF p_monitoring_method IS NOT NULL AND p_monitoring_method <> '' 
       AND p_monitoring_method NOT IN ('infrared_camera','manual_check','drone') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'monitoring_method must be one of: infrared_camera, manual_check, drone';
    END IF;

-- 2) 外键存在性校验（避免应用层漏校验导致脏引用）
    IF NOT EXISTS (SELECT 1 FROM Species WHERE species_id = p_species_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'species_id not found in Species';
    END IF;

    IF p_device_id IS NOT NULL AND p_device_id <> '' AND NOT EXISTS (SELECT 1 FROM MonitoringDevice WHERE device_id = p_device_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'device_id not found in MonitoringDevice';
    END IF;

    IF p_recorder_id IS NOT NULL AND p_recorder_id <> '' AND NOT EXISTS (SELECT 1 FROM User WHERE user_id = p_recorder_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'recorder_id not found in User';
    END IF;

    -- 3) 生成主键并插入（status 强制从 to_verify 开始）
    SET p_record_id = REPLACE(UUID(), '-', '');

    INSERT INTO MonitoringRecord(
        record_id, species_id, device_id, monitoring_time, longitude, latitude,
        monitoring_method, image_path, count_number, behavior_description,
        recorder_id, status
    ) VALUES (
        p_record_id, p_species_id, p_device_id, p_monitoring_time, p_longitude, p_latitude,
        p_monitoring_method, p_image_path, p_count_number, p_behavior_description,
        p_recorder_id, 'to_verify'
    );
END$$

DELIMITER ;
