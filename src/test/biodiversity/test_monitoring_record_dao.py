from __future__ import annotations

from datetime import datetime, timedelta

from src.dao.biodiversity.monitoring_record_dao import MonitoringRecordDAO
from .common import MySQLTestCase


class TestMonitoringRecordDAO(MySQLTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.dao = MonitoringRecordDAO(cls.db_config)

    def setUp(self):
        self.dao.delete("TST_MR001")

    def tearDown(self):
        self.dao.delete("TST_MR001")

    def test_create_and_pending_list(self):
        # Create a to_verify record in recent time
        self.dao.create({
            "record_id": "TST_MR001",
            "species_id": "SP001",      # exists in seed
            "device_id": "MD001",       # exists in seed
            "monitoring_time": datetime.now() - timedelta(days=1),
            "longitude": 116.21,
            "latitude": 40.00,
            "monitoring_method": "manual_check",
            "image_path": None,
            "count_number": 1,
            "behavior_description": "test",
            "recorder_id": "U001",      # exists in seed
            "status": "to_verify",
        })

        pending = self.dao.find_pending_list_recent(days=30, limit=100)
        # Should include our test record
        ids = {r["record_id"] for r in pending}
        self.assertIn("TST_MR001", ids)

    def test_update_status(self):
        self.dao.create({
            "record_id": "TST_MR001",
            "species_id": "SP001",
            "device_id": "MD001",
            "monitoring_time": datetime.now(),
            "longitude": 116.21,
            "latitude": 40.00,
            "monitoring_method": "infrared_camera",
            "count_number": 1,
            "recorder_id": "U001",
            "status": "to_verify",
        })
        affected = self.dao.update("TST_MR001", {"status": "valid"})
        self.assertEqual(affected, 1)
        row = self.dao.find_by_id("TST_MR001")
        self.assertEqual(row["status"], "valid")
