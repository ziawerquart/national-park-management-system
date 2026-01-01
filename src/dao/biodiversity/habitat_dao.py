from __future__ import annotations

from typing import Any, Dict, List, Optional

from .base_dao import BaseDAO


class HabitatDAO(BaseDAO):
    """DAO for table `Habitat`.

    Columns:
    - habitat_id (PK)
    - area_name
    - ecological_type
    - area_size
    - core_protection_area
    - environment_suitability_score
    - region_id (FK -> Region.region_id, nullable)
    """

    TABLE = "Habitat"
    PK = "habitat_id"
    ALLOWED_FIELDS = {
        "area_name",
        "ecological_type",
        "area_size",
        "core_protection_area",
        "environment_suitability_score",
        "region_id",
    }

    def create(self, data: Dict[str, Any]) -> None:
        if not data.get("habitat_id"):
            raise ValueError("Missing required field: habitat_id")

        sql = f"""
        INSERT INTO {self.TABLE}
        (habitat_id, area_name, ecological_type, area_size, core_protection_area, environment_suitability_score, region_id)
        VALUES (%s,%s,%s,%s,%s,%s,%s)
        """
        params = (
            data.get("habitat_id"),
            data.get("area_name"),
            data.get("ecological_type"),
            data.get("area_size"),
            data.get("core_protection_area"),
            data.get("environment_suitability_score"),
            data.get("region_id"),
        )
        self._execute(sql, params)

    def find_by_id(self, habitat_id: str) -> Optional[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} WHERE habitat_id=%s"
        return self._fetchone(sql, (habitat_id,))

    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} ORDER BY habitat_id LIMIT %s OFFSET %s"
        return self._fetchall(sql, (limit, offset))

    def find_by_region(self, region_id: str, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = f"""
        SELECT * FROM {self.TABLE}
        WHERE region_id=%s
        ORDER BY environment_suitability_score DESC, habitat_id
        LIMIT %s OFFSET %s
        """
        return self._fetchall(sql, (region_id, limit, offset))

    def update(self, habitat_id: str, fields: Dict[str, Any]) -> int:
        set_clause, vals = self._build_set_clause(fields, self.ALLOWED_FIELDS)
        if not set_clause:
            raise ValueError("No valid fields to update for Habitat")
        sql = f"UPDATE {self.TABLE} SET {set_clause} WHERE habitat_id=%s"
        vals.append(habitat_id)
        return self._execute(sql, tuple(vals))

    def delete(self, habitat_id: str) -> int:
        sql = f"DELETE FROM {self.TABLE} WHERE habitat_id=%s"
        return self._execute(sql, (habitat_id,))

    def exists(self, habitat_id: str) -> bool:
        sql = f"SELECT 1 FROM {self.TABLE} WHERE habitat_id=%s LIMIT 1"
        return self._fetchone(sql, (habitat_id,)) is not None
