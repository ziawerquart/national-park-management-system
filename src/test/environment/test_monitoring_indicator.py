import unittest
from src.dao.environment.monitoring_indicator_dao import MonitoringIndicatorDAO

class MonitoringIndicatorCRUD(unittest.TestCase):

    def setUp(self):
        self.dao = MonitoringIndicatorDAO()

    def test_crud(self):
        self.dao.insert("I1", "Air Quality", "AQI")
        row = self.dao.get_by_id("I1")
        self.assertEqual(row["unit"], "AQI")

        self.dao.update_unit("I1", "PPM")
        row = self.dao.get_by_id("I1")
        self.assertEqual(row["unit"], "PPM")

        self.dao.delete("I1")
        self.assertIsNone(self.dao.get_by_id("I1"))

    def tearDown(self):
        self.dao.close()
