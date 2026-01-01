"""
Unit tests for ResearchProjectDAO
Tests normal operations and exception scenarios
"""
import unittest
import pymysql
from datetime import date, timedelta
import sys
import os

# Add src directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

from src.dao.research.research_project_dao import ResearchProjectDAO


class TestResearchProjectDAO(unittest.TestCase):
    """ResearchProjectDAO 测试类"""
    
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
        cls.dao = ResearchProjectDAO(cls.config)
        
        # 测试用的项目ID
        cls.test_project_id = 'TEST_PRJ001'
        cls.test_user_id = 'U001'  # 假设数据库中存在的用户
    
    def setUp(self):
        """每个测试方法执行前的准备"""
        # 清理可能存在的测试数据
        try:
            self.dao.delete(self.test_project_id)
        except:
            pass
    
    def tearDown(self):
        """每个测试方法执行后的清理"""
        # 清理测试数据
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
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress',
            'applicant_organization': 'Test University',
            'start_time': date.today(),
            'end_time': date.today() + timedelta(days=365),
            'research_field': 'Testing'
        }
        
        result = self.dao.create(project_data)
        
        self.assertEqual(result, self.test_project_id)
        self.assertTrue(self.dao.exists(self.test_project_id))
    
    def test_find_by_id_success(self):
        """测试：成功查询项目"""
        # 先创建项目
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        self.dao.create(project_data)
        
        # 查询项目
        result = self.dao.find_by_id(self.test_project_id)
        
        self.assertIsNotNone(result)
        self.assertEqual(result['project_id'], self.test_project_id)
        self.assertEqual(result['project_name'], 'Test Project')
        self.assertEqual(result['project_status'], 'InProgress')
    
    def test_find_by_id_not_found(self):
        """测试：查询不存在的项目"""
        result = self.dao.find_by_id('NONEXISTENT_PROJECT')
        
        self.assertIsNone(result)
    
    def test_find_by_status(self):
        """测试：根据状态查询项目"""
        # 先创建一个进行中的项目
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        self.dao.create(project_data)
        
        # 查询进行中的项目
        results = self.dao.find_by_status('InProgress')
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(p['project_id'] == self.test_project_id for p in results))
    
    def test_find_by_investigator(self):
        """测试：根据研究员查询项目"""
        # 创建项目
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        self.dao.create(project_data)
        
        # 查询该研究员的项目
        results = self.dao.find_by_investigator(self.test_user_id)
        
        self.assertIsInstance(results, list)
        self.assertTrue(len(results) > 0)
        self.assertTrue(any(p['project_id'] == self.test_project_id for p in results))
    
    def test_update_project_success(self):
        """测试：成功更新项目"""
        # 先创建项目
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Original Name',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        self.dao.create(project_data)
        
        # 更新项目
        update_data = {
            'project_name': 'Updated Name',
            'project_status': 'Completed'
        }
        affected_rows = self.dao.update(self.test_project_id, update_data)
        
        self.assertEqual(affected_rows, 1)
        
        # 验证更新
        updated_project = self.dao.find_by_id(self.test_project_id)
        self.assertEqual(updated_project['project_name'], 'Updated Name')
        self.assertEqual(updated_project['project_status'], 'Completed')
    
    def test_update_nonexistent_project(self):
        """测试：更新不存在的项目"""
        update_data = {'project_name': 'New Name'}
        affected_rows = self.dao.update('NONEXISTENT_PROJECT', update_data)
        
        self.assertEqual(affected_rows, 0)
    
    def test_delete_project_success(self):
        """测试：成功删除项目"""
        # 先创建项目
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        self.dao.create(project_data)
        
        # 删除项目
        affected_rows = self.dao.delete(self.test_project_id)
        
        self.assertEqual(affected_rows, 1)
        self.assertFalse(self.dao.exists(self.test_project_id))
    
    def test_count_by_status(self):
        """测试：统计各状态的项目数量"""
        results = self.dao.count_by_status()
        
        self.assertIsInstance(results, list)
        # 验证返回的数据结构
        if results:
            self.assertIn('status', results[0])
            self.assertIn('count', results[0])
    
    # ========== 异常场景测试 ==========
    
    def test_create_without_required_fields(self):
        """测试：缺少必填字段时创建失败"""
        incomplete_data = {
            'project_id': self.test_project_id,
            # 缺少 project_name
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        
        with self.assertRaises(ValueError) as context:
            self.dao.create(incomplete_data)
        
        self.assertIn('Missing required field', str(context.exception))
    
    def test_create_with_invalid_status(self):
        """测试：使用无效的项目状态"""
        invalid_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InvalidStatus'  # 无效状态
        }
        
        with self.assertRaises(ValueError) as context:
            self.dao.create(invalid_data)
        
        self.assertIn('Invalid project_status', str(context.exception))
    
    def test_create_duplicate_project_id(self):
        """测试：创建重复的项目ID"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        
        # 第一次创建成功
        self.dao.create(project_data)
        
        # 第二次创建应该失败
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(project_data)
    
    def test_create_with_nonexistent_investigator(self):
        """测试：使用不存在的研究员ID"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': 'NONEXISTENT_USER',  # 不存在的用户
            'project_status': 'InProgress'
        }
        
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(project_data)
    
    def test_update_with_invalid_status(self):
        """测试：更新为无效的项目状态"""
        # 先创建项目
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        self.dao.create(project_data)
        
        # 尝试更新为无效状态
        update_data = {'project_status': 'InvalidStatus'}
        
        with self.assertRaises(ValueError) as context:
            self.dao.update(self.test_project_id, update_data)
        
        self.assertIn('Invalid project_status', str(context.exception))
    
    def test_update_with_no_valid_fields(self):
        """测试：更新时没有有效字段"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': 'Test Project',
            'principal_investigator_id': self.test_user_id,
            'project_status': 'InProgress'
        }
        self.dao.create(project_data)
        
        # 尝试更新不允许的字段
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
    # 运行测试
    unittest.main(verbosity=2)