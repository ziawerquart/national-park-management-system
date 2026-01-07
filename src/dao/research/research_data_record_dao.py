"""
ResearchDataRecord DAO - Data Access Object for ResearchDataRecord table
(与全局DDL严格一致)
"""
from typing import Optional, Dict, Any, List
from datetime import datetime
from .base_dao import BaseDAO

class ResearchDataRecordDAO(BaseDAO):
    """科研数据采集记录数据访问对象"""

    def create(self, record_data: Dict[str, Any]) -> str:
        """
        创建新的数据采集记录
        必填字段: collection_id、project_id、collector_id、collection_time、region_id、data_source
        可选字段: 其余字段（允许为NULL）
        """
        # 校验必填字段
        required_fields = [
            'collection_id', 'project_id', 'collector_id',
            'collection_time', 'region_id', 'data_source'
        ]
        for field in required_fields:
            if field not in record_data or record_data[field] is None:
                raise ValueError(f"Missing required field: {field}")

        # 校验数据来源合法性
        valid_sources = ['field', 'system']
        if record_data['data_source'] not in valid_sources:
            raise ValueError(f"Invalid data_source. Must be one of: {valid_sources}")

        # SQL与DDL字段顺序完全一致
        sql = """
            INSERT INTO ResearchDataRecord (
                collection_id, project_id, collector_id, collection_time,
                region_id, collection_content, data_source, sample_id,
                monitoring_data_id, data_file_path, remarks, is_verified,
                verified_by, verified_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        params = (
            record_data['collection_id'],
            record_data['project_id'],
            record_data['collector_id'],
            record_data['collection_time'],
            record_data['region_id'],
            record_data.get('collection_content'),  # 可选字段
            record_data['data_source'],
            record_data.get('sample_id'),          # 可选字段
            record_data.get('monitoring_data_id'), # 可选字段
            record_data.get('data_file_path'),     # 可选字段
            record_data.get('remarks'),            # 可选字段
            record_data.get('is_verified', False), # 默认False
            record_data.get('verified_by'),        # 可选字段
            record_data.get('verified_at')         # 可选字段
        )

        return self.execute_insert(sql, params)

    def find_by_id(self, collection_id: str) -> Optional[Dict[str, Any]]:
        """根据采集ID查询单条记录"""
        sql = """
            SELECT 
                collection_id, project_id, collector_id, collection_time,
                region_id, collection_content, data_source, sample_id,
                monitoring_data_id, data_file_path, remarks, is_verified,
                verified_by, verified_at
            FROM ResearchDataRecord
            WHERE collection_id = %s
        """
        results = self.execute_query(sql, (collection_id,))
        return results[0] if results else None

    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        """分页查询所有记录（按采集时间倒序）"""
        sql = """
            SELECT 
                collection_id, project_id, collector_id, collection_time,
                region_id, collection_content, data_source, sample_id,
                monitoring_data_id, data_file_path, remarks, is_verified,
                verified_by, verified_at
            FROM ResearchDataRecord
            ORDER BY collection_time DESC
            LIMIT %s OFFSET %s
        """
        return self.execute_query(sql, (limit, offset))

    def find_by_project(self, project_id: str) -> List[Dict[str, Any]]:
        """根据项目ID查询记录"""
        sql = """
            SELECT 
                collection_id, project_id, collector_id, collection_time,
                region_id, collection_content, data_source, sample_id,
                monitoring_data_id, data_file_path, remarks, is_verified,
                verified_by, verified_at
            FROM ResearchDataRecord
            WHERE project_id = %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (project_id,))

    def find_by_collector(self, collector_id: str) -> List[Dict[str, Any]]:
        """根据采集员ID查询记录"""
        sql = """
            SELECT 
                collection_id, project_id, collector_id, collection_time,
                region_id, collection_content, data_source, sample_id,
                monitoring_data_id, data_file_path, remarks, is_verified,
                verified_by, verified_at
            FROM ResearchDataRecord
            WHERE collector_id = %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (collector_id,))

    def find_by_region(self, region_id: str) -> List[Dict[str, Any]]:
        """根据区域ID查询记录"""
        sql = """
            SELECT 
                collection_id, project_id, collector_id, collection_time,
                region_id, collection_content, data_source, sample_id,
                monitoring_data_id, data_file_path, remarks, is_verified,
                verified_by, verified_at
            FROM ResearchDataRecord
            WHERE region_id = %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (region_id,))

    def find_by_time_range(self, start_time: datetime, end_time: datetime) -> List[Dict[str, Any]]:
        """根据时间范围查询记录"""
        sql = """
            SELECT 
                collection_id, project_id, collector_id, collection_time,
                region_id, collection_content, data_source, sample_id,
                monitoring_data_id, data_file_path, remarks, is_verified,
                verified_by, verified_at
            FROM ResearchDataRecord
            WHERE collection_time BETWEEN %s AND %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (start_time, end_time))

    def update(self, collection_id: str, update_data: Dict[str, Any]) -> int:
        """更新记录（仅允许更新DDL中存在的字段）"""
        allowed_fields = {
            'project_id', 'collector_id', 'collection_time', 'region_id',
            'collection_content', 'data_source', 'sample_id', 'monitoring_data_id',
            'data_file_path', 'remarks', 'is_verified', 'verified_by', 'verified_at'
        }

        # 过滤无效字段
        valid_updates = {k: v for k, v in update_data.items() if k in allowed_fields}
        if not valid_updates:
            raise ValueError("No valid fields to update")

        # 校验数据来源（若更新该字段）
        if 'data_source' in valid_updates:
            if valid_updates['data_source'] not in ['field', 'system']:
                raise ValueError("Invalid data_source. Must be 'field' or 'system'")

        # 构建更新SQL
        set_clause = ', '.join([f"{field} = %s" for field in valid_updates])
        sql = f"""
            UPDATE ResearchDataRecord
            SET {set_clause}
            WHERE collection_id = %s
        """
        params = tuple(valid_updates.values()) + (collection_id,)

        return self.execute_update(sql, params)

    def delete(self, collection_id: str) -> int:
        """根据采集ID删除记录"""
        sql = "DELETE FROM ResearchDataRecord WHERE collection_id = %s"
        return self.execute_update(sql, (collection_id,))

    def count_by_source(self) -> List[Dict[str, Any]]:
        """按数据来源统计记录数量"""
        sql = """
            SELECT data_source, COUNT(*) AS count
            FROM ResearchDataRecord
            GROUP BY data_source
            ORDER BY count DESC
        """
        return self.execute_query(sql)

    def exists(self, collection_id: str) -> bool:
        """判断采集ID是否存在"""
        sql = "SELECT COUNT(*) AS count FROM ResearchDataRecord WHERE collection_id = %s"
        result = self.execute_query(sql, (collection_id,))
        return result[0]['count'] > 0 if result else False