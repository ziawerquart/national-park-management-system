"""
Unit tests for ResearchDataRecordDAO
（与DDL、DAO完全对齐，解决外键依赖问题）
"""
import unittest
import pymysql
from datetime import datetime, date, timedelta
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from src.dao.research.research_data_record_dao import ResearchDataRecordDAO

class TestResearchDataRecordDAO(unittest.TestCase):
    """ResearchDataRecordDAO 测试类"""
    
    @classmethod
    def setUpClass(cls):
        """类级初始化：创建数据库连接+依赖数据（解决外键问题）"""
        cls.config = {
            'host': 'localhost',
            'port': 3306,
            'user': 'root',
            'password': '123456',
            'database': 'national_park_db',
            'charset': 'utf8mb4'
        }
        
        # 测试用ID（与依赖表数据对应）
        cls.test_collection_id = 'TEST_REC001'
        cls.test_project_id = 'TEST_PROJ001'
        cls.test_collector_id = 'TEST_USER001'
        cls.test_region_id = 'TEST_REG001'
        
        # 前置创建依赖表数据（User/Region/ResearchProject）
        try:
            cls._create_dependency_data()
        except Exception as e:
            raise RuntimeError(f"初始化依赖数据失败，无法执行测试：{e}") from e
        
        # DAO初始化
        cls.dao = ResearchDataRecordDAO(cls.config)
    
    @classmethod
    def tearDownClass(cls):
        """类级清理：删除测试数据（避免污染数据库）"""
        cls._cleanup_dependency_data()
    
    def setUp(self):
        """方法级初始化：删除当前测试记录"""
        try:
            # 清理主测试记录
            self.dao.delete(self.test_collection_id)
            # 清理分页测试创建的额外记录
            for i in range(15):
                self.dao.delete(f'{self.test_collection_id}_page_{i}')
            # 清理统计测试创建的额外记录
            self.dao.delete(f'{self.test_collection_id}_1')
            self.dao.delete(f'{self.test_collection_id}_2')
        except Exception as e:
            pass
    
    def tearDown(self):
        """方法级清理：删除当前测试记录"""
        self.setUp()
    
    @classmethod
    def _create_dependency_data(cls):
        """创建外键依赖的基础数据（修正字段名：approval_date + project_status）"""
        conn = pymysql.connect(**cls.config)
        cursor = conn.cursor()
        try:
            # 禁用外键检查，避免创建顺序问题
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
            
            # 1. 创建测试用户（collector_id/verified_by 依赖）
            cursor.execute("""
                INSERT IGNORE INTO user (user_id, user_name, role)
                VALUES (%s, %s, %s)
            """, (cls.test_collector_id, '测试采集员', 'researcher'))
            
            # 2. 创建测试区域（region_id 依赖）
            cursor.execute("""
                INSERT IGNORE INTO region (region_id, region_name, region_type)
                VALUES (%s, %s, %s)
            """, (cls.test_region_id, '测试区域', '保护区'))
            
            # 3. 创建测试项目（核心修复：字段名改为 approval_date + project_status）
            cursor.execute("""
                INSERT IGNORE INTO researchproject (
                    project_id, project_name, leader_id, approval_date, project_status
                ) VALUES (%s, %s, %s, %s, %s)
            """, (
                cls.test_project_id,
                '测试科研项目',
                cls.test_collector_id,
                date.today(),
                'ongoing'
            ))
            
            # 恢复外键检查
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
            conn.commit()
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()
            conn.close()
    
    @classmethod
    def _cleanup_dependency_data(cls):
        """清理依赖表测试数据"""
        conn = pymysql.connect(**cls.config)
        cursor = conn.cursor()
        try:
            # 禁用外键检查，避免删除顺序问题
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
            
            # 先删子表（ResearchDataRecord）
            cursor.execute("DELETE FROM researchdatarecord WHERE project_id = %s", (cls.test_project_id,))
            # 再删父表
            cursor.execute("DELETE FROM researchproject WHERE project_id = %s", (cls.test_project_id,))
            cursor.execute("DELETE FROM region WHERE region_id = %s", (cls.test_region_id,))
            cursor.execute("DELETE FROM user WHERE user_id = %s", (cls.test_collector_id,))
            
            # 恢复外键检查
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
            conn.commit()
        except Exception as e:
            print(f"清理依赖数据失败：{e}")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()
    
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
        # 兼容MySQL BOOLEAN的1/True两种返回形式
        self.assertTrue(updated_record['is_verified'] in (1, True))
    
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
        # 先创建不同来源的记录
        self.dao.create({
            'collection_id': f'{self.test_collection_id}_1',
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'field'
        })
        self.dao.create({
            'collection_id': f'{self.test_collection_id}_2',
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now(),
            'region_id': self.test_region_id,
            'data_source': 'system'
        })
        
        results = self.dao.count_by_source()
        
        self.assertIsInstance(results, list)
        source_types = [r['data_source'] for r in results]
        self.assertIn('field', source_types)
        self.assertIn('system', source_types)
        self.assertTrue(all('count' in r for r in results))
    
    # ========== 异常场景测试 ==========
    def test_create_without_required_fields(self):
        """测试：缺少必填字段时创建失败"""
        incomplete_data = {
            'collection_id': self.test_collection_id,
            'project_id': self.test_project_id
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
    """测试：分页查询（最终修复版）"""
    # 步骤1：清空当前测试项目的所有旧记录
    try:
        conn = pymysql.connect(**self.config)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM researchdatarecord WHERE project_id = %s", (self.test_project_id,))
        conn.commit()
    except Exception as e:
        print(f"清空旧记录失败：{e}")
    finally:
        cursor.close()
        conn.close()
    
    # 步骤2：创建15条唯一的测试记录
    test_record_ids = []
    for i in range(15):
        record_id = f'{self.test_collection_id}_page_{i}_{datetime.now().microsecond}'  # 加微秒确保唯一
        test_record_ids.append(record_id)
        self.dao.create({
            'collection_id': record_id,
            'project_id': self.test_project_id,
            'collector_id': self.test_collector_id,
            'collection_time': datetime.now() - timedelta(minutes=i),
            'region_id': self.test_region_id,
            'data_source': 'field'
        })
    
    # 步骤3：分页查询并过滤出当前测试的记录
    raw_page1 = self.dao.find_all(limit=10, offset=0)
    raw_page2 = self.dao.find_all(limit=10, offset=10)
    
    # 过滤：只保留当前测试创建的记录
    results_page1 = [r for r in raw_page1 if r['collection_id'] in test_record_ids]
    results_page2 = [r for r in raw_page2 if r['collection_id'] in test_record_ids]
    
    # 步骤4：验证结果
    self.assertIsInstance(results_page1, list)
    self.assertIsInstance(results_page2, list)
    self.assertEqual(len(results_page1), 10)
    self.assertEqual(len(results_page2), 5)
    
    # 验证分页无重复
    page1_ids = {r['collection_id'] for r in results_page1}
    page2_ids = {r['collection_id'] for r in results_page2}
    self.assertEqual(len(page1_ids & page2_ids), 0)

if __name__ == '__main__':
    unittest.main(verbosity=2)