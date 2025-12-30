"""
ResearchProject DAO - Data Access Object for ResearchProject table
Implements CRUD operations for research project management
"""
from typing import Optional, Dict, Any, List
from datetime import date
from .base_dao import BaseDAO


class ResearchProjectDAO(BaseDAO):
    """研究项目数据访问对象"""
    
    def create(self, project_data: Dict[str, Any]) -> str:
        """
        创建新的研究项目
        
        Args:
            project_data: 项目数据字典，必须包含:
                - project_id: 项目ID
                - project_name: 项目名称
                - principal_investigator_id: 首席研究员ID
                - project_status: 项目状态 (InProgress/Completed/Suspended)
                可选字段:
                - applicant_organization: 申请组织
                - start_time: 开始时间
                - end_time: 结束时间
                - research_field: 研究领域
                - leader_user_id: 项目负责人ID
                
        Returns:
            str: 创建的项目ID
            
        Raises:
            ValueError: 缺少必填字段
            pymysql.IntegrityError: 违反数据库约束（如主键重复、外键不存在）
            pymysql.Error: 其他数据库错误
        """
        # 验证必填字段
        required_fields = ['project_id', 'project_name', 'principal_investigator_id', 'project_status']
        for field in required_fields:
            if field not in project_data:
                raise ValueError(f"Missing required field: {field}")
        
        # 验证枚举值
        valid_statuses = ['InProgress', 'Completed', 'Suspended']
        if project_data['project_status'] not in valid_statuses:
            raise ValueError(f"Invalid project_status. Must be one of: {valid_statuses}")
        
        sql = """
            INSERT INTO ResearchProject 
            (project_id, project_name, principal_investigator_id, applicant_organization,
             start_time, end_time, project_status, research_field, leader_user_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        params = (
            project_data['project_id'],
            project_data['project_name'],
            project_data['principal_investigator_id'],
            project_data.get('applicant_organization'),
            project_data.get('start_time'),
            project_data.get('end_time'),
            project_data['project_status'],
            project_data.get('research_field'),
            project_data.get('leader_user_id')
        )
        
        return self.execute_insert(sql, params)
    
    def find_by_id(self, project_id: str) -> Optional[Dict[str, Any]]:
        """
        根据项目ID查询项目
        
        Args:
            project_id: 项目ID
            
        Returns:
            Optional[Dict[str, Any]]: 项目信息字典，不存在返回None
        """
        sql = """
            SELECT project_id, project_name, principal_investigator_id,
                   applicant_organization, start_time, end_time,
                   project_status, research_field, leader_user_id
            FROM ResearchProject
            WHERE project_id = %s
        """
        
        results = self.execute_query(sql, (project_id,))
        return results[0] if results else None
    
    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        """
        查询所有项目（支持分页）
        
        Args:
            limit: 返回记录数限制（默认100）
            offset: 偏移量（默认0）
            
        Returns:
            List[Dict[str, Any]]: 项目信息列表
        """
        sql = """
            SELECT project_id, project_name, principal_investigator_id,
                   applicant_organization, start_time, end_time,
                   project_status, research_field, leader_user_id
            FROM ResearchProject
            ORDER BY start_time DESC
            LIMIT %s OFFSET %s
        """
        
        return self.execute_query(sql, (limit, offset))
    
    def find_by_status(self, status: str) -> List[Dict[str, Any]]:
        """
        根据项目状态查询项目
        
        Args:
            status: 项目状态 (InProgress/Completed/Suspended)
            
        Returns:
            List[Dict[str, Any]]: 项目信息列表
            
        Raises:
            ValueError: 无效的状态值
        """
        valid_statuses = ['InProgress', 'Completed', 'Suspended']
        if status not in valid_statuses:
            raise ValueError(f"Invalid status. Must be one of: {valid_statuses}")
        
        sql = """
            SELECT project_id, project_name, principal_investigator_id,
                   applicant_organization, start_time, end_time,
                   project_status, research_field, leader_user_id
            FROM ResearchProject
            WHERE project_status = %s
            ORDER BY start_time DESC
        """
        
        return self.execute_query(sql, (status,))
    
    def find_by_investigator(self, investigator_id: str) -> List[Dict[str, Any]]:
        """
        根据首席研究员ID查询其负责的所有项目
        
        Args:
            investigator_id: 研究员用户ID
            
        Returns:
            List[Dict[str, Any]]: 项目信息列表
        """
        sql = """
            SELECT project_id, project_name, principal_investigator_id,
                   applicant_organization, start_time, end_time,
                   project_status, research_field, leader_user_id
            FROM ResearchProject
            WHERE principal_investigator_id = %s
            ORDER BY start_time DESC
        """
        
        return self.execute_query(sql, (investigator_id,))
    
    def update(self, project_id: str, update_data: Dict[str, Any]) -> int:
        """
        更新项目信息
        
        Args:
            project_id: 项目ID
            update_data: 要更新的字段字典（不包含project_id）
            
        Returns:
            int: 受影响的行数（0表示项目不存在）
            
        Raises:
            ValueError: 尝试更新不允许的字段或无效的枚举值
            pymysql.Error: 数据库错误
        """
        # 允许更新的字段
        allowed_fields = {
            'project_name', 'applicant_organization', 'start_time', 
            'end_time', 'project_status', 'research_field', 'leader_user_id'
        }
        
        # 过滤出允许更新的字段
        update_fields = {k: v for k, v in update_data.items() if k in allowed_fields}
        
        if not update_fields:
            raise ValueError("No valid fields to update")
        
        # 验证枚举值
        if 'project_status' in update_fields:
            valid_statuses = ['InProgress', 'Completed', 'Suspended']
            if update_fields['project_status'] not in valid_statuses:
                raise ValueError(f"Invalid project_status. Must be one of: {valid_statuses}")
        
        # 构建SQL语句
        set_clause = ', '.join([f"{field} = %s" for field in update_fields.keys()])
        sql = f"UPDATE ResearchProject SET {set_clause} WHERE project_id = %s"
        
        params = tuple(update_fields.values()) + (project_id,)
        
        return self.execute_update(sql, params)
    
    def delete(self, project_id: str) -> int:
        """
        删除项目
        注意：由于外键约束，如果项目有关联的数据采集或研究成果，删除会级联删除这些记录
        
        Args:
            project_id: 项目ID
            
        Returns:
            int: 受影响的行数（0表示项目不存在）
            
        Raises:
            pymysql.IntegrityError: 违反外键约束
            pymysql.Error: 其他数据库错误
        """
        sql = "DELETE FROM ResearchProject WHERE project_id = %s"
        return self.execute_update(sql, (project_id,))
    
    def count_by_status(self) -> List[Dict[str, Any]]:
        """
        统计各状态的项目数量
        
        Returns:
            List[Dict[str, Any]]: 包含status和count的列表
        """
        sql = """
            SELECT project_status AS status, COUNT(*) AS count
            FROM ResearchProject
            GROUP BY project_status
            ORDER BY count DESC
        """
        
        return self.execute_query(sql)
    
    def exists(self, project_id: str) -> bool:
        """
        检查项目是否存在
        
        Args:
            project_id: 项目ID
            
        Returns:
            bool: 存在返回True，否则返回False
        """
        sql = "SELECT COUNT(*) AS count FROM ResearchProject WHERE project_id = %s"
        result = self.execute_query(sql, (project_id,))
        return result[0]['count'] > 0 if result else False