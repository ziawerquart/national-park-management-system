from __future__ import annotations

from src.dao.biodiversity.habitat_dao import HabitatDAO
from .common import MySQLTestCase


class TestHabitatDAO(MySQLTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.dao = HabitatDAO(cls.db_config)

    def setUp(self):
        # ensure a clean record for each test
        self.dao.delete("TST_HB001")

    def tearDown(self):
        self.dao.delete("TST_HB001")

    def test_create_and_find(self):
        self.dao.create({
            "habitat_id": "TST_HB001",
            "area_name": "Test Habitat",
            "ecological_type": "forest",
            "area_size": 12.34,
            "core_protection_area": "Test-Zone",
            "environment_suitability_score": 88.8,
            "region_id": "R001",  # exists in seed
        })
        row = self.dao.find_by_id("TST_HB001")
        self.assertIsNotNone(row)
        self.assertEqual(row["habitat_id"], "TST_HB001")
        self.assertEqual(row["area_name"], "Test Habitat")

    def test_update(self):
        self.dao.create({"habitat_id": "TST_HB001", "area_name": "A"})
        affected = self.dao.update("TST_HB001", {"area_name": "B", "environment_suitability_score": 77.7})
        self.assertEqual(affected, 1)
        row = self.dao.find_by_id("TST_HB001")
        self.assertEqual(row["area_name"], "B")

    def test_delete(self):
        self.dao.create({"habitat_id": "TST_HB001", "area_name": "A"})
        affected = self.dao.delete("TST_HB001")
        self.assertIn(affected, (0, 1))
        row = self.dao.find_by_id("TST_HB001")
        self.assertIsNone(row)
