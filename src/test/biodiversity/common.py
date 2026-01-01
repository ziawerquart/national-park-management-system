from __future__ import annotations

import os
import unittest
from typing import Any, Dict

import pymysql


def get_db_config() -> Dict[str, Any]:
    """Read DB config from environment variables.

    Required:
      - DB_PASSWORD (or empty if your root has no password)

    Optional (defaults shown):
      - DB_HOST=localhost
      - DB_PORT=3306
      - DB_USER=root
      - DB_NAME=national_park_db
    """
    return {
        "host": os.getenv("DB_HOST", "localhost"),
        "port": int(os.getenv("DB_PORT", "3306")),
        "user": os.getenv("DB_USER", "root"),
        "password": os.getenv("DB_PASSWORD", ""),
        "database": os.getenv("DB_NAME", "national_park_db"),
        "charset": "utf8mb4",
    }


class MySQLTestCase(unittest.TestCase):
    """Base TestCase with a quick connection check."""

    @classmethod
    def setUpClass(cls):
        cls.db_config = get_db_config()
        try:
            conn = pymysql.connect(
                host=cls.db_config["host"],
                port=cls.db_config["port"],
                user=cls.db_config["user"],
                password=cls.db_config["password"],
                database=cls.db_config["database"],
                charset=cls.db_config["charset"],
            )
            conn.close()
        except Exception as e:
            raise unittest.SkipTest(
                "Cannot connect to MySQL. "
                "Set env vars DB_HOST/DB_PORT/DB_USER/DB_PASSWORD/DB_NAME. "
                f"Original error: {e}"
            )
