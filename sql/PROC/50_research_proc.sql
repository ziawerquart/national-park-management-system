-- ============================================================================
-- 科研支撑模块存储过程
-- ============================================================================

DELIMITER //

-- 存储过程: 项目结题检查
CREATE PROCEDURE sp_check_project_completion(
    IN p_project_id VARCHAR(10),
    OUT p_can_complete BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE v_record_count INT DEFAULT 0;
    DECLARE v_achievement_count INT DEFAULT 0;
    DECLARE v_unverified_count INT DEFAULT 0;
    DECLARE v_status VARCHAR(20);
    
    SELECT project_status INTO v_status 
    FROM ResearchProject WHERE project_id = p_project_id;
    
    IF v_status IS NULL THEN
        SET p_can_complete = FALSE;
        SET p_message = '项目不存在';
    ELSEIF v_status = 'completed' THEN
        SET p_can_complete = FALSE;
        SET p_message = '项目已结题';
    ELSE
        SELECT COUNT(*) INTO v_record_count 
        FROM ResearchDataRecord WHERE project_id = p_project_id;
        
        SELECT COUNT(*) INTO v_unverified_count 
        FROM ResearchDataRecord WHERE project_id = p_project_id AND is_verified = FALSE;
        
        SELECT COUNT(*) INTO v_achievement_count 
        FROM ResearchAchievement WHERE project_id = p_project_id;
        
        IF v_record_count > 0 AND v_achievement_count > 0 AND v_unverified_count = 0 THEN
            SET p_can_complete = TRUE;
            SET p_message = CONCAT('可以结题。数据记录:', v_record_count, ', 成果数:', v_achievement_count);
        ELSE
            SET p_can_complete = FALSE;
            SET p_message = CONCAT('不满足结题条件。数据记录:', v_record_count, ', 未审核:', v_unverified_count, ', 成果数:', v_achievement_count);
        END IF;
    END IF;
END //

-- 存储过程: 按共享权限导出成果清单
CREATE PROCEDURE sp_export_achievements_by_permission(
    IN p_permission VARCHAR(20)
)
BEGIN
    SELECT 
        a.achievement_id,
        a.achievement_name,
        a.achievement_type,
        a.submit_time,
        a.file_path,
        p.project_name,
        u.user_name AS leader_name
    FROM ResearchAchievement a
    JOIN ResearchProject p ON a.project_id = p.project_id
    LEFT JOIN `User` u ON p.leader_id = u.user_id
    WHERE a.share_permission = p_permission
    ORDER BY a.submit_time DESC;
END //

DELIMITER ;
