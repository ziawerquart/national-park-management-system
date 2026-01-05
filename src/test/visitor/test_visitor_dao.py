"""
Visitor DAO 测试用例
"""
import unittest
from datetime import date
from src.dao.visitor.visitor_dao import Visitor, VisitorDAO


class TestVisitorDAO(unittest.TestCase):
    """Visitor DAO 测试类"""

    def setUp(self):
        """测试前准备"""
        # 清理测试数据
        self._cleanup_test_data()

        # 创建测试游客
        self.test_visitor = Visitor(
            visitor_id="TEST001",
            visitor_name="Test User",
            id_number="ID99999999",
            contact_number="+1-555-9999",
            entry_time=date(2025, 7, 1),
            exit_time=date(2025, 7, 5),
            entry_method="online"
        )

    def tearDown(self):
        """测试后清理"""
        self._cleanup_test_data()

    def _cleanup_test_data(self):
        """清理测试数据"""
        try:
            VisitorDAO.delete("TEST001")
        except:
            pass  # 忽略删除失败

    def test_create_visitor_success(self):
        """测试成功创建游客"""
        result = VisitorDAO.create(self.test_visitor)
        self.assertTrue(result)

        # 验证游客已创建
        retrieved = VisitorDAO.get_by_id("TEST001")
        self.assertIsNotNone(retrieved)
        self.assertEqual(retrieved.visitor_name, "Test User")
        self.assertEqual(retrieved.id_number, "ID99999999")

    def test_create_visitor_duplicate_id(self):
        """测试创建重复ID的游客（异常场景）"""
        # 先创建一次
        VisitorDAO.create(self.test_visitor)

        # 尝试再次创建相同ID的游客
        result = VisitorDAO.create(self.test_visitor)
        # 注意：由于使用了INSERT IGNORE，在实际数据库中可能不会报错
        # 但我们的DAO会返回False表示未插入新记录
        self.assertFalse(result)

    def test_get_visitor_by_id_exists(self):
        """测试获取存在的游客"""
        VisitorDAO.create(self.test_visitor)
        retrieved = VisitorDAO.get_by_id("TEST001")
        self.assertIsNotNone(retrieved)
        self.assertEqual(retrieved.visitor_id, "TEST001")

    def test_get_visitor_by_id_not_exists(self):
        """测试获取不存在的游客（正常场景）"""
        retrieved = VisitorDAO.get_by_id("NONEXISTENT")
        self.assertIsNone(retrieved)

    def test_update_visitor_success(self):
        """测试成功更新游客"""
        VisitorDAO.create(self.test_visitor)

        # 更新游客信息
        updated_visitor = Visitor(
            visitor_id="TEST001",
            visitor_name="Updated Test User",
            id_number="ID88888888",
            contact_number="+1-555-8888",
            entry_time=date(2025, 7, 2),
            exit_time=date(2025, 7, 6),
            entry_method="onsite"
        )
        result = VisitorDAO.update(updated_visitor)
        self.assertTrue(result)

        # 验证更新
        retrieved = VisitorDAO.get_by_id("TEST001")
        self.assertEqual(retrieved.visitor_name, "Updated Test User")
        self.assertEqual(retrieved.id_number, "ID88888888")
        self.assertEqual(retrieved.entry_method, "onsite")

    def test_update_visitor_not_exists(self):
        """测试更新不存在的游客（异常场景）"""
        non_existent_visitor = Visitor(
            visitor_id="NONEXISTENT",
            visitor_name="Non-existent User",
            id_number="ID77777777",
            contact_number="+1-555-7777",
            entry_time=date(2025, 7, 1),
            exit_time=date(2025, 7, 5),
            entry_method="online"
        )
        result = VisitorDAO.update(non_existent_visitor)
        self.assertFalse(result)

    def test_delete_visitor_success(self):
        """测试成功删除游客"""
        VisitorDAO.create(self.test_visitor)
        result = VisitorDAO.delete("TEST001")
        self.assertTrue(result)

        # 验证已删除
        retrieved = VisitorDAO.get_by_id("TEST001")
        self.assertIsNone(retrieved)

    def test_delete_visitor_not_exists(self):
        """测试删除不存在的游客（正常场景）"""
        result = VisitorDAO.delete("NONEXISTENT")
        self.assertFalse(result)

    def test_get_all_visitors(self):
        """测试获取所有游客"""
        # 确保存在一些游客
        VisitorDAO.create(self.test_visitor)

        all_visitors = VisitorDAO.get_all()
        self.assertGreater(len(all_visitors), 0)

    def test_get_visitors_by_entry_method(self):
        """测试按入场方式获取游客"""
        VisitorDAO.create(self.test_visitor)

        online_visitors = VisitorDAO.get_by_entry_method("online")
        self.assertGreater(len(online_visitors), 0)

        onsite_visitors = VisitorDAO.get_by_entry_method("onsite")
        # 我们的测试游客是online，所以onsite应该为空
        # 但数据库中可能有其他数据，所以这里只验证类型
        self.assertIsInstance(onsite_visitors, list)


if __name__ == '__main__':
    unittest.main()