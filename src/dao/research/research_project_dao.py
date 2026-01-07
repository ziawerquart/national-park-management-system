"""
ResearchProject DAO - Data Access Object for ResearchProject table
(与全局DDL严格一致)
"""
from typing import Optional, Dict, Any, List
from datetime import date
from .base_dao import BaseDAO

class ResearchProjectDAO(BaseDAO):
    """研究项目数据访问对象"""

    def create(self, project_data: Dict[str, Any]) -> str:
        """
        创建新的研究项目
        必填字段: project_id、project_name、leader_id、approval_date、project_status
        可选字段: 其余字段（允许为NULL）
        """
        # 校验必填字段
        required_fields = [
            'project_id', 'project_name', 'leader_id',
            'approval_date', 'project_status'
        ]
        for field in required_fields:
            if field not in project_data or project_data[field] is None:
                raise ValueError(f"Missing required field: {field}")

        # 校验项目状态合法性
        valid_statuses = ['ongoing', 'completed', 'paused']
        if project_data['project_status'] not in valid_statuses:
            raise ValueError(f"Invalid project_status. Must be one of: {valid_statuses}")

        # SQL与DDL字段顺序完全一致
        sql = """
            INSERT INTO ResearchProject (
                project_id, project_name, leader_id, apply_organization,
                approval_date, completion_date, project_status,
                research_field, description
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        params = (
            project_data['project_id'],
            project_data['project_name'],
            project_data['leader_id'],
            project_data.get('apply_organization'),  # 可选字段
            project_data['approval_date'],
            project_data.get('completion_date'),     # 可选字段
            project_data['project_status'],
            project_data.get('research_field'),      # 可选字段
            project_data.get('description')          # 可选字段
        )

        return self.execute_insert(sql, params)

    def find_by_id(self, project_id: str) -> Optional[Dict[str, Any]]:
        """根据项目ID查询单条记录"""
        sql = """
            SELECT 
                project_id, project_name, leader_id, apply_organization,
                approval_date, completion_date, project_status,
                research_field, description
            FROM ResearchProject
            WHERE project_id = %s
        """
        results = self.execute_query(sql, (project_id,))
        return results[0] if results else None

    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        """分页查询所有项目（按审批日期倒序）"""
        sql = """
            SELECT 
                project_id, project_name, leader_id, apply_organization,
                approval_date, completion_date, project_status,
                research_field, description
            FROM ResearchProject
            ORDER BY approval_date DESC
            LIMIT %s OFFSET %s
        """
        return self.execute_query(sql, (limit, offset))

    def find_by_status(self, status: str) -> List[Dict[str, Any]]:
        """根据项目状态查询"""
        valid_statuses = ['ongoing', 'completed', 'paused']
        if status not in valid_statuses:
            raise ValueError(f"Invalid status. Must be one of: {valid_statuses}")

        sql = """
            SELECT 
                project_id, project_name, leader_id, apply_organization,
                approval_date, completion_date, project_status,
                research_field, description
            FROM ResearchProject
            WHERE project_status = %s
            ORDER BY approval_date DESC
        """
        return self.execute_query(sql, (status,))

    def find_by_leader(self, leader_id: str) -> List[Dict[str, Any]]:
        """根据负责人ID查询项目"""
        sql = """
            SELECT 
                project_id, project_name, leader_id, apply_organization,
                approval_date, completion_date, project_status,
                research_field, description
            FROM ResearchProject
            WHERE leader_id = %s
            ORDER BY approval_date DESC
        """
        return self.execute_query(sql, (leader_id,))

    def update(self, project_id: str, update_data: Dict[str, Any]) -> int:
        """更新项目（仅允许更新DDL中存在的字段）"""
        allowed_fields = {
            'project_name', 'leader_id', 'apply_organization',
            'approval_date', 'completion_date', 'project_status',
            'research_field', 'description'
        }

        # 过滤无效字段
        valid_updates = {k: v for k, v in update_data.items() if k in allowed_fields}
        if not valid_updates:
            raise ValueError("No valid fields to update")

        # 校验项目状态（若更新该字段）
        if 'project_status' in valid_updates:
            if valid_updates['project_status'] not in ['ongoing', 'completed', 'paused']:
                raise ValueError("Invalid project_status. Must be 'ongoing'/'completed'/'paused'")

        # 构建更新SQL
        set_clause = ', '.join([f"{field} = %s" for field in valid_updates])
        sql = f"""
            UPDATE ResearchProject
            SET {set_clause}
            WHERE project_id = %s
        """
        params = tuple(valid_updates.values()) + (project_id,)

        return self.execute_update(sql, params)

    def delete(self, project_id: str) -> int:
        """根据项目ID删除项目"""
        sql = "DELETE FROM ResearchProject WHERE project_id = %s"
        return self.execute_update(sql, (project_id,))

    def count_by_status(self) -> List[Dict[str, Any]]:
        """按项目状态统计数量"""
        sql = """
            SELECT project_status AS status, COUNT(*) AS count
            FROM ResearchProject
            GROUP BY project_status
            ORDER BY count DESC
        """
        return self.execute_query(sql)

    def exists(self, project_id: str) -> bool:
        """判断项目ID是否存在"""
        sql = "SELECT COUNT(*) AS count FROM ResearchProject WHERE project_id = %s"
        result = self.execute_query(sql, (project_id,))
        return result[0]['count'] > 0 if result else False