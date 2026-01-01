from __future__ import annotations

from contextlib import contextmanager
from typing import Any, Dict, Iterable, List, Optional, Tuple

import pymysql
from pymysql.cursors import DictCursor


class BaseDAO:
    """Base DAO (MySQL / PyMySQL).

    config example:
    {
        "host": "localhost",
        "port": 3306,
        "user": "root",
        "password": "xxx",
        "database": "national_park_db",
        "charset": "utf8mb4"
    }
    """

    def __init__(self, config: Dict[str, Any]):
        self.config = dict(config)
        self.config.setdefault("charset", "utf8mb4")
        self.config.setdefault("cursorclass", DictCursor)
        # keep autocommit false; manage transactions explicitly
        self.config.setdefault("autocommit", False)

    @contextmanager
    def _conn(self):
        conn = pymysql.connect(**self.config)
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()

    def _execute(self, sql: str, params: Optional[Tuple[Any, ...]] = None) -> int:
        with self._conn() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, params or ())
                return cur.rowcount

    def _fetchone(self, sql: str, params: Optional[Tuple[Any, ...]] = None) -> Optional[Dict[str, Any]]:
        with self._conn() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, params or ())
                return cur.fetchone()

    def _fetchall(self, sql: str, params: Optional[Tuple[Any, ...]] = None) -> List[Dict[str, Any]]:
        with self._conn() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, params or ())
                return list(cur.fetchall())

    @staticmethod
    def _build_set_clause(fields: Dict[str, Any], allowed: Iterable[str]) -> Tuple[str, List[Any]]:
        cols = []
        vals: List[Any] = []
        for k, v in fields.items():
            if k in allowed:
                cols.append(f"{k}=%s")
                vals.append(v)
        return ", ".join(cols), vals
