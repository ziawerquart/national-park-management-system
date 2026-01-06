"""
Reservation 表的 DAO (Data Access Object)
"""
from typing import Optional, List
from datetime import date
from .database import get_db_connection
from .visitor_dao import VisitorDAO


class Reservation:
    """Reservation 模型类"""

    def __init__(self, reservation_id: str, visitor_id: str, reservation_date: date,
                 entry_time_slot: str, group_size: int, reservation_status: str,
                 ticket_amount: float, payment_status: str):
        self.reservation_id = reservation_id
        self.visitor_id = visitor_id
        self.reservation_date = reservation_date
        self.entry_time_slot = entry_time_slot
        self.group_size = group_size
        self.reservation_status = reservation_status
        self.ticket_amount = ticket_amount
        self.payment_status = payment_status


class ReservationDAO:
    """Reservation 数据访问对象"""

    @staticmethod
    def create(reservation: Reservation) -> bool:
        """创建新预约记录"""
        # 验证关联的游客是否存在
        if not VisitorDAO.get_by_id(reservation.visitor_id):
            raise ValueError(f"Visitor with ID {reservation.visitor_id} does not exist")

        query = """
        INSERT INTO Reservation (
            reservation_id, visitor_id, reservation_date, entry_time_slot,
            group_size, reservation_status, ticket_amount, payment_status
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (
                    reservation.reservation_id, reservation.visitor_id, reservation.reservation_date,
                    reservation.entry_time_slot, reservation.group_size, reservation.reservation_status,
                    reservation.ticket_amount, reservation.payment_status
                ))
                conn.commit()
                return True
        except Exception as e:
            print(f"Error creating reservation: {e}")
            return False

    @staticmethod
    def get_by_id(reservation_id: str) -> Optional[Reservation]:
        """根据ID获取预约信息"""
        query = "SELECT * FROM Reservation WHERE reservation_id = %s"
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query, (reservation_id,))
                row = cursor.fetchone()
                if row:
                    return Reservation(
                        reservation_id=row['reservation_id'],
                        visitor_id=row['visitor_id'],
                        reservation_date=row['reservation_date'],
                        entry_time_slot=row['entry_time_slot'],
                        group_size=row['group_size'],
                        reservation_status=row['reservation_status'],
                        ticket_amount=row['ticket_amount'],
                        payment_status=row['payment_status']
                    )
                return None
        except Exception as e:
            print(f"Error fetching reservation by ID: {e}")
            return None

    @staticmethod
    def update(reservation: Reservation) -> bool:
        """更新预约信息"""
        query = """
        UPDATE Reservation SET 
            visitor_id = %s, reservation_date = %s, entry_time_slot = %s,
            group_size = %s, reservation_status = %s, ticket_amount = %s, payment_status = %s
        WHERE reservation_id = %s
        """
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (
                    reservation.visitor_id, reservation.reservation_date, reservation.entry_time_slot,
                    reservation.group_size, reservation.reservation_status, reservation.ticket_amount,
                    reservation.payment_status, reservation.reservation_id
                ))
                conn.commit()
                return cursor.rowcount > 0
        except Exception as e:
            print(f"Error updating reservation: {e}")
            return False

    @staticmethod
    def delete(reservation_id: str) -> bool:
        """删除预约记录"""
        query = "DELETE FROM Reservation WHERE reservation_id = %s"
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (reservation_id,))
                conn.commit()
                return cursor.rowcount > 0
        except Exception as e:
            print(f"Error deleting reservation: {e}")
            return False

    @staticmethod
    def get_all() -> List[Reservation]:
        """获取所有预约记录"""
        query = "SELECT * FROM Reservation"
        reservations = []
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query)
                rows = cursor.fetchall()
                for row in rows:
                    reservations.append(Reservation(
                        reservation_id=row['reservation_id'],
                        visitor_id=row['visitor_id'],
                        reservation_date=row['reservation_date'],
                        entry_time_slot=row['entry_time_slot'],
                        group_size=row['group_size'],
                        reservation_status=row['reservation_status'],
                        ticket_amount=row['ticket_amount'],
                        payment_status=row['payment_status']
                    ))
        except Exception as e:
            print(f"Error fetching all reservations: {e}")
        return reservations

    @staticmethod
    def get_by_visitor_id(visitor_id: str) -> List[Reservation]:
        """根据游客ID获取预约列表"""
        query = "SELECT * FROM Reservation WHERE visitor_id = %s"
        reservations = []
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query, (visitor_id,))
                rows = cursor.fetchall()
                for row in rows:
                    reservations.append(Reservation(
                        reservation_id=row['reservation_id'],
                        visitor_id=row['visitor_id'],
                        reservation_date=row['reservation_date'],
                        entry_time_slot=row['entry_time_slot'],
                        group_size=row['group_size'],
                        reservation_status=row['reservation_status'],
                        ticket_amount=row['ticket_amount'],
                        payment_status=row['payment_status']
                    ))
        except Exception as e:
            print(f"Error fetching reservations by visitor ID: {e}")
        return reservations

    @staticmethod
    def get_by_status(reservation_status: str) -> List[Reservation]:
        """根据预约状态获取预约列表"""
        query = "SELECT * FROM Reservation WHERE reservation_status = %s"
        reservations = []
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query, (reservation_status,))
                rows = cursor.fetchall()
                for row in rows:
                    reservations.append(Reservation(
                        reservation_id=row['reservation_id'],
                        visitor_id=row['visitor_id'],
                        reservation_date=row['reservation_date'],
                        entry_time_slot=row['entry_time_slot'],
                        group_size=row['group_size'],
                        reservation_status=row['reservation_status'],
                        ticket_amount=row['ticket_amount'],
                        payment_status=row['payment_status']
                    ))
        except Exception as e:
            print(f"Error fetching reservations by status: {e}")
        return reservations