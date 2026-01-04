# tests/visitor/test_reservation_dao.py
import unittest
import mysql.connector
from src.dao.visitor import VisitorDAO, ReservationDAO


class TestReservationDAO(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='123',
            database='visitor_management_system'
        )
        cursor = cls.conn.cursor()
        cursor.execute("DELETE FROM Reservation")
        cursor.execute("DELETE FROM Visitor")
        cls.conn.commit()
        cursor.close()

    @classmethod
    def tearDownClass(cls):
        cls.conn.close()

    def setUp(self):
        self.visitor_dao = VisitorDAO(self.conn)
        self.reservation_dao = ReservationDAO(self.conn)

    def test_create_reservation(self):
        vid = self.visitor_dao.create("预约用户", "15000000000", "2026-01-04 09:00:00")
        rid = self.reservation_dao.create(vid, 1, "2026-01-05", "confirmed")
        self.assertGreater(rid, 0)

    def test_get_by_id(self):
        vid = self.visitor_dao.create("查询用户", "15100000000", "2026-01-04 09:30:00")
        rid = self.reservation_dao.create(vid, 2, "2026-01-06")
        reservation = self.reservation_dao.get_by_id(rid)
        self.assertIsNotNone(reservation)
        self.assertEqual(reservation['region_id'], 2)

    def test_update_status(self):
        vid = self.visitor_dao.create("状态用户", "15200000000", "2026-01-04 10:00:00")
        rid = self.reservation_dao.create(vid, 3, "2026-01-07", "pending")
        success = self.reservation_dao.update_status(rid, "confirmed")
        self.assertTrue(success)

    def test_delete_reservation(self):
        vid = self.visitor_dao.create("删除用户", "15300000000", "2026-01-04 10:30:00")
        rid = self.reservation_dao.create(vid, 4, "2026-01-08")
        success = self.reservation_dao.delete(rid)
        self.assertTrue(success)
        self.assertIsNone(self.reservation_dao.get_by_id(rid))

    def test_list_by_visitor(self):
        vid = self.visitor_dao.create("列表用户", "15400000000", "2026-01-04 11:00:00")
        self.reservation_dao.create(vid, 5, "2026-01-09")
        self.reservation_dao.create(vid, 6, "2026-01-10")
        reservations = self.reservation_dao.list_by_visitor(vid)
        self.assertEqual(len(reservations), 2)


if __name__ == '__main__':
    unittest.main()