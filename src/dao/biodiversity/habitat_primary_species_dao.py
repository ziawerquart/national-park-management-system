from __future__ import annotations

from typing import Any, Dict, List, Optional, Tuple

from .base_dao import BaseDAO


class HabitatPrimarySpeciesDAO(BaseDAO):
    """DAO for N:M bridge table `HabitatPrimarySpecies`.

    PK: (habitat_id, species_id)
    Columns:
    - habitat_id (FK -> Habitat)
    - species_id (FK -> Species)
    - is_primary (BOOLEAN)
    """

    TABLE = "HabitatPrimarySpecies"
    ALLOWED_FIELDS = {"is_primary"}

    def create(self, habitat_id: str, species_id: str, is_primary: bool = False) -> None:
        if not habitat_id or not species_id:
            raise ValueError("habitat_id and species_id are required")
        sql = f"""
        INSERT INTO {self.TABLE} (habitat_id, species_id, is_primary)
        VALUES (%s,%s,%s)
        """
        self._execute(sql, (habitat_id, species_id, int(bool(is_primary))))

    def find_by_pk(self, habitat_id: str, species_id: str) -> Optional[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} WHERE habitat_id=%s AND species_id=%s"
        return self._fetchone(sql, (habitat_id, species_id))

    def find_by_habitat(self, habitat_id: str) -> List[Dict[str, Any]]:
        sql = f"SELECT * FROM {self.TABLE} WHERE habitat_id=%s ORDER BY species_id"
        return self._fetchall(sql, (habitat_id,))

    def find_primary_species(self, habitat_id: str) -> List[Dict[str, Any]]:
        sql = f"""
        SELECT hps.*, s.species_name_cn, s.protection_level
        FROM {self.TABLE} hps
        JOIN Species s ON s.species_id = hps.species_id
        WHERE hps.habitat_id=%s AND hps.is_primary=1
        ORDER BY s.protection_level, s.species_id
        """
        return self._fetchall(sql, (habitat_id,))

    def update(self, habitat_id: str, species_id: str, fields: Dict[str, Any]) -> int:
        set_clause, vals = self._build_set_clause(fields, self.ALLOWED_FIELDS)
        if not set_clause:
            raise ValueError("No valid fields to update for HabitatPrimarySpecies")
        sql = f"UPDATE {self.TABLE} SET {set_clause} WHERE habitat_id=%s AND species_id=%s"
        vals.extend([habitat_id, species_id])
        return self._execute(sql, tuple(vals))

    def delete(self, habitat_id: str, species_id: str) -> int:
        sql = f"DELETE FROM {self.TABLE} WHERE habitat_id=%s AND species_id=%s"
        return self._execute(sql, (habitat_id, species_id))

    def exists(self, habitat_id: str, species_id: str) -> bool:
        sql = f"SELECT 1 FROM {self.TABLE} WHERE habitat_id=%s AND species_id=%s LIMIT 1"
        return self._fetchone(sql, (habitat_id, species_id)) is not None
