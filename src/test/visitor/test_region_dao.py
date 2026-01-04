# tests/visitor/test_region_dao.py
import unittest
import mysql.connector
from src.dao.visitor import RegionDAO


class TestRegionDAO(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='123',
            database='visitor_management_system'
        )
        # Region 表通常为初始化数据，此处假设已有测试数据
        cursor = cls.conn.cursor()
        cursor.execute("""
            INSERT IGNORE INTO Region (region_id, region_name, max_capacity) 
            VALUES 
                (101, '入口广场', 500),
                (102, '主展馆A', 300),
                (103, '主展馆B', 300),
                (104, '休息区', 200)
        """)
        cls.conn.commit()
        cursor.close()

    @classmethod
    def tearDownClass(cls):
        cls.conn.close()

    def setUp(self):
        self.region_dao = RegionDAO(self.conn)

    def test_get_by_id_exists(self):
        region = self.region_dao.get_by_id(102)
        self.assertIsNotNone(region)
        self.assertEqual(region['region_name'], '主展馆A')
        self.assertEqual(region['max_capacity'], 300)

    def test_get_by_id_not_exists(self):
        region = self.region_dao.get_by_id(99999)
        self.assertIsNone(region)

    def test_list_all(self):
        regions = self.region_dao.list_all()
        self.assertGreaterEqual(len(regions), 4)
        names = [r['region_name'] for r in regions]
        self.assertIn('入口广场', names)
        self.assertIn('休息区', names)

    def test_get_capacity_info(self):
        info = self.region_dao.get_capacity_info(103)
        self.assertIsNotNone(info)
        self.assertEqual(info['region_id'], 103)
        self.assertEqual(info['region_name'], '主展馆B')
        self.assertEqual(info['max_capacity'], 300)

    def test_get_capacity_info_not_exists(self):
        info = self.region_dao.get_capacity_info(88888)
        self.assertIsNone(info)


if __name__ == '__main__':
    unittest.main()