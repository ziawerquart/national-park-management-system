import unittest
from src.dao.environment.calibration_record_dao import CalibrationRecordDAO

class CalibrationRecordCRUD(unittest.TestCase):

    def setUp(self):
        self.dao = CalibrationRecordDAO()

    def test_crud(self):
        self.dao.insert("C1", "DEV1", "2025-01-01")
        rows = self.dao.get_by_device("DEV1")
        self.assertEqual(len(rows), 1)

        self.dao.delete("C1")
        rows = self.dao.get_by_device("DEV1")
        self.assertEqual(len(rows), 0)

    def tearDown(self):
        self.dao.close()
