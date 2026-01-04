SET NAMES utf8mb4;
USE national_park_db;

-- ==============================================
-- 触发器：tr_ibr_status_update
-- 作用表：IllegalBehaviorRecord
-- 触发时机：AFTER UPDATE
-- 触发条件：process_status字段变更时触发
-- 功能：案件状态变更自动记日志 + 联动更新调度表状态
-- ==============================================
-- 前置：创建案件状态变更日志表
DROP TABLE IF EXISTS illegal_behavior_status_log;
CREATE TABLE illegal_behavior_status_log (
    log_id VARCHAR(64) NOT NULL PRIMARY KEY,
    record_id VARCHAR(64) NOT NULL,
    old_status VARCHAR(32) NOT NULL,
    new_status VARCHAR(32) NOT NULL,
    update_time DATETIME NOT NULL DEFAULT NOW(),
    operator VARCHAR(64) DEFAULT 'system',
    FOREIGN KEY (record_id) REFERENCES IllegalBehaviorRecord(record_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='非法行为案件状态变更日志表';

-- 创建触发器
DELIMITER //
CREATE TRIGGER tr_ibr_status_update
AFTER UPDATE ON IllegalBehaviorRecord
FOR EACH ROW
BEGIN
    -- 仅状态变更时执行逻辑
    IF OLD.process_status != NEW.process_status THEN
        -- 插入状态变更日志
        INSERT INTO illegal_behavior_status_log (log_id, record_id, old_status, new_status)
        VALUES (CONCAT('LOG_', REPLACE(UUID(), '-', '')), NEW.record_id, OLD.process_status, NEW.process_status);
        
        -- 案件结案 → 调度置为completed，填充办结时间
        IF NEW.process_status = 'closed' THEN
            UPDATE LawEnforcementDispatch
            SET dispatch_status = 'completed', finish_time = NOW()
            WHERE record_id = NEW.record_id AND dispatch_status != 'completed';
        END IF;
        
        -- 案件处理中 → 调度置为dispatched，填充响应时间
        IF NEW.process_status = 'processing' THEN
            UPDATE LawEnforcementDispatch
            SET dispatch_status = 'dispatched', response_time = NOW()
            WHERE record_id = NEW.record_id AND dispatch_status = 'pending';
        END IF;
    END IF;
END //
DELIMITER ;