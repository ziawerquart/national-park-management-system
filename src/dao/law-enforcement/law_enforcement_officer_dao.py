from typing import List, Dict, Optional, Tuple
from src.dao.law_enforcement.base_dao import BaseDao
from pymysql.err import MySQLError


class LawEnforcementOfficerDao(BaseDao):
    """执法人员表(LawEnforcementOfficer) 完整CRUD操作"""

    def insert(self, officer_data: Dict) -> Tuple[bool, Optional[int]]:
        """新增执法人员 - 字段匹配SQL脚本(contact替换phone+device_id+user_id)"""
        sql = """INSERT INTO LawEnforcementOfficer 
                 (law_id, name, department, authority, contact, device_id, user_id)
                 VALUES (%s, %s, %s, %s, %s, %s, %s)"""
        try:
            self._connect_db()
            self.cursor.execute(sql, (
                officer_data.get("law_id"),
                officer_data.get("name"),
                officer_data.get("department"),
                officer_data.get("authority", "Level 1 Law Enforcement"),
                officer_data.get("contact"),
                officer_data.get("device_id"),
                officer_data.get("user_id")
            ))
            self._commit()
            return True, self.cursor.lastrowid
        except MySQLError as e:
            self._rollback()
            print(f"新增执法人员失败: {str(e)}")
            return False, None
        finally:
            self._close_db()

    def select_by_id(self, law_id: str) -> Optional[Dict]:
        """根据执法ID查询人员信息"""
        sql = "SELECT * FROM LawEnforcementOfficer WHERE law_id = %s LIMIT 1"
        try:
            self._connect_db()
            self.cursor.execute(sql, (law_id,))
            return self.cursor.fetchone()
        except MySQLError as e:
            print(f"查询执法人员失败: {str(e)}")
            return None
        finally:
            self._close_db()

    def select_by_department(self, department: str) -> List[Dict]:
        """按部门查询执法人员列表"""
        sql = "SELECT * FROM LawEnforcementOfficer WHERE department = %s ORDER BY name ASC"
        try:
            self._connect_db()
            self.cursor.execute(sql, (department,))
            return self.cursor.fetchall()
        except MySQLError as e:
            print(f"按部门查询人员失败: {str(e)}")
            return []
        finally:
            self._close_db()

    def update_authority(self, law_id: str, new_authority: str) -> bool:
        """更新执法人员职级权限"""
        sql = "UPDATE LawEnforcementOfficer SET authority = %s WHERE law_id = %s"
        try:
            self._connect_db()
            affected_rows = self.cursor.execute(sql, (new_authority, law_id))
            self._commit()
            return affected_rows > 0
        except MySQLError as e:
            self._rollback()
            print(f"更新职级权限失败: {str(e)}")
            return False
        finally:
            self._close_db()

    def delete(self, law_id: str) -> bool:
        """删除执法人员"""
        sql = "DELETE FROM LawEnforcementOfficer WHERE law_id = %s"
        try:
            self._connect_db()
            affected_rows = self.cursor.execute(sql, (law_id,))
            self._commit()
            return affected_rows > 0
        except MySQLError as e:
            self._rollback()
            print(f"删除执法人员失败: {str(e)}")
            return False
        finally:
            self._close_db()