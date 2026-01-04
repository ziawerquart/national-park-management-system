"""
ResearchProject DAO - Data Access Object for ResearchProject table
(DDL-aligned merged version)
"""
from typing import Optional, Dict, Any, List
from datetime import date
from .base_dao import BaseDAO


class ResearchProjectDAO(BaseDAO):
    """研究项目数据访问对象（与全局DDL完全一致）"""

    def create(self, project_data: Dict[str, Any]) -> str:
        """
        创建新的研究项目
        必填字段:
            - project_id
            - project_name
            - leader_id
            - approval_date
            - project_status (ongoing/completed/paused)
        可选字段:
            - apply_organization
            - completion_date
            - research_field
            - description
        """
        required_fields = [
            'project_id',
            'project_name',
            'leader_id',
            'approval_date',
            'project_status'
        ]
        for field in required_fields:
            if field not in project_data:
                raise ValueError(f"Missing required field: {field}")

        valid_statuses = ['ongoing', 'completed', 'paused']
        if project_data['project_status'] not in valid_statuses:
            raise ValueError(f"Invalid project_status. Must be one of: {valid_statuses}")

        sql = """
            INSERT INTO ResearchProject
            (project_id, project_name, leader_id, apply_organization,
             approval_date, completion_date, project_status,
             research_field, description)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        params = (
            project_data['project_id'],
            project_data['project_name'],
            project_data['leader_id'],
            project_data.get('apply_organization'),
            project_data['approval_date'],
            project_data.get('completion_date'),
            project_data['project_status'],
            project_data.get('research_field'),
            project_data.get('description')
        )

        return self.execute_insert(sql, params)

    def find_by_id(self, project_id: str) -> Optional[Dict[str, Any]]:
        sql = """
            SELECT project_id, project_name, leader_id,
                   apply_organization, approval_date, completion_date,
                   project_status, research_field, description
            FROM ResearchProject
            WHERE project_id = %s
        """
        results = self.execute_query(sql, (project_id,))
        return results[0] if results else None

    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = """
            SELECT project_id, project_name, leader_id,
                   apply_organization, approval_date, completion_date,
                   project_status, research_field, description
            FROM ResearchProject
            ORDER BY approval_date DESC
            LIMIT %s OFFSET %s
        """
        return self.execute_query(sql, (limit, offset))

    def find_by_status(self, status: str) -> List[Dict[str, Any]]:
        valid_statuses = ['ongoing', 'completed', 'paused']
        if status not in valid_statuses:
            raise ValueError(f"Invalid status. Must be one of: {valid_statuses}")

        sql = """
            SELECT project_id, project_name, leader_id,
                   apply_organization, approval_date, completion_date,
                   project_status, research_field, description
            FROM ResearchProject
            WHERE project_status = %s
            ORDER BY approval_date DESC
        """
        return self.execute_query(sql, (status,))

    def find_by_leader(self, leader_id: str) -> List[Dict[str, Any]]:
        sql = """
            SELECT project_id, project_name, leader_id,
                   apply_organization, approval_date, completion_date,
                   project_status, research_field, description
            FROM ResearchProject
            WHERE leader_id = %s
            ORDER BY approval_date DESC
        """
        return self.execute_query(sql, (leader_id,))

    def update(self, project_id: str, update_data: Dict[str, Any]) -> int:
        allowed_fields = {
            'project_name',
            'leader_id',
            'apply_organization',
            'approval_date',
            'completion_date',
            'project_status',
            'research_field',
            'description'
        }

        update_fields = {k: v for k, v in update_data.items() if k in allowed_fields}
        if not update_fields:
            raise ValueError("No valid fields to update")

        if 'project_status' in update_fields:
            valid_statuses = ['ongoing', 'completed', 'paused']
            if update_fields['project_status'] not in valid_statuses:
                raise ValueError(f"Invalid project_status. Must be one of: {valid_statuses}")

        set_clause = ', '.join([f"{field} = %s" for field in update_fields])
        sql = f"UPDATE ResearchProject SET {set_clause} WHERE project_id = %s"
        params = tuple(update_fields.values()) + (project_id,)

        return self.execute_update(sql, params)

    def delete(self, project_id: str) -> int:
        sql = "DELETE FROM ResearchProject WHERE project_id = %s"
        return self.execute_update(sql, (project_id,))

    def count_by_status(self) -> List[Dict[str, Any]]:
        sql = """
            SELECT project_status AS status, COUNT(*) AS count
            FROM ResearchProject
            GROUP BY project_status
            ORDER BY count DESC
        """
        return self.execute_query(sql)

    def exists(self, project_id: str) -> bool:
        sql = "SELECT COUNT(*) AS count FROM ResearchProject WHERE project_id = %s"
        result = self.execute_query(sql, (project_id,))
        return result[0]['count'] > 0 if result else False
