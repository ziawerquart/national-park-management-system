/* =====================================================
   存储过程名称：sp_env_auto_alert
   业务线    ：生态环境监测（Environmental Monitoring）
   功能说明：
   - 对指定环境监测数据进行异常判定
   - 自动生成环境异常告警记录
   ===================================================== */
-- 删除旧存储过程（如果存在）
DROP PROCEDURE IF EXISTS sp_env_auto_alert;

DELIMITER $$

CREATE PROCEDURE sp_env_auto_alert(IN p_data_id VARCHAR(64))
BEGIN
    DECLARE v_upper DECIMAL(10,2);
    DECLARE v_lower DECIMAL(10,2);
    DECLARE v_value DECIMAL(10,2);
    DECLARE v_count INT;

    -- 获取监测值及上下限
    SELECT ed.monitor_value, mi.upper_limit, mi.lower_limit
    INTO v_value, v_upper, v_lower
    FROM EnvironmentalData ed
    JOIN MonitoringIndicator mi ON ed.indicator_id = mi.indicator_id
    WHERE ed.data_id = p_data_id;

    -- 判定是否异常
    IF v_value > v_upper OR v_value < v_lower THEN

        -- 更新 EnvironmentalData 异常标识
        UPDATE EnvironmentalData
        SET is_abnormal = 1
        WHERE data_id = p_data_id;

        -- 检查是否已存在告警
        SELECT COUNT(*) INTO v_count
        FROM Alert
        WHERE data_id = p_data_id;

        -- 如果没有告警，则生成新告警
        IF v_count = 0 THEN
            INSERT INTO Alert (
                alert_id, data_id, alert_time,
                alert_level, alert_status
            ) VALUES (
                UUID(), p_data_id, NOW(),
                'high', 'unprocessed'
            );
        END IF;

    END IF;
END$$

DELIMITER ;
