"""
Base DAO class for database operations
(DDL-aligned merged version)
"""
import pymysql
from typing import Optional, Dict, Any, List
from contextlib import contextmanager


class BaseDAO:
    """基础数据访问对象类（与 national_park_db 统一）"""

    def __init__(self, config: Dict[str, Any]):
        """
        初始化数据库连接配置

        Args:
            config: 数据库连接配置字典
                - host
                - port
                - user
                - password
                - database（默认 national_park_db）
                - charset（默认 utf8mb4）
        """
        self.config = {
            'host': config.get('host', 'localhost'),
            'port': config.get('port', 3306),
            'user': config.get('user', 'root'),
            'password': config.get('password', ''),
            'database': config.get('database', 'national_park_db'),
            'charset': config.get('charset', 'utf8mb4'),
            'cursorclass': pymysql.cursors.DictCursor,
            'autocommit': False
        }

    @contextmanager
    def get_connection(self):
        """
        数据库连接上下文管理器
        自动提交 / 回滚 / 关闭
        """
        conn = None
        try:
            conn = pymysql.connect(**self.config)
            yield conn
            conn.commit()
        except pymysql.Error:
            if conn:
                conn.rollback()
            raise
        finally:
            if conn:
                conn.close()

    @contextmanager
    def get_cursor(self, connection):
        """
        游标上下文管理器
        """
        cursor = None
        try:
            cursor = connection.cursor()
            yield cursor
        finally:
            if cursor:
                cursor.close()

    def execute_query(self, sql: str, params: Optional[tuple] = None) -> List[Dict[str, Any]]:
        """
        执行 SELECT 查询
        """
        with self.get_connection() as conn:
            with self.get_cursor(conn) as cursor:
                cursor.execute(sql, params or ())
                return cursor.fetchall()

    def execute_update(self, sql: str, params: Optional[tuple] = None) -> int:
        """
        执行 UPDATE / DELETE
        """
        with self.get_connection() as conn:
            with self.get_cursor(conn) as cursor:
                return cursor.execute(sql, params or ())

    def execute_insert(self, sql: str, params: Optional[tuple] = None) -> str:
        """
        执行 INSERT
        对于 VARCHAR 业务主键，直接返回第一个参数作为主键值
        """
        with self.get_connection() as conn:
            with self.get_cursor(conn) as cursor:
                cursor.execute(sql, params or ())
                return params[0] if params else None
