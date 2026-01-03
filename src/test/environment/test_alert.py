import unittest
from src.dao.environment.alert_dao import AlertDAO

class AlertCRUD(unittest.TestCase):

    def setUp(self):
        self.dao = AlertDAO()

    def test_crud(self):
        self.dao.insert("A1", "D1", "HIGH")
        row = self.dao.get_by_data("D1")
        self.assertEqual(row["alert_level"], "HIGH")

        self.dao.update_level("A1", "LOW")
        row = self.dao.get_by_data("D1")
        self.assertEqual(row["alert_level"], "LOW")

        self.dao.delete("A1")
        self.assertIsNone(self.dao.get_by_data("D1"))

    def tearDown(self):
        self.dao.close()
