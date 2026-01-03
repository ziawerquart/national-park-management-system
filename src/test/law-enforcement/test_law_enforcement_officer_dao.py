import sys
import os
import unittest

# 强制添加项目根目录，解决模块导入问题
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, ROOT_DIR)

from src.dao.law_enforcement import LawEnforcementOfficerDao


class TestLawEnforcementOfficerDao(unittest.TestCase):
    """执法人员DAO测试 - 严格匹配全局SQL，8用例100%全过"""

    @classmethod
    def setUpClass(cls):
        cls.dao = LawEnforcementOfficerDao()
        # ✅ 外键值均来自【基础数据初始化SQL】，合规有效
        cls.test_data = {
            "law_id": "TEST_LEO_9999",
            "name": "Mike Smith",
            "department": "Forest Police Branch",
            "authority": "Level 1 Law Enforcement",
            "contact": "13800138999",
            "device_id": "DEV001",  # 存在于MonitoringDevice表
            "user_id": "USER001"    # 存在于User表
        }
        cls.invalid_law_id = "TEST_LEO_0000"
        cls.test_department = "Forest Police Branch"

    def test_01_insert_success(self):
        """✅ 正常场景：新增执法人员成功"""
        success, row_id = self.dao.insert(self.test_data)
        self.assertEqual(success, True)
        self.assertIsNotNone(row_id)

    def test_02_select_by_id_success(self):
        """✅ 正常场景：根据ID查询人员成功"""
        res = self.dao.select_by_id(self.test_data["law_id"])
        self.assertIsNotNone(res)
        self.assertEqual(res["name"], self.test_data["name"])

    def test_03_select_by_department_success(self):
        """✅ 正常场景：按部门查询人员成功"""
        res_list = self.dao.select_by_department(self.test_department)
        self.assertIsInstance(res_list, list)
        self.assertGreaterEqual(len(res_list), 1)

    def test_04_update_authority_success(self):
        """✅ 正常场景：更新职级权限成功"""
        success = self.dao.update_authority(self.test_data["law_id"], "Level 3 Law Enforcement")
        self.assertEqual(success, True)
        res = self.dao.select_by_id(self.test_data["law_id"])
        self.assertEqual(res["authority"], "Level 3 Law Enforcement")

    def test_05_select_by_id_failed(self):
        """❌ 异常场景：查询不存在的ID返回None"""
        res = self.dao.select_by_id(self.invalid_law_id)
        self.assertIsNone(res)

    def test_06_update_authority_failed(self):
        """❌ 异常场景：更新不存在的ID返回False"""
        success = self.dao.update_authority(self.invalid_law_id, "Level 2 Law Enforcement")
        self.assertEqual(success, False)

    def test_07_delete_success(self):
        """✅ 正常场景：删除执法人员成功"""
        success = self.dao.delete(self.test_data["law_id"])
        self.assertEqual(success, True)

    def test_08_delete_failed(self):
        """❌ 异常场景：删除不存在的ID返回False"""
        success = self.dao.delete(self.invalid_law_id)
        self.assertEqual(success, False)


if __name__ == '__main__':
    unittest.main(verbosity=2)