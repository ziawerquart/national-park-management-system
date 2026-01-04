-- ============================================================================
-- 科研支撑模块触发器
-- ============================================================================

DELIMITER //

-- 触发器: 项目状态为completed时禁止新增数据记录
CREATE TRIGGER tr_prevent_record_on_completed
BEFORE INSERT ON ResearchDataRecord
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    
    SELECT project_status INTO v_status 
    FROM ResearchProject WHERE project_id = NEW.project_id;
    
    IF v_status = 'completed' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '已结题项目不能新增数据记录';
    END IF;
END //

-- 触发器: 成果插入时自动设置提交时间为当前日期（如果为空）
CREATE TRIGGER tr_achievement_auto_submit_time
BEFORE INSERT ON ResearchAchievement
FOR EACH ROW
BEGIN
    IF NEW.submit_time IS NULL THEN
        SET NEW.submit_time = CURDATE();
    END IF;
END //

DELIMITER ;
