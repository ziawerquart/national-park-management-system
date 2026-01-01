from __future__ import annotations

from src.dao.biodiversity.species_dao import SpeciesDAO
from .common import MySQLTestCase


class TestSpeciesDAO(MySQLTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.dao = SpeciesDAO(cls.db_config)

    def setUp(self):
        self.dao.delete("TST_SP001")

    def tearDown(self):
        self.dao.delete("TST_SP001")

    def test_create_and_find(self):
        self.dao.create({
            "species_id": "TST_SP001",
            "species_name_cn": "测试物种",
            "species_name_latin": "Testus specius",
            "kingdom": "Animalia",
            "phylum": "Chordata",
            "tax_class": "Mammalia",
            "tax_order": "Carnivora",
            "family": "TestFam",
            "genus": "TestGen",
            "species": "specius",
            "protection_level": "none",
            "living_habits": "test",
            "distribution_description": "test",
            "habitat_id": "HB001",  # exists in seed
        })
        row = self.dao.find_by_id("TST_SP001")
        self.assertIsNotNone(row)
        self.assertEqual(row["species_id"], "TST_SP001")
        self.assertEqual(row["protection_level"], "none")

    def test_update(self):
        self.dao.create({"species_id": "TST_SP001", "species_name_cn": "A", "protection_level": "none"})
        affected = self.dao.update("TST_SP001", {"protection_level": "national_second"})
        self.assertEqual(affected, 1)
        row = self.dao.find_by_id("TST_SP001")
        self.assertEqual(row["protection_level"], "national_second")
