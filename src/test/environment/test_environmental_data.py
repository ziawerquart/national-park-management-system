import unittest
from src.dao.environment.environmental_data_dao import EnvironmentalDataDAO

class EnvironmentalDataCRUD(unittest.TestCase):

    def setUp(self):
        self.dao = EnvironmentalDataDAO()

    def test_crud(self):
        self.dao.insert("D1", "I1", "R1", "DEV1", 88.5, True)
        row = self.dao.get_by_id("D1")
        self.assertTrue(row["is_abnormal"])

        self.dao.update_value("D1", 66.6)
        row = self.dao.get_by_id("D1")
        self.assertEqual(row["monitor_value"], 66.6)

        self.dao.delete("D1")
        self.assertIsNone(self.dao.get_by_id("D1"))

    def tearDown(self):
        self.dao.close()
