"""
数据库连接配置
"""
import os
import mysql.connector
from mysql.connector import Error
from contextlib import contextmanager

class DatabaseConfig:
    """数据库配置类"""
    HOST = os.getenv('DB_HOST', 'localhost')
    DATABASE = os.getenv('DB_NAME', 'national_park_db')
    USER = os.getenv('DB_USER', 'root')
    PASSWORD = os.getenv('DB_PASSWORD', '123')
    PORT = int(os.getenv('DB_PORT', 3306))

@contextmanager
def get_db_connection():
    """
    数据库连接上下文管理器
    """
    connection = None
    try:
        connection = mysql.connector.connect(
            host=DatabaseConfig.HOST,
            database=DatabaseConfig.DATABASE,
            user=DatabaseConfig.USER,
            password=DatabaseConfig.PASSWORD,
            port=DatabaseConfig.PORT,
            autocommit=False
        )
        yield connection
    except Error as e:
        if connection:
            connection.rollback()
        raise e
    finally:
        if connection and connection.is_connected():
            connection.close()