"""
Visitor 表的 DAO (Data Access Object)
"""
from typing import Optional, List
from datetime import date
from .database import get_db_connection


class Visitor:
    """Visitor 模型类"""

    def __init__(self, visitor_id: str, visitor_name: str, id_number: str,
                 contact_number: str, entry_time: date, exit_time: date,
                 entry_method: str):
        self.visitor_id = visitor_id
        self.visitor_name = visitor_name
        self.id_number = id_number
        self.contact_number = contact_number
        self.entry_time = entry_time
        self.exit_time = exit_time
        self.entry_method = entry_method


class VisitorDAO:
    """Visitor 数据访问对象"""

    @staticmethod
    def create(visitor: Visitor) -> bool:
        """创建新游客记录"""
        query = """
        INSERT INTO Visitor (
            visitor_id, visitor_name, id_number, contact_number, 
            entry_time, exit_time, entry_method
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (
                    visitor.visitor_id, visitor.visitor_name, visitor.id_number,
                    visitor.contact_number, visitor.entry_time, visitor.exit_time,
                    visitor.entry_method
                ))
                conn.commit()
                return True
        except Exception as e:
            print(f"Error creating visitor: {e}")
            return False

    @staticmethod
    def get_by_id(visitor_id: str) -> Optional[Visitor]:
        """根据ID获取游客信息"""
        query = "SELECT * FROM Visitor WHERE visitor_id = %s"
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query, (visitor_id,))
                row = cursor.fetchone()
                if row:
                    return Visitor(
                        visitor_id=row['visitor_id'],
                        visitor_name=row['visitor_name'],
                        id_number=row['id_number'],
                        contact_number=row['contact_number'],
                        entry_time=row['entry_time'],
                        exit_time=row['exit_time'],
                        entry_method=row['entry_method']
                    )
                return None
        except Exception as e:
            print(f"Error fetching visitor by ID: {e}")
            return None

    @staticmethod
    def update(visitor: Visitor) -> bool:
        """更新游客信息"""
        query = """
        UPDATE Visitor SET 
            visitor_name = %s, id_number = %s, contact_number = %s,
            entry_time = %s, exit_time = %s, entry_method = %s
        WHERE visitor_id = %s
        """
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (
                    visitor.visitor_name, visitor.id_number, visitor.contact_number,
                    visitor.entry_time, visitor.exit_time, visitor.entry_method,
                    visitor.visitor_id
                ))
                conn.commit()
                return cursor.rowcount > 0
        except Exception as e:
            print(f"Error updating visitor: {e}")
            return False

    @staticmethod
    def delete(visitor_id: str) -> bool:
        """删除游客记录"""
        query = "DELETE FROM Visitor WHERE visitor_id = %s"
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (visitor_id,))
                conn.commit()
                return cursor.rowcount > 0
        except Exception as e:
            print(f"Error deleting visitor: {e}")
            return False

    @staticmethod
    def get_all() -> List[Visitor]:
        """获取所有游客记录"""
        query = "SELECT * FROM Visitor"
        visitors = []
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query)
                rows = cursor.fetchall()
                for row in rows:
                    visitors.append(Visitor(
                        visitor_id=row['visitor_id'],
                        visitor_name=row['visitor_name'],
                        id_number=row['id_number'],
                        contact_number=row['contact_number'],
                        entry_time=row['entry_time'],
                        exit_time=row['exit_time'],
                        entry_method=row['entry_method']
                    ))
        except Exception as e:
            print(f"Error fetching all visitors: {e}")
        return visitors

    @staticmethod
    def get_by_entry_method(entry_method: str) -> List[Visitor]:
        """根据入场方式获取游客列表"""
        query = "SELECT * FROM Visitor WHERE entry_method = %s"
        visitors = []
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query, (entry_method,))
                rows = cursor.fetchall()
                for row in rows:
                    visitors.append(Visitor(
                        visitor_id=row['visitor_id'],
                        visitor_name=row['visitor_name'],
                        id_number=row['id_number'],
                        contact_number=row['contact_number'],
                        entry_time=row['entry_time'],
                        exit_time=row['exit_time'],
                        entry_method=row['entry_method']
                    ))
        except Exception as e:
            print(f"Error fetching visitors by entry method: {e}")
        return visitors