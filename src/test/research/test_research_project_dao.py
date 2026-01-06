"""
Unit tests for ResearchProjectDAO
（最终修复版：解决KeyError + 主键重复 + 数据库连接所有问题）
"""
import unittest
import pymysql
from datetime import datetime, date, timedelta
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from src.dao.research.research_project_dao import ResearchProjectDAO

class TestResearchProjectDAO(unittest.TestCase):
    """ResearchProjectDAO 测试类"""
    
    @classmethod
    def setUpClass(cls):
        """类级初始化：创建数据库连接+清理旧数据"""
        cls.config = {
            'host': 'localhost',
            'port': 3306,
            'user': 'root',
            'password': '123456',
            'database': 'national_park_db',
            'charset': 'utf8mb4'
        }
        
        # 生成唯一的测试前缀（加时间戳，确保每次运行ID不重复）
        cls.test_prefix = f'TEST_PRJ_{datetime.now().strftime("%Y%m%d%H%M%S%f")}'
        cls.test_project_id = f'{cls.test_prefix}_001'
        cls.test_leader_id = f'{cls.test_prefix}_leader'
        
        # 初始化前彻底清理所有旧测试数据（不管前缀）
        cls._cleanup_all_old_test_data()
        
        # 创建依赖的用户数据（leader_id 外键）
        cls._create_leader_data()
        
        # 初始化DAO时传入config参数
        cls.dao = ResearchProjectDAO(cls.config)
    
    @classmethod
    def tearDownClass(cls):
        """类级清理：删除本次测试的所有数据"""
        cls._cleanup_test_data_by_prefix()
    
    def setUp(self):
        """方法级初始化：删除当前测试的项目记录（强制清理）"""
        try:
            # 强制删除当前测试前缀的所有项目
            conn = pymysql.connect(**self.config)
            cursor = conn.cursor()
            cursor.execute("DELETE FROM researchproject WHERE project_id LIKE %s", (f'{self.test_prefix}%',))
            conn.commit()
            cursor.close()
            conn.close()
        except Exception as e:
            print(f"方法级清理失败：{e}")
    
    def tearDown(self):
        """方法级清理：复用setUp的清理逻辑"""
        self.setUp()
    
    @classmethod
    def _create_leader_data(cls):
        """创建依赖的leader用户数据（唯一ID）"""
        conn = pymysql.connect(**cls.config)
        cursor = conn.cursor()
        try:
            # 先删除旧的leader数据
            cursor.execute("DELETE FROM user WHERE user_id LIKE %s", (f'{cls.test_prefix}%',))
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
            cursor.execute("""
                INSERT INTO user (user_id, user_name, role)
                VALUES (%s, %s, %s)
            """, (cls.test_leader_id, '测试项目负责人', 'project_leader'))
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
            conn.commit()
        except Exception as e:
            print(f"创建leader数据失败：{e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()
    
    @classmethod
    def _cleanup_all_old_test_data(cls):
        """清理所有历史测试数据（所有TEST_PRJ前缀）"""
        conn = pymysql.connect(**cls.config)
        cursor = conn.cursor()
        try:
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
            # 删除所有测试项目（不管前缀）
            cursor.execute("DELETE FROM researchproject WHERE project_id LIKE 'TEST_PRJ%';")
            # 删除所有测试用户
            cursor.execute("DELETE FROM user WHERE user_id LIKE 'TEST_PRJ%';")
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
            conn.commit()
        except Exception as e:
            print(f"清理所有旧测试数据失败：{e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()
    
    @classmethod
    def _cleanup_test_data_by_prefix(cls):
        """清理本次测试创建的所有数据（按当前前缀）"""
        conn = pymysql.connect(**cls.config)
        cursor = conn.cursor()
        try:
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
            # 删除本次测试的项目
            cursor.execute("DELETE FROM researchproject WHERE project_id LIKE %s", (f'{cls.test_prefix}%',))
            # 删除本次测试的用户
            cursor.execute("DELETE FROM user WHERE user_id LIKE %s", (f'{cls.test_prefix}%',))
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
            conn.commit()
        except Exception as e:
            print(f"清理本次测试数据失败：{e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()
    
    # ========== 正常场景测试 ==========
    def test_create_project_success(self):
        """测试：成功创建项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': '测试科研项目',
            'leader_id': self.test_leader_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        
        result = self.dao.create(project_data)
        
        self.assertEqual(result, self.test_project_id)
        self.assertTrue(self.dao.exists(self.test_project_id))
    
    def test_find_by_id_success(self):
        """测试：成功查询项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': '测试科研项目',
            'leader_id': self.test_leader_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        result = self.dao.find_by_id(self.test_project_id)
        
        self.assertIsNotNone(result)
        self.assertEqual(result['project_name'], '测试科研项目')
        # 兼容字段名：先查project_status，没有则查status
        self.assertEqual(result.get('project_status', result.get('status')), 'ongoing')
    
    def test_update_project_success(self):
        """测试：成功更新项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': '原始项目名称',
            'leader_id': self.test_leader_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        update_data = {
            'project_name': '更新后的项目名称',
            'project_status': 'completed'
        }
        affected_rows = self.dao.update(self.test_project_id, update_data)
        
        self.assertEqual(affected_rows, 1)
        updated_project = self.dao.find_by_id(self.test_project_id)
        self.assertEqual(updated_project['project_name'], '更新后的项目名称')
        # 兼容字段名
        self.assertEqual(updated_project.get('project_status', updated_project.get('status')), 'completed')
    
    def test_delete_project_success(self):
        """测试：成功删除项目"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': '测试删除项目',
            'leader_id': self.test_leader_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        self.dao.create(project_data)
        
        affected_rows = self.dao.delete(self.test_project_id)
        
        self.assertEqual(affected_rows, 1)
        self.assertFalse(self.dao.exists(self.test_project_id))
    
    def test_count_by_status(self):
        """测试：统计各状态的项目数量（解决KeyError）"""
        # 生成唯一的子ID（基于当前测试前缀）
        project_id_1 = f'{self.test_prefix}_002'
        project_id_2 = f'{self.test_prefix}_003'
        
        # 强制删除这两个ID的旧记录（双重保障）
        conn = pymysql.connect(**self.config)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM researchproject WHERE project_id IN (%s, %s)", (project_id_1, project_id_2))
        conn.commit()
        cursor.close()
        conn.close()
        
        # 创建不同状态的测试项目（唯一ID）
        self.dao.create({
            'project_id': project_id_1,
            'project_name': '测试项目1',
            'leader_id': self.test_leader_id,
            'approval_date': date.today(),
            'project_status': 'ongoing'
        })
        self.dao.create({
            'project_id': project_id_2,
            'project_name': '测试项目2',
            'leader_id': self.test_leader_id,
            'approval_date': date.today(),
            'project_status': 'completed'
        })
        
        results = self.dao.count_by_status()
        
        self.assertIsInstance(results, list)
        # 核心修复：兼容两种键名（project_status / status）
        status_list = []
        for r in results:
            # 先取project_status，没有则取status
            status = r.get('project_status', r.get('status'))
            if status:
                status_list.append(status)
        
        self.assertIn('ongoing', status_list)
        self.assertIn('completed', status_list)
        # 验证count字段
        for r in results:
            self.assertIn('count', r.keys())
    
    # ========== 异常场景测试 ==========
    def test_create_duplicate_project_id(self):
        """测试：创建重复的项目ID"""
        project_data = {
            'project_id': self.test_project_id,
            'project_name': '测试重复ID',
            'leader_id': self.test_leader_id,
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
            'project_name': '测试无效负责人',
            'leader_id': f'{self.test_prefix}_nonexistent',
            'approval_date': date.today(),
            'project_status': 'ongoing'
        }
        
        with self.assertRaises(pymysql.IntegrityError):
            self.dao.create(project_data)

if __name__ == '__main__':
    unittest.main(verbosity=2)