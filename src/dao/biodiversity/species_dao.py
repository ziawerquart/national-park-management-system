from __future__ import annotations

from typing import Any, Dict, List, Optional

from .base_dao import BaseDAO


class SpeciesDAO(BaseDAO):
    """DAO for table `Species`.

    Key enums:
    - protection_level: 'national_first' | 'national_second' | 'none'
    """

    TABLE = "Species"
    PK = "species_id"
    ALLOWED_FIELDS = {
        "species_name_cn",
        "species_name_latin",
        "kingdom",
        "phylum",
        "tax_class",
        "tax_order",
        "family",
        "genus",
        "species",
        "protection_level",
        "living_habits",
        "distribution_description",
        "habitat_id",
    }
    VALID_PROTECTION_LEVEL = {"national_first", "national_second", "none"}

    def create(self, data: Dict[str, Any]) -> None:
        if not data.get("species_id"):
            raise ValueError("Missing required field: species_id")
        pl = data.get("protection_level")
        if pl is not None and pl not in self.VALID_PROTECTION_LEVEL:
            raise ValueError(f"Invalid protection_level: {pl}")

        sql = f"""
        INSERT INTO {self.TABLE}
        (species_id, species_name_cn, species_name_latin, kingdom, phylum, tax_class, tax_order, family, genus, species,
         protection_level, living_habits, distribution_description, habitat_id)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """
        params = (
            data.get("species_id"),
            data.get("species_name_cn"),
            data.get("species_name_latin"),
            data.get("kingdom"),
            data.get("phylum"),
            data.get("tax_class"),
            data.get("tax_order"),
            data.get("family"),
            data.get("genus"),
            data.get("species"),
            data.get("protection_level"),
            data.get("living_habits"),
            data.get("distribution_description"),
            data.get("habitat_id"),
        )
        self._execute(sql, params)

    def find_by_id(self, species_id: str) -> Optional[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} WHERE species_id=%s"
        return self._fetchone(sql, (species_id,))

    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} ORDER BY species_id LIMIT %s OFFSET %s"
        return self._fetchall(sql, (limit, offset))

    def find_by_habitat(self, habitat_id: str, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = f"""
        SELECT * FROM {self.TABLE}
        WHERE habitat_id=%s
        ORDER BY protection_level, species_id
        LIMIT %s OFFSET %s
        """
        return self._fetchall(sql, (habitat_id, limit, offset))

    def find_by_protection_level(self, protection_level: str, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        if protection_level not in self.VALID_PROTECTION_LEVEL:
            raise ValueError(f"Invalid protection_level: {protection_level}")
        sql = f"""
        SELECT * FROM {self.TABLE}
        WHERE protection_level=%s
        ORDER BY species_id
        LIMIT %s OFFSET %s
        """
        return self._fetchall(sql, (protection_level, limit, offset))

    def update(self, species_id: str, fields: Dict[str, Any]) -> int:
        if "protection_level" in fields:
            pl = fields.get("protection_level")
            if pl is not None and pl not in self.VALID_PROTECTION_LEVEL:
                raise ValueError(f"Invalid protection_level: {pl}")

        set_clause, vals = self._build_set_clause(fields, self.ALLOWED_FIELDS)
        if not set_clause:
            raise ValueError("No valid fields to update for Species")
        sql = f"UPDATE {self.TABLE} SET {set_clause} WHERE species_id=%s"
        vals.append(species_id)
        return self._execute(sql, tuple(vals))

    def delete(self, species_id: str) -> int:
        sql = f"DELETE FROM {self.TABLE} WHERE species_id=%s"
        return self._execute(sql, (species_id,))

    def exists(self, species_id: str) -> bool:
        sql = f"SELECT 1 FROM {self.TABLE} WHERE species_id=%s LIMIT 1"
        return self._fetchone(sql, (species_id,)) is not None
