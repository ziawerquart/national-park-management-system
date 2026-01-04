"""
Unit tests for ResearchProjectDAO
Tests normal operations and exception scenarios
"""
import unittest
import pymysql
from datetime import date, timedelta
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

from src.dao.research.research_project_dao import ResearchProjectDAO


class TestResearchProjectDAO(unittest.TestCase):
    """ResearchProjectDAO 测试类"""
    
    @classmethod
    def setUpClass(cls):
        cls.config = {
            'host': 'localhost',
            'port': 3306,
            'user': 'root',
            'password': 'newbee',
            'database': 'national_park_db'
        }
        cls.dao = ResearchProjectDAO(cls.config)
        cls.test_project_id = 'TEST_PRJ001'
        cls.test_user_id = 'U001'
    
    def setUp(self):
        try:
            self.dao.delete(self.test_project_id)
        except:
            pass
    
    def tearDown(self):
        try:
            self.dao.delete(self.test_project_id)
        except:
            pass
    
    # ========== 正常场景测试 ==========
    
    def test_create_project_success(self):
        """测试：成功创建项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project for Unit Testing',
            'leader_id': self.test_user_id,
            'project_status': 'ongoing',
            'apply_organization': 'Test University',
            'approval_date': date.today(),
            'completion_date': date.today() + timedelta(days=365),
            'research_field': 'Testing'
        }
        
        result = self.dao.create(project_data)
        
        self.assertEqual(result, self.test_project_id)
        self.assertTrue(self.dao.exists(self.test_project_id))
    
    def test_find_by_id_success(self):
        """测试：成功查询项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        result = self.dao.find_by_id(self.test_project_id)
        
        self.assertIsNotNone(result)
        self.assertEqual(result['project_id'], self.test_project_id)
        self.assertEqual(result['project_name'], 'Test Project')
        self.assertEqual(result['project_status'], 'ongoing')
    
    def test_find_by_id_not_found(self):
        """测试：查询不存在的项目"""
        result = self.dao.find_by_id('NONEXISTENT_PROJECT')
        self.assertIsNone(result)
    
    def test_find_by_status(self):
        """测试：根据状态查询项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        results = self.dao.find_by_status('ongoing')
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(p['project_id'] == self.test_project_id for p in results))
    
    def test_find_by_leader(self):
        """测试：根据负责人查询项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        results = self.dao.find_by_leader(self.test_user_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(p['project_id'] == self.test_project_id for p in results))
    
    def test_update_project_success(self):
        """测试：成功更新项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Original Name',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        update_data = {
            'project_name': 'Updated Name',
            'project_status': 'completed'
        }
        affected_rows = self.dao.update(self.test_project_id, update_data)
        
        self.assertEqual(affected_rows, 1)
        
        updated_project = self.dao.find_by_id(self.test_project_id)
        self.assertEqual(updated_project['project_name'], 'Updated Name')
        self.assertEqual(updated_project['project_status'], 'completed')
    
    def test_update_nonexistent_project(self):
        """测试：更新不存在的项目"""
        update_data = {'project_name': 'New Name'}
        affected_rows = self.dao.update('NONEXISTENT_PROJECT', update_data)
        self.assertEqual(affected_rows, 0)
    
    def test_delete_project_success(self):
        """测试：成功删除项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        affected_rows = self.dao.delete(self.test_project_id)
        
        self.assertEqual(affected_rows, 1)
        self.assertFalse(self.dao.exists(self.test_project_id))
    
    def test_count_by_status(self):
        """测试：统计各状态的项目数量"""
        results = self.dao.count_by_status()
        
        self.assertIsInstance(results, list)
        if results:
            self.assertIn('status', results[0])
            self.assertIn('count', results[0])
    
    # ========== 异常场景测试 ==========
    
    def test_create_without_required_fields(self):
        """测试：缺少必填字段时创建失败"""
        incomplete_data = {
            'project_id': self.test_project_id,
            'leader_id': self.test_user_id,
            'project_status': 'ongoing'
            # 缺少 project_name, approval_date
        }
        
        with self.assertRaises(ValueError) as context:
            self.dao.create(incomplete_data)
        
        self.assertIn('Missing required field', str(context.exception))
    
    def test_create_with_invalid_status(self):
        """测试：使用无效的项目状态"""
        invalid_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'InvalidStatus'
        }
        
        with self.assertRaises(ValueError) as context:
            self.dao.create(invalid_data)
        
        self.assertIn('Invalid project_status', str(context.exception))
    
    def test_create_duplicate_project_id(self):
        """测试：创建重复的项目ID"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        
        self.dao.create(project_data)
        
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(project_data)
    
    def test_create_with_nonexistent_leader(self):
        """测试：使用不存在的负责人ID"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': 'NONEXISTENT_USER',
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(project_data)
    
    def test_update_with_invalid_status(self):
        """测试：更新为无效的项目状态"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        update_data = {'project_status': 'InvalidStatus'}
        
        with self.assertRaises(ValueError) as context:
            self.dao.update(self.test_project_id, update_data)
        
        self.assertIn('Invalid project_status', str(context.exception))
    
    def test_update_with_no_valid_fields(self):
        """测试：更新时没有有效字段"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'leader_id': self.test_user_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        update_data = {'invalid_field': 'value'}
        
        with self.assertRaises(ValueError) as context:
            self.dao.update(self.test_project_id, update_data)
        
        self.assertIn('No valid fields to update', str(context.exception))
    
    def test_find_by_invalid_status(self):
        """测试：使用无效状态查询"""
        with self.assertRaises(ValueError) as context:
            self.dao.find_by_status('InvalidStatus')
        
        self.assertIn('Invalid status', str(context.exception))


if __name__ == '__main__':
    unittest.main(verbosity=2)