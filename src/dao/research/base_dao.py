"""
Base DAO class for database operations
Provides common database connection and error handling
"""
import pymysql
from typing import Optional, Dict, Any, List
from contextlib import contextmanager


class BaseDAO:
    """基础数据访问对象类，提供数据库连接和通用方法"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        初始化数据库连接配置
        
        Args:
            config: 数据库连接配置字典
                - host: 主机地址
                - port: 端口号
                - user: 用户名
                - password: 密码
                - database: 数据库名
                - charset: 字符编码（默认 utf8mb4）
        """
        self.config = {
            'host': config.get('host', 'localhost'),
            'port': config.get('port', 3306),
            'user': config.get('user', 'root'),
            'password': config.get('password', ''),
            'database': config.get('database', 'wildlife_conservation'),
            'charset': config.get('charset', 'utf8mb4'),
            'cursorclass': pymysql.cursors.DictCursor
        }
    
    @contextmanager
    def get_connection(self):
        """
        获取数据库连接的上下文管理器
        自动处理连接的创建和关闭
        
        Yields:
            pymysql.Connection: 数据库连接对象
        """
        conn = None
        try:
            conn = pymysql.connect(**self.config)
            yield conn
        except pymysql.Error as e:
            if conn:
                conn.rollback()
            raise e
        finally:
            if conn:
                conn.close()
    
    @contextmanager
    def get_cursor(self, connection):
        """
        获取游标的上下文管理器
        
        Args:
            connection: 数据库连接对象
            
        Yields:
            pymysql.cursors.Cursor: 游标对象
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
        执行查询语句并返回结果
        
        Args:
            sql: SQL查询语句
            params: 查询参数（可选）
            
        Returns:
            List[Dict[str, Any]]: 查询结果列表
            
        Raises:
            pymysql.Error: 数据库操作错误
        """
        with self.get_connection() as conn:
            with self.get_cursor(conn) as cursor:
                cursor.execute(sql, params or ())
                return cursor.fetchall()
    
    def execute_update(self, sql: str, params: Optional[tuple] = None) -> int:
        """
        执行更新语句（INSERT/UPDATE/DELETE）
        
        Args:
            sql: SQL更新语句
            params: 更新参数（可选）
            
        Returns:
            int: 受影响的行数
            
        Raises:
            pymysql.Error: 数据库操作错误
        """
        with self.get_connection() as conn:
            with self.get_cursor(conn) as cursor:
                affected_rows = cursor.execute(sql, params or ())
                conn.commit()
                return affected_rows
    
    def execute_insert(self, sql: str, params: Optional[tuple] = None) -> str:
        """
        执行插入语句并返回最后插入的ID
        
        Args:
            sql: SQL插入语句
            params: 插入参数（可选）
            
        Returns:
            str: 最后插入的ID（对于VARCHAR主键，需要在参数中传入）
            
        Raises:
            pymysql.Error: 数据库操作错误
        """
        with self.get_connection() as conn:
            with self.get_cursor(conn) as cursor:
                cursor.execute(sql, params or ())
                conn.commit()
                # 对于VARCHAR主键，返回传入的第一个参数作为ID
                return params[0] if params else None