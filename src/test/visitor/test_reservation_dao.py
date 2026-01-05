"""
Reservation DAO 测试用例
"""
import unittest
from datetime import date
from src.dao.visitor.visitor_dao import Visitor, VisitorDAO
from src.dao.visitor.reservation_dao import Reservation, ReservationDAO


class TestReservationDAO(unittest.TestCase):
    """Reservation DAO 测试类"""

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
        VisitorDAO.create(self.test_visitor)

        # 创建测试预约
        self.test_reservation = Reservation(
            reservation_id="RES_TEST001",
            visitor_id="TEST001",
            reservation_date=date(2025, 6, 25),
            entry_time_slot="09:00-11:00",
            group_size=2,
            reservation_status="confirmed",
            ticket_amount=40.00,
            payment_status="paid"
        )

    def tearDown(self):
        """测试后清理"""
        self._cleanup_test_data()
        VisitorDAO.delete("TEST001")

    def _cleanup_test_data(self):
        """清理测试数据"""
        try:
            ReservationDAO.delete("RES_TEST001")
        except:
            pass  # 忽略删除失败

    def test_create_reservation_success(self):
        """测试成功创建预约"""
        result = ReservationDAO.create(self.test_reservation)
        self.assertTrue(result)

        # 验证预约已创建
        retrieved = ReservationDAO.get_by_id("RES_TEST001")
        self.assertIsNotNone(retrieved)
        self.assertEqual(retrieved.visitor_id, "TEST001")
        self.assertEqual(retrieved.ticket_amount, 40.00)

    def test_create_reservation_invalid_visitor(self):
        """测试创建关联无效游客的预约（异常场景）"""
        invalid_reservation = Reservation(
            reservation_id="RES_INVALID",
            visitor_id="NONEXISTENT",
            reservation_date=date(2025, 6, 25),
            entry_time_slot="09:00-11:00",
            group_size=2,
            reservation_status="confirmed",
            ticket_amount=40.00,
            payment_status="paid"
        )

        with self.assertRaises(ValueError) as context:
            ReservationDAO.create(invalid_reservation)
        self.assertIn("does not exist", str(context.exception))

    def test_get_reservation_by_id_exists(self):
        """测试获取存在的预约"""
        ReservationDAO.create(self.test_reservation)
        retrieved = ReservationDAO.get_by_id("RES_TEST001")
        self.assertIsNotNone(retrieved)
        self.assertEqual(retrieved.reservation_id, "RES_TEST001")

    def test_get_reservation_by_id_not_exists(self):
        """测试获取不存在的预约（正常场景）"""
        retrieved = ReservationDAO.get_by_id("NONEXISTENT")
        self.assertIsNone(retrieved)

    def test_update_reservation_success(self):
        """测试成功更新预约"""
        ReservationDAO.create(self.test_reservation)

        # 更新预约信息
        updated_reservation = Reservation(
            reservation_id="RES_TEST001",
            visitor_id="TEST001",
            reservation_date=date(2025, 6, 26),
            entry_time_slot="10:00-12:00",
            group_size=3,
            reservation_status="completed",
            ticket_amount=60.00,
            payment_status="paid"
        )
        result = ReservationDAO.update(updated_reservation)
        self.assertTrue(result)

        # 验证更新
        retrieved = ReservationDAO.get_by_id("RES_TEST001")
        self.assertEqual(retrieved.reservation_date, date(2025, 6, 26))
        self.assertEqual(retrieved.group_size, 3)
        self.assertEqual(retrieved.ticket_amount, 60.00)

    def test_update_reservation_not_exists(self):
        """测试更新不存在的预约（异常场景）"""
        non_existent_reservation = Reservation(
            reservation_id="NONEXISTENT",
            visitor_id="TEST001",
            reservation_date=date(2025, 6, 25),
            entry_time_slot="09:00-11:00",
            group_size=2,
            reservation_status="confirmed",
            ticket_amount=40.00,
            payment_status="paid"
        )
        result = ReservationDAO.update(non_existent_reservation)
        self.assertFalse(result)

    def test_delete_reservation_success(self):
        """测试成功删除预约"""
        ReservationDAO.create(self.test_reservation)
        result = ReservationDAO.delete("RES_TEST001")
        self.assertTrue(result)

        # 验证已删除
        retrieved = ReservationDAO.get_by_id("RES_TEST001")
        self.assertIsNone(retrieved)

    def test_delete_reservation_not_exists(self):
        """测试删除不存在的预约（正常场景）"""
        result = ReservationDAO.delete("NONEXISTENT")
        self.assertFalse(result)

    def test_get_all_reservations(self):
        """测试获取所有预约"""
        ReservationDAO.create(self.test_reservation)

        all_reservations = ReservationDAO.get_all()
        self.assertGreater(len(all_reservations), 0)

    def test_get_reservations_by_visitor_id(self):
        """测试按游客ID获取预约"""
        ReservationDAO.create(self.test_reservation)

        visitor_reservations = ReservationDAO.get_by_visitor_id("TEST001")
        self.assertGreater(len(visitor_reservations), 0)
        self.assertEqual(visitor_reservations[0].visitor_id, "TEST001")

    def test_get_reservations_by_status(self):
        """测试按状态获取预约"""
        ReservationDAO.create(self.test_reservation)

        confirmed_reservations = ReservationDAO.get_by_status("confirmed")
        self.assertGreater(len(confirmed_reservations), 0)

        completed_reservations = ReservationDAO.get_by_status("completed")
        # 我们的测试预约是confirmed，所以completed应该为空
        # 但数据库中可能有其他数据，所以这里只验证类型
        self.assertIsInstance(completed_reservations, list)


if __name__ == '__main__':
    unittest.main()