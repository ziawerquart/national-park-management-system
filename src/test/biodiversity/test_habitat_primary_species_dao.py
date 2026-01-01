from __future__ import annotations

from src.dao.biodiversity.habitat_primary_species_dao import HabitatPrimarySpeciesDAO
from src.dao.biodiversity.species_dao import SpeciesDAO
from .common import MySQLTestCase


class TestHabitatPrimarySpeciesDAO(MySQLTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.hps = HabitatPrimarySpeciesDAO(cls.db_config)
        cls.species = SpeciesDAO(cls.db_config)

    def setUp(self):
        # ensure test species exists
        self.species.delete("TST_SP002")
        self.species.create({"species_id": "TST_SP002", "species_name_cn": "测试物种2", "protection_level": "none", "habitat_id": "HB001"})
        self.hps.delete("HB001", "TST_SP002")

    def tearDown(self):
        self.hps.delete("HB001", "TST_SP002")
        self.species.delete("TST_SP002")

    def test_create_find_update_delete(self):
        self.hps.create("HB001", "TST_SP002", is_primary=True)
        row = self.hps.find_by_pk("HB001", "TST_SP002")
        self.assertIsNotNone(row)
        self.assertEqual(int(row["is_primary"]), 1)

        affected = self.hps.update("HB001", "TST_SP002", {"is_primary": 0})
        self.assertEqual(affected, 1)
        row2 = self.hps.find_by_pk("HB001", "TST_SP002")
        self.assertEqual(int(row2["is_primary"]), 0)

        self.hps.delete("HB001", "TST_SP002")
        self.assertIsNone(self.hps.find_by_pk("HB001", "TST_SP002"))
