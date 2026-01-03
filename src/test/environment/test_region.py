import unittest
from src.dao.environment.region_dao import RegionDAO

class RegionCRUD(unittest.TestCase):

    def setUp(self):
        self.dao = RegionDAO()

    def test_insert_query_update_delete(self):
        self.dao.insert("R1", "North Area")
        row = self.dao.get_by_id("R1")
        self.assertEqual(row["region_name"], "North Area")

        self.dao.update_name("R1", "South Area")
        row = self.dao.get_by_id("R1")
        self.assertEqual(row["region_name"], "South Area")

        self.dao.delete("R1")
        self.assertIsNone(self.dao.get_by_id("R1"))

    def tearDown(self):
        self.dao.close()
