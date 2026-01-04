# src/dao/visitor/trajectory_dao.py
import mysql.connector
from typing import List, Dict, Any, Optional


class TrajectoryDAO:
    def __init__(self, connection):
        self.conn = connection

    def create(self, visitor_id: int, region_id: int, location_time: str,
               latitude: float, longitude: float, is_out_of_route: bool = False) -> int:
        cursor = self.conn.cursor()
        try:
            query = """
                INSERT INTO VisitorTrajectory 
                (visitor_id, region_id, location_time, latitude, longitude, is_out_of_route)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(query, (visitor_id, region_id, location_time, latitude, longitude, is_out_of_route))
            self.conn.commit()
            return cursor.lastrowid
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to insert trajectory: {e}")
        finally:
            cursor.close()

    def get_by_visitor(self, visitor_id: int) -> List[Dict[str, Any]]:
        cursor = self.conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT * FROM VisitorTrajectory WHERE visitor_id = %s ORDER BY location_time", (visitor_id,))
            return cursor.fetchall()
        finally:
            cursor.close()

    def get_out_of_route_count(self, visitor_id: int) -> int:
        cursor = self.conn.cursor()
        try:
            cursor.execute(
                "SELECT COUNT(*) FROM VisitorTrajectory WHERE visitor_id = %s AND is_out_of_route = TRUE",
                (visitor_id,)
            )
            return cursor.fetchone()[0]
        finally:
            cursor.close()

    def delete_by_visitor(self, visitor_id: int) -> int:
        """删除某游客的所有轨迹，返回删除行数"""
        cursor = self.conn.cursor()
        try:
            cursor.execute("DELETE FROM VisitorTrajectory WHERE visitor_id = %s", (visitor_id,))
            self.conn.commit()
            return cursor.rowcount
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise RuntimeError(f"Failed to delete trajectories: {e}")
        finally:
            cursor.close()