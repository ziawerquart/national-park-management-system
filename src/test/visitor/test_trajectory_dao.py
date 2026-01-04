# tests/visitor/test_trajectory_dao.py
import unittest
import mysql.connector
from src.dao.visitor import VisitorDAO, TrajectoryDAO


class TestTrajectoryDAO(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='123',
            database='visitor_management_system'
        )
        cursor = cls.conn.cursor()
        # 清理依赖表：先清轨迹，再清游客
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
        cursor.execute("DELETE FROM VisitorTrajectory")
        cursor.execute("DELETE FROM Visitor")
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
        cls.conn.commit()
        cursor.close()

    @classmethod
    def tearDownClass(cls):
        cls.conn.close()

    def setUp(self):
        self.visitor_dao = VisitorDAO(self.conn)
        self.trajectory_dao = TrajectoryDAO(self.conn)

    def test_create_trajectory(self):
        # 先创建游客
        vid = self.visitor_dao.create("轨迹测试用户", "13812345678", "2026-01-04 08:00:00")
        tid = self.trajectory_dao.create(
            visitor_id=vid,
            region_id=101,
            location_time="2026-01-04 09:00:00",
            latitude=39.9042,
            longitude=116.4074,
            is_out_of_route=False
        )
        self.assertGreater(tid, 0)

    def test_get_by_visitor(self):
        vid = self.visitor_dao.create("轨迹查询用户", "13912345678", "2026-01-04 10:00:00")
        self.trajectory_dao.create(vid, 102, "2026-01-04 10:05:00", 39.9050, 116.4080, False)
        self.trajectory_dao.create(vid, 103, "2026-01-04 10:10:00", 39.9060, 116.4090, True)

        trajectories = self.trajectory_dao.get_by_visitor(vid)
        self.assertEqual(len(trajectories), 2)
        self.assertTrue(trajectories[1]['is_out_of_route'])  # 第二条为偏离

    def test_get_out_of_route_count(self):
        vid = self.visitor_dao.create("偏离统计用户", "13712345678", "2026-01-04 11:00:00")
        self.trajectory_dao.create(vid, 104, "2026-01-04 11:05:00", 39.9070, 116.4100, False)
        self.trajectory_dao.create(vid, 105, "2026-01-04 11:10:00", 39.9080, 116.4110, True)
        self.trajectory_dao.create(vid, 106, "2026-01-04 11:15:00", 39.9090, 116.4120, True)

        count = self.trajectory_dao.get_out_of_route_count(vid)
        self.assertEqual(count, 2)

    def test_delete_by_visitor(self):
        vid = self.visitor_dao.create("轨迹删除用户", "13612345678", "2026-01-04 12:00:00")
        self.trajectory_dao.create(vid, 107, "2026-01-04 12:05:00", 39.9100, 116.4130, False)
        self.trajectory_dao.create(vid, 108, "2026-01-04 12:10:00", 39.9110, 116.4140, False)

        deleted_count = self.trajectory_dao.delete_by_visitor(vid)
        self.assertEqual(deleted_count, 2)

        remaining = self.trajectory_dao.get_by_visitor(vid)
        self.assertEqual(len(remaining), 0)

    def test_create_with_invalid_visitor_id_raises_error(self):
        """异常场景：插入轨迹时 visitor_id 不存在（外键约束）"""
        with self.assertRaises(RuntimeError):
            self.trajectory_dao.create(
                visitor_id=999999,  # 不存在的 visitor_id
                region_id=101,
                location_time="2026-01-04 13:00:00",
                latitude=39.9200,
                longitude=116.4200,
                is_out_of_route=False
            )


if __name__ == '__main__':
    unittest.main()