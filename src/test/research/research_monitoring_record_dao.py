"""
Unit tests for ResearchDataRecordDAO
Tests normal operations and exception scenarios
"""
import unittest
import pymysql
from datetime import datetime, timedelta
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

from src.dao.research.research_data_record_dao import ResearchDataRecordDAO


class TestResearchDataRecordDAO(unittest.TestCase):
    """ResearchDataRecordDAO 测试类"""
    
    @classmethod
    def setUpClass(cls):
        cls.config = {
            'host': 'localhost',
            'port': 3306,
            'user': 'root',
            'password': 'newbee',
            'database': 'national_park_db'
        }
        cls.dao = ResearchDataRecordDAO(cls.config)
        cls.test_collection_id = 'TEST_REC001'
        cls.test_project_id = 'P001'
        cls.test_collector_id = 'U001'
        cls.test_region_id = 'R001'
    
    def setUp(self):
        try:
            self.dao.delete(self.test_collection_id)
        except:
            pass
    
    def tearDown(self):
        try:
            self.dao.delete(self.test_collection_id)
        except:
            pass
    
    # ========== 正常场景测试 ==========
    
    def test_create_record_success(self):
        """测试：成功创建数据记录"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field',
            'collection_content': 'Test content',
            'sample_id': 'S001'
        }
        
        result = self.dao.create(record_data)
        
        self.assertEqual(result, self.test_collection_id)
        self.assertTrue(self.dao.exists(self.test_collection_id))
    
    def test_create_record_minimal_fields(self):
        """测试：只使用必填字段创建记录"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'system'
        }
        
        result = self.dao.create(record_data)
        
        self.assertEqual(result, self.test_collection_id)
        self.assertTrue(self.dao.exists(self.test_collection_id))
    
    def test_find_by_id_success(self):
        """测试：成功查询数据记录"""
        collection_time = datetime.now()
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': collection_time,
            'region_id': self.test_region_id,
            'data_source': 'field',
            'collection_content': 'Test content'
        }
        self.dao.create(record_data)
        
        result = self.dao.find_by_id(self.test_collection_id)
        
        self.assertIsNotNone(result)
        self.assertEqual(result['collection_id'], self.test_collection_id)
        self.assertEqual(result['data_source'], 'field')
    
    def test_find_by_id_not_found(self):
        """测试：查询不存在的记录"""
        result = self.dao.find_by_id('NONEXISTENT_RECORD')
        self.assertIsNone(result)
    
    def test_find_by_project(self):
        """测试：根据项目查询数据记录"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        self.dao.create(record_data)
        
        results = self.dao.find_by_project(self.test_project_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['collection_id'] == self.test_collection_id for r in results))
    
    def test_find_by_collector(self):
        """测试：根据采集员查询数据记录"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        self.dao.create(record_data)
        
        results = self.dao.find_by_collector(self.test_collector_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['collection_id'] == self.test_collection_id for r in results))
    
    def test_find_by_region(self):
        """测试：根据区域查询数据记录"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        self.dao.create(record_data)
        
        results = self.dao.find_by_region(self.test_region_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['collection_id'] == self.test_collection_id for r in results))
    
    def test_find_by_time_range(self):
        """测试：根据时间范围查询数据记录"""
        now = datetime.now()
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': now,
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        self.dao.create(record_data)
        
        start_time = now - timedelta(hours=1)
        end_time = now + timedelta(hours=1)
        results = self.dao.find_by_time_range(start_time, end_time)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(r['collection_id'] == self.test_collection_id for r in results))
    
    def test_update_record_success(self):
        """测试：成功更新数据记录"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field',
            'collection_content': 'Original content'
        }
        self.dao.create(record_data)
        
        update_data = {
            'collection_content': 'Updated content',
            'is_verified': True,
            'verified_by': self.test_collector_id,
            'verified_at': datetime.now()
        }
        affected_rows = self.dao.update(self.test_collection_id, update_data)
        
        self.assertEqual(affected_rows, 1)
        
        updated_record = self.dao.find_by_id(self.test_collection_id)
        self.assertEqual(updated_record['collection_content'], 'Updated content')
        self.assertEqual(updated_record['is_verified'], 1)
    
    def test_update_nonexistent_record(self):
        """测试：更新不存在的记录"""
        update_data = {'collection_content': 'New content'}
        affected_rows = self.dao.update('NONEXISTENT_RECORD', update_data)
        self.assertEqual(affected_rows, 0)
    
    def test_delete_record_success(self):
        """测试：成功删除数据记录"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        self.dao.create(record_data)
        
        affected_rows = self.dao.delete(self.test_collection_id)
        
        self.assertEqual(affected_rows, 1)
        self.assertFalse(self.dao.exists(self.test_collection_id))
    
    def test_count_by_source(self):
        """测试：统计各数据来源的记录数量"""
        results = self.dao.count_by_source()
        
        self.assertIsInstance(results, list)
        if results:
            self.assertIn('data_source', results[0])
            self.assertIn('count', results[0])
    
    # ========== 异常场景测试 ==========
    
    def test_create_without_required_fields(self):
        """测试：缺少必填字段时创建失败"""
        incomplete_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id
            # 缺少 collector_id, collection_time, region_id, data_source
        }
        
        with self.assertRaises(ValueError) as context:
            self.dao.create(incomplete_data)
        
        self.assertIn('Missing required field', str(context.exception))
    
    def test_create_with_invalid_data_source(self):
        """测试：使用无效的数据来源"""
        invalid_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'invalid_source'
        }
        
        with self.assertRaises(ValueError) as context:
            self.dao.create(invalid_data)
        
        self.assertIn('Invalid data_source', str(context.exception))
    
    def test_create_duplicate_collection_id(self):
        """测试：创建重复的记录ID"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        
        self.dao.create(record_data)
        
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(record_data)
    
    def test_create_with_nonexistent_project(self):
        """测试：使用不存在的项目ID"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': 'NONEXISTENT_PROJECT',
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(record_data)
    
    def test_update_with_invalid_data_source(self):
        """测试：更新为无效的数据来源"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        self.dao.create(record_data)
        
        update_data = {'data_source': 'invalid_source'}
        
        with self.assertRaises(ValueError) as context:
            self.dao.update(self.test_collection_id, update_data)
        
        self.assertIn('Invalid data_source', str(context.exception))
    
    def test_update_with_no_valid_fields(self):
        """测试：更新时没有有效字段"""
        record_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        }
        self.dao.create(record_data)
        
        update_data = {'invalid_field': 'value'}
        
        with self.assertRaises(ValueError) as context:
            self.dao.update(self.test_collection_id, update_data)
        
        self.assertIn('No valid fields to update', str(context.exception))
    
    def test_find_all_with_pagination(self):
        """测试：分页查询"""
        results_page1 = self.dao.find_all(limit=10, offset=0)
        results_page2 = self.dao.find_all(limit=10, offset=10)
        
        self.assertIsInstance(results_page1, list)
        self.assertIsInstance(results_page2, list)
        
        if len(results_page1) > 0 and len(results_page2) > 0:
            page1_ids = {r['collection_id'] for r in results_page1}
            page2_ids = {r['collection_id'] for r in results_page2}
            self.assertEqual(len(page1_ids & page2_ids), 0)


if __name__ == '__main__':
    unittest.main(verbosity=2)