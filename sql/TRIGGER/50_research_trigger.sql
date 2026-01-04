-- ============================================================================
-- 科研支撑模块触发器
-- ============================================================================

DELIMITER //

-- 触发器: 项目状态为Completed时禁止新增采集记录
CREATE TRIGGER tr_prevent_collection_on_completed
BEFORE INSERT ON ResearchDataCollection
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    
    SELECT project_status INTO v_status 
    FROM ResearchProject WHERE project_id = NEW.project_id;
    
    IF v_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '已结题项目不能新增采集记录';
    END IF;
END //

-- 触发器: 成果插入时自动记录归档信息（通过更新publish_time为当前时间如果为空）
CREATE TRIGGER tr_result_auto_archive
BEFORE INSERT ON ResearchResult
FOR EACH ROW
BEGIN
    IF NEW.publish_time IS NULL THEN
        SET NEW.publish_time = NOW();
    END IF;
END //

DELIMITER ;
