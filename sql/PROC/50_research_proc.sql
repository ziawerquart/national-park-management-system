-- ============================================================================
-- 科研支撑模块存储过程
-- ============================================================================

DELIMITER //

-- 存储过程: 项目结题检查
-- 检查项目是否满足结题条件（有采集记录且有成果产出）
CREATE PROCEDURE sp_check_project_completion(
    IN p_project_id VARCHAR(50),
    OUT p_can_complete BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE v_collection_count INT DEFAULT 0;
    DECLARE v_result_count INT DEFAULT 0;
    DECLARE v_status VARCHAR(20);
    
    -- 获取项目当前状态
    SELECT project_status INTO v_status 
    FROM ResearchProject WHERE project_id = p_project_id;
    
    IF v_status IS NULL THEN
        SET p_can_complete = FALSE;
        SET p_message = '项目不存在';
    ELSEIF v_status = 'Completed' THEN
        SET p_can_complete = FALSE;
        SET p_message = '项目已结题';
    ELSE
        -- 统计采集记录数
        SELECT COUNT(*) INTO v_collection_count 
        FROM ResearchDataCollection WHERE project_id = p_project_id;
        
        -- 统计成果数
        SELECT COUNT(*) INTO v_result_count 
        FROM ResearchResult WHERE project_id = p_project_id;
        
        IF v_collection_count > 0 AND v_result_count > 0 THEN
            SET p_can_complete = TRUE;
            SET p_message = CONCAT('可以结题。采集记录:', v_collection_count, ', 成果数:', v_result_count);
        ELSE
            SET p_can_complete = FALSE;
            SET p_message = CONCAT('不满足结题条件。采集记录:', v_collection_count, ', 成果数:', v_result_count);
        END IF;
    END IF;
END //

-- 存储过程: 按访问级别导出成果清单
CREATE PROCEDURE sp_export_results_by_access(
    IN p_access_level VARCHAR(20)
)
BEGIN
    SELECT 
        r.result_id,
        r.result_name,
        r.result_type,
        r.publish_time,
        r.file_path,
        p.project_name,
        u.name AS leader_name
    FROM ResearchResult r
    JOIN ResearchProject p ON r.project_id = p.project_id
    LEFT JOIN User u ON p.leader_user_id = u.user_id
    WHERE r.access_level = p_access_level
    ORDER BY r.publish_time DESC;
END //

DELIMITER ;
