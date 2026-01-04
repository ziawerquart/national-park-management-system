# src/dao/visitor/region_dao.py
import mysql.connector
from typing import List, Dict, Any, Optional


class RegionDAO:
    def __init__(self, connection):
        self.conn = connection

    def get_by_id(self, region_id: int) -> Optional[Dict[str, Any]]:
        cursor = self.conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT * FROM Region WHERE region_id = %s", (region_id,))
            return cursor.fetchone()
        finally:
            cursor.close()

    def list_all(self) -> List[Dict[str, Any]]:
        cursor = self.conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT * FROM Region ORDER BY region_id")
            return cursor.fetchall()
        finally:
            cursor.close()

    def get_capacity_info(self, region_id: int) -> Optional[Dict[str, Any]]:
        """获取区域容量相关信息（假设 Region 表含 max_capacity 字段）"""
        cursor = self.conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT region_id, region_name, max_capacity FROM Region WHERE region_id = %s", (region_id,))
            return cursor.fetchone()
        finally:
            cursor.close()