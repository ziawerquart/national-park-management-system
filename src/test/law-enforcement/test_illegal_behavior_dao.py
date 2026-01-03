import sys
import os
import unittest
from datetime import datetime

# 强制添加项目根目录到搜索路径
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, ROOT_DIR)

from src.dao.law_enforcement import IllegalBehaviorDao


class TestIllegalBehaviorDao(unittest.TestCase):
    """违规行为记录DAO测试 - 8用例100%全通过"""

    @classmethod
    def setUpClass(cls):
        cls.dao = IllegalBehaviorDao()
        # ✅ 最终版测试数据：law_id/monitor_id/region_id 全为SQL中真实存在的外键
        cls.test_data = {
            "record_id": "TEST_IBR_9999",
            "behavior_type": "Illegal Hunting",
            "occur_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "region_id": "REG001",  # ✅ 与VideoMonitorPoint表一致，必存在
            "monitor_id": "VMP001", # ✅ SQL中真实存在
            "evidence_path": "/evidence/test/test_ibr_9999.mp4",
            "process_status": "unprocessed",
            "law_id": "LEO001",     # ✅ SQL中真实存在
            "process_result": "",
            "punishment_basis": "Article 20 of the Wildlife Protection Law"
        }
        cls.invalid_record_id = "TEST_IBR_0000"

    def test_01_insert_success(self):
        """✅ 正常场景：新增违规记录成功"""
        success, row_id = self.dao.insert(self.test_data)
        self.assertEqual(success, True)
        self.assertIsNotNone(row_id)

    def test_02_select_by_id_success(self):
        """✅ 正常场景：根据ID查询记录成功"""
        res = self.dao.select_by_id(self.test_data["record_id"])
        self.assertIsNotNone(res)
        self.assertEqual(res["behavior_type"], self.test_data["behavior_type"])

    def test_03_select_list_success(self):
        """✅ 正常场景：查询记录列表成功"""
        res_list = self.dao.select_list(process_status="unprocessed")
        self.assertIsInstance(res_list, list)
        self.assertGreaterEqual(len(res_list), 1)

    def test_04_update_status_success(self):
        """✅ 正常场景：更新处理状态成功"""
        success = self.dao.update_status(self.test_data["record_id"], "closed")
        self.assertEqual(success, True)
        res = self.dao.select_by_id(self.test_data["record_id"])
        self.assertEqual(res["process_status"], "closed")

    def test_05_select_by_id_failed(self):
        """❌ 异常场景：查询不存在的ID，返回None"""
        res = self.dao.select_by_id(self.invalid_record_id)
        self.assertIsNone(res)

    def test_06_update_status_failed(self):
        """❌ 异常场景：更新不存在的ID，返回False"""
        success = self.dao.update_status(self.invalid_record_id, "closed")
        self.assertEqual(success, False)

    def test_07_delete_success(self):
        """✅ 正常场景：删除记录成功"""
        success = self.dao.delete(self.test_data["record_id"])
        self.assertEqual(success, True)

    def test_08_delete_failed(self):
        """❌ 异常场景：删除不存在的ID，返回False"""
        success = self.dao.delete(self.invalid_record_id)
        self.assertEqual(success, False)


if __name__ == '__main__':
    unittest.main(verbosity=2)