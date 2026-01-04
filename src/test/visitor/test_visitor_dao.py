# tests/visitor/test_visitor_dao.py
import unittest
import mysql.connector
from src.dao.visitor import VisitorDAO


class TestVisitorDAO(unittest.TestCase):
    @classmethod
    @classmethod
    def setUpClass(cls):
        cls.conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='123',
            database='visitor_management_system'
        )
        cursor = cls.conn.cursor()
        try:
            # 按外键依赖顺序清理：子表 → 父表
            cursor.execute("DELETE FROM VisitorTrajectory")
            cursor.execute("DELETE FROM Reservation")
            cursor.execute("DELETE FROM Visitor")
            cls.conn.commit()
        except Exception as e:
            cls.conn.rollback()
            raise e
        finally:
            cursor.close()

    @classmethod
    def tearDownClass(cls):
        cls.conn.close()

    def setUp(self):
        self.dao = VisitorDAO(self.conn)

    def test_create_visitor(self):
        vid = self.dao.create("张三", "13800138000", "2026-01-04 10:00:00")
        self.assertGreater(vid, 0)

    def test_get_by_id(self):
        vid = self.dao.create("李四", "13900139000", "2026-01-04 11:00:00")
        visitor = self.dao.get_by_id(vid)
        self.assertIsNotNone(visitor)
        self.assertEqual(visitor['name'], "李四")

    def test_update_exit_time(self):
        vid = self.dao.create("王五", "13700137000", "2026-01-04 12:00:00")
        success = self.dao.update_exit_time(vid, "2026-01-04 13:00:00")
        self.assertTrue(success)

    def test_delete_visitor(self):
        vid = self.dao.create("赵六", "13600136000", "2026-01-04 14:00:00")
        success = self.dao.delete(vid)
        self.assertTrue(success)
        self.assertIsNone(self.dao.get_by_id(vid))

    def test_list_all(self):
        self.dao.create("测试1", "11111111111", "2026-01-04 15:00:00")
        self.dao.create("测试2", "22222222222", "2026-01-04 16:00:00")
        visitors = self.dao.list_all()
        self.assertGreaterEqual(len(visitors), 2)


if __name__ == '__main__':
    unittest.main()