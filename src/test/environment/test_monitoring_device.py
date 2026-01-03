import unittest
from src.dao.environment.monitoring_device_dao import MonitoringDeviceDAO

class MonitoringDeviceCRUD(unittest.TestCase):

    def setUp(self):
        self.dao = MonitoringDeviceDAO()

    def test_crud(self):
        self.dao.insert("DEV1", "R1", 30)
        row = self.dao.get("DEV1")
        self.assertEqual(row["calibration_cycle"], 30)

        self.dao.update_cycle("DEV1", 60)
        row = self.dao.get("DEV1")
        self.assertEqual(row["calibration_cycle"], 60)

        self.dao.delete("DEV1")
        self.assertIsNone(self.dao.get("DEV1"))

    def tearDown(self):
        self.dao.close()
