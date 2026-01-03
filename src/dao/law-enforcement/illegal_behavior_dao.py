from typing import List, Dict, Optional, Tuple
from src.dao.law_enforcement.base_dao import BaseDao
from pymysql.err import MySQLError


class IllegalBehaviorDao(BaseDao):
    """违规行为记录表(IllegalBehaviorRecord) 完整CRUD操作"""

    def insert(self, behavior_data: Dict) -> Tuple[bool, Optional[int]]:
        """新增违规行为记录 - 字段完全匹配SQL脚本"""
        sql = """INSERT INTO IllegalBehaviorRecord 
                 (record_id, behavior_type, occur_time, region_id, monitor_id,
                  evidence_path, process_status, law_id, process_result, punishment_basis)
                 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
        try:
            self._connect_db()
            self.cursor.execute(sql, (
                behavior_data.get("record_id"),
                behavior_data.get("behavior_type"),
                behavior_data.get("occur_time"),
                behavior_data.get("region_id"),
                behavior_data.get("monitor_id"),
                behavior_data.get("evidence_path"),
                behavior_data.get("process_status", "unprocessed"),
                behavior_data.get("law_id"),
                behavior_data.get("process_result", ""),
                behavior_data.get("punishment_basis", "")
            ))
            self._commit()
            return True, self.cursor.lastrowid
        except MySQLError as e:
            self._rollback()
            print(f"新增违规记录失败: {str(e)}")
            return False, None
        finally:
            self._close_db()

    def select_by_id(self, record_id: str) -> Optional[Dict]:
        """根据ID查询单条违规记录"""
        sql = "SELECT * FROM IllegalBehaviorRecord WHERE record_id = %s LIMIT 1"
        try:
            self._connect_db()
            self.cursor.execute(sql, (record_id,))
            return self.cursor.fetchone()
        except MySQLError as e:
            print(f"查询违规记录失败: {str(e)}")
            return None
        finally:
            self._close_db()

    def select_list(self, process_status: Optional[str] = None) -> List[Dict]:
        """查询违规记录列表（支持按处理状态筛选）"""
        sql = "SELECT * FROM IllegalBehaviorRecord"
        params = []
        if process_status:
            sql += " WHERE process_status = %s"
            params.append(process_status)
        sql += " ORDER BY occur_time DESC"
        try:
            self._connect_db()
            self.cursor.execute(sql, params)
            return self.cursor.fetchall()
        except MySQLError as e:
            print(f"查询违规记录列表失败: {str(e)}")
            return []
        finally:
            self._close_db()

    def update_status(self, record_id: str, new_status: str) -> bool:
        """更新违规记录处理状态"""
        sql = "UPDATE IllegalBehaviorRecord SET process_status = %s WHERE record_id = %s"
        try:
            self._connect_db()
            affected_rows = self.cursor.execute(sql, (new_status, record_id))
            self._commit()
            return affected_rows > 0
        except MySQLError as e:
            self._rollback()
            print(f"更新违规记录状态失败: {str(e)}")
            return False
        finally:
            self._close_db()

    def delete(self, record_id: str) -> bool:
        """删除违规记录"""
        sql = "DELETE FROM IllegalBehaviorRecord WHERE record_id = %s"
        try:
            self._connect_db()
            affected_rows = self.cursor.execute(sql, (record_id,))
            self._commit()
            return affected_rows > 0
        except MySQLError as e:
            self._rollback()
            print(f"删除违规记录失败: {str(e)}")
            return False
        finally:
            self._close_db()