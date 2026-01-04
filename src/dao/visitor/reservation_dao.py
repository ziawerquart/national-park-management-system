# src/dao/visitor/reservation_dao.py
import mysql.connector
from typing import Optional, List, Dict, Any


class ReservationDAO:
    def __init__(self, connection):
        """
        初始化 ReservationDAO
        :param connection: 已建立的 MySQL 连接对象
        """
        self.conn = connection

    def create(self, visitor_id: int, region_id: int, reservation_date: str, status: str = 'pending') -> int:
        """创建预约记录"""
        cursor = self.conn.cursor()
        try:
            query = """
                INSERT INTO Reservation (visitor_id, region_id, reservation_date, reservation_status)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(query, (visitor_id, region_id, reservation_date, status))
            self.conn.commit()
            return cursor.lastrowid
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to create reservation: {e}")
        finally:
            cursor.close()

    def get_by_id(self, reservation_id: int) -> Optional[Dict[str, Any]]:
        """根据 ID 查询预约信息"""
        cursor = self.conn.cursor(dictionary=True)
        try:
            query = "SELECT * FROM Reservation WHERE reservation_id = %s"
            cursor.execute(query, (reservation_id,))
            return cursor.fetchone()
        finally:
            cursor.close()

    def update_status(self, reservation_id: int, new_status: str) -> bool:
        """更新预约状态"""
        cursor = self.conn.cursor()
        try:
            query = "UPDATE Reservation SET reservation_status = %s WHERE reservation_id = %s"
            cursor.execute(query, (new_status, reservation_id))
            self.conn.commit()
            return cursor.rowcount > 0
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to update reservation status: {e}")
        finally:
            cursor.close()

    def delete(self, reservation_id: int) -> bool:
        """删除预约记录"""
        cursor = self.conn.cursor()
        try:
            query = "DELETE FROM Reservation WHERE reservation_id = %s"
            cursor.execute(query, (reservation_id,))
            self.conn.commit()
            return cursor.rowcount > 0
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to delete reservation: {e}")
        finally:
            cursor.close()

    def list_by_visitor(self, visitor_id: int) -> List[Dict[str, Any]]:
        """根据游客 ID 列出其所有预约"""
        cursor = self.conn.cursor(dictionary=True)
        try:
            query = "SELECT * FROM Reservation WHERE visitor_id = %s"
            cursor.execute(query, (visitor_id,))
            return cursor.fetchall()
        finally:
            cursor.close()