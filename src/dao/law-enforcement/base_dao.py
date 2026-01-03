import pymysql
from pymysql.err import MySQLError
from typing import Optional

# 数据库连接配置（与项目biodiversity模块保持一致）
DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "123456",
    "database": "national_park_db",
    "charset": "utf8mb4",
    "cursorclass": pymysql.cursors.DictCursor
}


class BaseDao:
    """DAO基类：封装所有数据库操作公共逻辑，所有业务DAO必须继承此类"""
    def __init__(self):
        self.conn: Optional[pymysql.connections.Connection] = None
        self.cursor: Optional[pymysql.cursors.DictCursor] = None

    def _connect_db(self):
        """受保护方法：建立数据库连接"""
        if not self.conn or not self.conn.open:
            self.conn = pymysql.connect(**DB_CONFIG)
            self.cursor = self.conn.cursor()

    def _close_db(self):
        """受保护方法：关闭数据库连接"""
        if self.cursor:
            self.cursor.close()
        if self.conn and self.conn.open:
            self.conn.close()

    def _commit(self):
        """受保护方法：事务提交"""
        if self.conn:
            self.conn.commit()

    def _rollback(self):
        """受保护方法：事务回滚"""
        if self.conn:
            self.conn.rollback()

    def __del__(self):
        """析构方法：对象销毁时自动关连接，杜绝连接泄漏"""
        self._close_db()