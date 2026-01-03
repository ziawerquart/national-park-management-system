import sqlite3
import os

class BaseDAO:
    def __init__(self):
        db_path = os.path.join(os.path.dirname(__file__), "environment_test.db")
        self.conn = sqlite3.connect(":memory:")
        self.conn.row_factory = sqlite3.Row   # ★关键：返回 dict-like row
        self.conn.execute("PRAGMA foreign_keys = ON")
        self._init_schema()

    def _init_schema(self):
        cur = self.conn.cursor()
        cur.executescript("""
        CREATE TABLE IF NOT EXISTS Region (
            region_id TEXT PRIMARY KEY,
            region_name TEXT
        );

        CREATE TABLE IF NOT EXISTS MonitoringIndicator (
            indicator_id TEXT PRIMARY KEY,
            indicator_name TEXT,
            unit TEXT
        );

        CREATE TABLE IF NOT EXISTS MonitoringDevice (
            device_id TEXT PRIMARY KEY,
            region_id TEXT,
            calibration_cycle INTEGER
        );

        CREATE TABLE IF NOT EXISTS EnvironmentalData (
            data_id TEXT PRIMARY KEY,
            indicator_id TEXT,
            region_id TEXT,
            device_id TEXT,
            monitor_value REAL,
            is_abnormal INTEGER
        );

        CREATE TABLE IF NOT EXISTS Alert (
            alert_id TEXT PRIMARY KEY,
            data_id TEXT,
            alert_level TEXT
        );

        CREATE TABLE IF NOT EXISTS CalibrationRecord (
            record_id TEXT PRIMARY KEY,
            device_id TEXT,
            calibration_time TEXT
        );
        """)
        self.conn.commit()

    def execute(self, sql, params=()):
        cur = self.conn.cursor()
        cur.execute(sql, params)
        self.conn.commit()

    def query_one(self, sql, params=()):
        cur = self.conn.cursor()
        cur.execute(sql, params)
        return cur.fetchone()

    def query_all(self, sql, params=()):
        cur = self.conn.cursor()
        cur.execute(sql, params)
        return cur.fetchall()

    def close(self):
        self.conn.close()
