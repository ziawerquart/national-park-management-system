# src/dao/visitor/visitor_dao.py
import mysql.connector
from typing import Optional, List, Dict, Any


class VisitorDAO:
    def __init__(self, connection):
        """
        初始化 VisitorDAO
        :param connection: 已建立的 MySQL 连接对象
        """
        self.conn = connection

    def create(self, name: str, phone: str, entry_time: str, exit_time: Optional[str] = None) -> int:
        """插入新游客记录，返回 visitor_id"""
        cursor = self.conn.cursor()
        try:
            query = """
                INSERT INTO Visitor (name, phone, entry_time, exit_time)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(query, (name, phone, entry_time, exit_time))
            self.conn.commit()
            return cursor.lastrowid
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to create visitor: {e}")
        finally:
            cursor.close()

    def get_by_id(self, visitor_id: int) -> Optional[Dict[str, Any]]:
        """根据 ID 查询游客信息"""
        cursor = self.conn.cursor(dictionary=True)
        try:
            query = "SELECT * FROM Visitor WHERE visitor_id = %s"
            cursor.execute(query, (visitor_id,))
            return cursor.fetchone()
        finally:
            cursor.close()

    def update_exit_time(self, visitor_id: int, exit_time: str) -> bool:
        """更新游客离开时间"""
        cursor = self.conn.cursor()
        try:
            query = "UPDATE Visitor SET exit_time = %s WHERE visitor_id = %s"
            cursor.execute(query, (exit_time, visitor_id))
            self.conn.commit()
            return cursor.rowcount > 0
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to update exit time: {e}")
        finally:
            cursor.close()

    def delete(self, visitor_id: int) -> bool:
        """软删除或硬删除游客记录（此处为硬删）"""
        cursor = self.conn.cursor()
        try:
            query = "DELETE FROM Visitor WHERE visitor_id = %s"
            cursor.execute(query, (visitor_id,))
            self.conn.commit()
            return cursor.rowcount > 0
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to delete visitor: {e}")
        finally:
            cursor.close()

    def list_all(self) -> List[Dict[str, Any]]:
        """列出所有游客"""
        cursor = self.conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT * FROM Visitor")
            return cursor.fetchall()
        finally:
            cursor.close()