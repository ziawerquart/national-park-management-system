"""
Unit tests for MonitoringRecordDAO
Tests normal operations and exception scenarios
"""
import unittest
import pymysql
from datetime import datetime, timedelta
import sys
import os

# Add src directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

from src.dao.research.monitoring_record_dao import MonitoringRecordDAO


class TestMonitoringRecordDAO(unittest.TestCase):
    """MonitoringRecordDAO 测试类"""
    
    @classmethod
    def setUpClass(cls):
        """测试类初始化 - 只执行一次"""
        cls.config = {
            'host': 'localhost',
            'port': 3306,
            'user': 'root',
            'password': 'newbee',  # 请根据实际情况修改
            'database': 'wildlife_conservation'
        }
        cls.dao = MonitoringRecordDAO(cls.config)
        
        # 测试用的记录ID
        cls.test_record_id = 'TEST_MR001'
        cls.test_species_id = 'SP001'  # 假设数据库中存在的物种
        cls.test_habitat_id = 'HB001'  # 假设数据库中存在的栖息地
        cls.test_collection_id = 'DC001'  # 假设数据库中存在的数据采集记录
    
    def setUp(self):
        """每个测试方法执行前的准备"""
        # 清理可能存在的测试数据
        try:
            self.dao.delete(self.test_record_id)
        except:
            pass
    
    def tearDown(self):
        """每个测试方法执行后的清理"""
        # 清理测试数据
        try:
            self.dao.delete(self.test_record_id)
        except:
            pass
    
    # ========== 正常场景测试 ==========
    
    def test_create_record_success(self):
        """测试：成功创建监测记录"""
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Test Observation',
            'data_value': 'Test Value',
            'habitat_id': self.test_habitat_id,
            'species_id': self.test_species_id,
            'collection_id': self.test_collection_id
        }
        
        result = self.dao.create(record_data)
        
        self.assertEqual(result, self.test_record_id)
        self.assertTrue(self.dao.exists(self.test_record_id))
    
    def test_create_record_minimal_fields(self):
        """测试：只使用必填字段创建记录"""
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Minimal Test'
        }
        
        result = self.dao.create(record_data)
        
        self.assertEqual(result, self.test_record_id)
        self.assertTrue(self.dao.exists(self.test_record_id))
    
    def test_find_by_id_success(self):
        """测试：成功查询监测记录"""
        # 先创建记录
        monitor_time = datetime.now()
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': monitor_time,
            'data_type': 'Test Type',
            'data_value': 'Test Value'
        }
        self.dao.create(record_data)
        
        # 查询记录
        result = self.dao.find_by_id(self.test_record_id)
        
        self.assertIsNotNone(result)
        self.assertEqual(result['record_id'], self.test_record_id)
        self.assertEqual(result['data_type'], 'Test Type')
        self.assertEqual(result['data_value'], 'Test Value')
    
    def test_find_by_id_not_found(self):
        """测试：查询不存在的记录"""
        result = self.dao.find_by_id('NONEXISTENT_RECORD')
        
        self.assertIsNone(result)
    
    def test_find_by_species(self):
        """测试：根据物种查询监测记录"""
        # 创建记录
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Species Test',
            'species_id': self.test_species_id
        }
        self.dao.create(record_data)
        
        # 查询该物种的记录
        results = self.dao.find_by_species(self.test_species_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['record_id'] == self.test_record_id for r in results))
    
    def test_find_by_habitat(self):
        """测试：根据栖息地查询监测记录"""
        # 创建记录
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Habitat Test',
            'habitat_id': self.test_habitat_id
        }
        self.dao.create(record_data)
        
        # 查询该栖息地的记录
        results = self.dao.find_by_habitat(self.test_habitat_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['record_id'] == self.test_record_id for r in results))
    
    def test_find_by_collection(self):
        """测试：根据数据采集ID查询监测记录"""
        # 创建记录
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Collection Test',
            'collection_id': self.test_collection_id
        }
        self.dao.create(record_data)
        
        # 查询该采集的记录
        results = self.dao.find_by_collection(self.test_collection_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['record_id'] == self.test_record_id for r in results))
    
    def test_find_by_data_type(self):
        """测试：根据数据类型查询监测记录"""
        data_type = 'Custom Data Type'
        
        # 创建记录
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': data_type
        }
        self.dao.create(record_data)
        
        # 查询该类型的记录
        results = self.dao.find_by_data_type(data_type)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['record_id'] == self.test_record_id for r in results))
    
    def test_find_by_time_range(self):
        """测试：根据时间范围查询监测记录"""
        now = datetime.now()
        
        # 创建记录
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': now,
            'data_type': 'Time Range Test'
        }
        self.dao.create(record_data)
        
        # 查询时间范围内的记录
        start_time = now - timedelta(hours=1)
        end_time = now + timedelta(hours=1)
        results = self.dao.find_by_time_range(start_time, end_time)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['record_id'] == self.test_record_id for r in results))
    
    def test_update_record_success(self):
        """测试：成功更新监测记录"""
        # 先创建记录
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Original Type',
            'data_value': 'Original Value'
        }
        self.dao.create(record_data)
        
        # 更新记录
        update_data = {
            'data_type': 'Updated Type',
            'data_value': 'Updated Value'
        }
        affected_rows = self.dao.update(self.test_record_id, update_data)
        
        self.assertEqual(affected_rows, 1)
        
        # 验证更新
        updated_record = self.dao.find_by_id(self.test_record_id)
        self.assertEqual(updated_record['data_type'], 'Updated Type')
        self.assertEqual(updated_record['data_value'], 'Updated Value')
    
    def test_update_nonexistent_record(self):
        """测试：更新不存在的记录"""
        update_data = {'data_value': 'New Value'}
        affected_rows = self.dao.update('NONEXISTENT_RECORD', update_data)
        
        self.assertEqual(affected_rows, 0)
    
    def test_delete_record_success(self):
        """测试：成功删除监测记录"""
        # 先创建记录
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Delete Test'
        }
        self.dao.create(record_data)
        
        # 删除记录
        affected_rows = self.dao.delete(self.test_record_id)
        
        self.assertEqual(affected_rows, 1)
        self.assertFalse(self.dao.exists(self.test_record_id))
    
    def test_count_by_data_type(self):
        """测试：统计各数据类型的记录数量"""
        results = self.dao.count_by_data_type()
        
        self.assertIsInstance(results, list)
        # 验证返回的数据结构
        if results:
            self.assertIn('data_type', results[0])
            self.assertIn('count', results[0])
    
    def test_count_by_species(self):
        """测试：统计各物种的监测记录数量"""
        results = self.dao.count_by_species()
        
        self.assertIsInstance(results, list)
        # 验证返回的数据结构
        if results:
            self.assertIn('species_id', results[0])
            self.assertIn('count', results[0])
    
    # ========== 异常场景测试 ==========
    
    def test_create_without_required_fields(self):
        """测试：缺少必填字段时创建失败"""
        incomplete_data = {
            'record_id': self.test_record_id,
            # 缺少 monitor_time 和 data_type
        }
        
        with self.assertRaises(ValueError) as context:
            self.dao.create(incomplete_data)
        
        self.assertIn('Missing required field', str(context.exception))
    
    def test_create_duplicate_record_id(self):
        """测试：创建重复的记录ID"""
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Duplicate Test'
        }
        
        # 第一次创建成功
        self.dao.create(record_data)
        
        # 第二次创建应该失败
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(record_data)
    
    def test_create_with_nonexistent_species(self):
        """测试：使用不存在的物种ID"""
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Test',
            'species_id': 'NONEXISTENT_SPECIES'
        }
        
        # 由于外键约束为 ON DELETE SET NULL，这可能不会失败
        # 但如果约束改为 RESTRICT，则会失败
        # 这里我们测试是否能正常创建或抛出预期错误
        try:
            self.dao.create(record_data)
            # 如果创建成功，验证记录存在
            self.assertTrue(self.dao.exists(self.test_record_id))
        except pymysql.IntegrityError:
            # 如果抛出完整性错误，也是预期的
            pass
    
    def test_create_with_nonexistent_collection(self):
        """测试：使用不存在的数据采集ID"""
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Test',
            'collection_id': 'NONEXISTENT_COLLECTION'
        }
        
        # collection_id 有外键约束且为 ON DELETE CASCADE
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(record_data)
    
    def test_update_with_no_valid_fields(self):
        """测试：更新时没有有效字段"""
        record_data = {
            'record_id': self.test_record_id,
            'monitor_time': datetime.now(),
            'data_type': 'Test'
        }
        self.dao.create(record_data)
        
        # 尝试更新不允许的字段
        update_data = {'invalid_field': 'value'}
        
        with self.assertRaises(ValueError) as context:
            self.dao.update(self.test_record_id, update_data)
        
        self.assertIn('No valid fields to update', str(context.exception))
    
    def test_find_all_with_pagination(self):
        """测试：分页查询"""
        # 测试分页功能
        results_page1 = self.dao.find_all(limit=10, offset=0)
        results_page2 = self.dao.find_all(limit=10, offset=10)
        
        self.assertIsInstance(results_page1, list)
        self.assertIsInstance(results_page2, list)
        
        # 如果有足够数据，验证分页是否正常工作
        if len(results_page1) > 0 and len(results_page2) > 0:
            # 确保两页的记录不重复
            page1_ids = {r['record_id'] for r in results_page1}
            page2_ids = {r['record_id'] for r in results_page2}
            self.assertEqual(len(page1_ids & page2_ids), 0)


if __name__ == '__main__':
    # 运行测试
    unittest.main(verbosity=2)