from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Optional

from .base_dao import BaseDAO


class MonitoringRecordDAO(BaseDAO):
    """DAO for table `MonitoringRecord`.

    Key enums:
    - monitoring_method: 'infrared_camera' | 'manual_check' | 'drone'
    - status: 'valid' | 'to_verify'
    """

    TABLE = "MonitoringRecord"
    PK = "record_id"
    ALLOWED_FIELDS = {
        "species_id",
        "device_id",
        "monitoring_time",
        "longitude",
        "latitude",
        "monitoring_method",
        "image_path",
        "count_number",
        "behavior_description",
        "recorder_id",
        "status",
    }
    VALID_METHOD = {"infrared_camera", "manual_check", "drone"}
    VALID_STATUS = {"valid", "to_verify"}

    def create(self, data: Dict[str, Any]) -> None:
        if not data.get("record_id"):
            raise ValueError("Missing required field: record_id")

        if "monitoring_method" in data and data["monitoring_method"] is not None:
            if data["monitoring_method"] not in self.VALID_METHOD:
                raise ValueError(f"Invalid monitoring_method: {data['monitoring_method']}")

        if "status" in data and data["status"] is not None:
            if data["status"] not in self.VALID_STATUS:
                raise ValueError(f"Invalid status: {data['status']}")

        sql = f"""
        INSERT INTO {self.TABLE}
        (record_id, species_id, device_id, monitoring_time, longitude, latitude, monitoring_method,
         image_path, count_number, behavior_description, recorder_id, status)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """
        params = (
            data.get("record_id"),
            data.get("species_id"),
            data.get("device_id"),
            data.get("monitoring_time"),
            data.get("longitude"),
            data.get("latitude"),
            data.get("monitoring_method"),
            data.get("image_path"),
            data.get("count_number"),
            data.get("behavior_description"),
            data.get("recorder_id"),
            data.get("status"),
        )
        self._execute(sql, params)

    def find_by_id(self, record_id: str) -> Optional[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} WHERE record_id=%s"
        return self._fetchone(sql, (record_id,))

    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} ORDER BY monitoring_time DESC, record_id LIMIT %s OFFSET %s"
        return self._fetchall(sql, (limit, offset))

    # --- Use-case oriented queries ---

    def find_pending_list_recent(self, days: int = 30, limit: int = 50) -> List[Dict[str, Any]]:
        """Pending list for analysts: recent to_verify records with joined info."""
        sql = f"""
        SELECT
            mr.record_id,
            mr.monitoring_time,
            mr.monitoring_method,
            mr.status,
            mr.count_number,
            mr.image_path,
            mr.behavior_description,
            s.species_id,
            s.species_name_cn,
            s.protection_level,
            h.habitat_id,
            h.area_name,
            h.ecological_type,
            u.user_id AS recorder_id,
            u.user_name AS recorder_name
        FROM {self.TABLE} mr
        JOIN Species s ON s.species_id = mr.species_id
        LEFT JOIN Habitat h ON h.habitat_id = s.habitat_id
        LEFT JOIN User u ON u.user_id = mr.recorder_id
        WHERE mr.status='to_verify'
          AND mr.monitoring_time >= NOW() - INTERVAL %s DAY
        ORDER BY mr.monitoring_time DESC, mr.record_id
        LIMIT %s
        """
        return self._fetchall(sql, (days, limit))

    def find_by_species(self, species_id: str, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = f"""
        SELECT * FROM {self.TABLE}
        WHERE species_id=%s
        ORDER BY monitoring_time DESC, record_id
        LIMIT %s OFFSET %s
        """
        return self._fetchall(sql, (species_id, limit, offset))

    def find_by_habitat(self, habitat_id: str, days: int = 90, limit: int = 100) -> List[Dict[str, Any]]:
        """Records in a habitat (via Species.habitat_id)."""
        sql = f"""
        SELECT mr.*
        FROM {self.TABLE} mr
        JOIN Species s ON s.species_id = mr.species_id
        WHERE s.habitat_id=%s
          AND mr.monitoring_time >= NOW() - INTERVAL %s DAY
        ORDER BY mr.monitoring_time DESC, mr.record_id
        LIMIT %s
        """
        return self._fetchall(sql, (habitat_id, days, limit))

    def count_by_status(self, days: int = 30) -> List[Dict[str, Any]]:
        sql = f"""
        SELECT status, COUNT(*) AS cnt
        FROM {self.TABLE}
        WHERE monitoring_time >= NOW() - INTERVAL %s DAY
        GROUP BY status
        ORDER BY cnt DESC
        """
        return self._fetchall(sql, (days,))

    def update(self, record_id: str, fields: Dict[str, Any]) -> int:
        if "monitoring_method" in fields:
            m = fields.get("monitoring_method")
            if m is not None and m not in self.VALID_METHOD:
                raise ValueError(f"Invalid monitoring_method: {m}")

        if "status" in fields:
            s = fields.get("status")
            if s is not None and s not in self.VALID_STATUS:
                raise ValueError(f"Invalid status: {s}")

        set_clause, vals = self._build_set_clause(fields, self.ALLOWED_FIELDS)
        if not set_clause:
            raise ValueError("No valid fields to update for MonitoringRecord")
        sql = f"UPDATE {self.TABLE} SET {set_clause} WHERE record_id=%s"
        vals.append(record_id)
        return self._execute(sql, tuple(vals))

    def delete(self, record_id: str) -> int:
        sql = f"DELETE FROM {self.TABLE} WHERE record_id=%s"
        return self._execute(sql, (record_id,))

    def exists(self, record_id: str) -> bool:
        sql = f"SELECT 1 FROM {self.TABLE} WHERE record_id=%s LIMIT 1"
        return self._fetchone(sql, (record_id,)) is not None
