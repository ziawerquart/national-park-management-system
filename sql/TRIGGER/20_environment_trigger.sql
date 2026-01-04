-- 删除旧触发器（如果存在）
DROP TRIGGER IF EXISTS trg_envdata_fill_time;

DELIMITER $$

CREATE TRIGGER trg_envdata_fill_time
BEFORE INSERT ON EnvironmentalData
FOR EACH ROW
BEGIN
    -- 如果 collect_time 为空，则自动填充当前时间
    IF NEW.collect_time IS NULL THEN
        SET NEW.collect_time = NOW();
    END IF;
END$$

DELIMITER ;
