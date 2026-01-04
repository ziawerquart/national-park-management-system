"""
ResearchDataRecord DAO - Data Access Object for ResearchDataRecord table
(DDL-aligned merged version)
"""
from typing import Optional, Dict, Any, List
from datetime import datetime
from .base_dao import BaseDAO


class ResearchDataRecordDAO(BaseDAO):
    """科研数据采集记录数据访问对象（与最新DDL完全一致）"""

    def create(self, record_data: Dict[str, Any]) -> str:
        """
        创建新的数据采集记录
        必填字段:
            - collection_id
            - project_id
            - collector_id
            - collection_time
            - region_id
            - data_source (field/system)
        可选字段:
            - collection_content
            - sample_id
            - monitoring_data_id
            - data_file_path
            - remarks
            - is_verified
            - verified_by
            - verified_at
        """
        required_fields = [
            'collection_id',
            'project_id',
            'collector_id',
            'collection_time',
            'region_id',
            'data_source'
        ]
        for field in required_fields:
            if field not in record_data:
                raise ValueError(f"Missing required field: {field}")

        valid_sources = ['field', 'system']
        if record_data['data_source'] not in valid_sources:
            raise ValueError(f"Invalid data_source. Must be one of: {valid_sources}")

        sql = """
            INSERT INTO ResearchDataRecord
            (collection_id, project_id, collector_id, collection_time,
             region_id, collection_content, data_source,
             sample_id, monitoring_data_id, data_file_path,
             remarks, is_verified, verified_by, verified_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        params = (
            record_data['collection_id'],
            record_data['project_id'],
            record_data['collector_id'],
            record_data['collection_time'],
            record_data['region_id'],
            record_data.get('collection_content'),
            record_data['data_source'],
            record_data.get('sample_id'),
            record_data.get('monitoring_data_id'),
            record_data.get('data_file_path'),
            record_data.get('remarks'),
            record_data.get('is_verified', False),
            record_data.get('verified_by'),
            record_data.get('verified_at')
        )

        return self.execute_insert(sql, params)

    def find_by_id(self, collection_id: str) -> Optional[Dict[str, Any]]:
        sql = """
            SELECT collection_id, project_id, collector_id, collection_time,
                   region_id, collection_content, data_source,
                   sample_id, monitoring_data_id, data_file_path,
                   remarks, is_verified, verified_by, verified_at
            FROM ResearchDataRecord
            WHERE collection_id = %s
        """
        results = self.execute_query(sql, (collection_id,))
        return results[0] if results else None

    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        sql = """
            SELECT collection_id, project_id, collector_id, collection_time,
                   region_id, collection_content, data_source,
                   sample_id, monitoring_data_id, data_file_path,
                   remarks, is_verified, verified_by, verified_at
            FROM ResearchDataRecord
            ORDER BY collection_time DESC
            LIMIT %s OFFSET %s
        """
        return self.execute_query(sql, (limit, offset))

    def find_by_project(self, project_id: str) -> List[Dict[str, Any]]:
        sql = """
            SELECT *
            FROM ResearchDataRecord
            WHERE project_id = %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (project_id,))

    def find_by_collector(self, collector_id: str) -> List[Dict[str, Any]]:
        sql = """
            SELECT *
            FROM ResearchDataRecord
            WHERE collector_id = %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (collector_id,))

    def find_by_region(self, region_id: str) -> List[Dict[str, Any]]:
        sql = """
            SELECT *
            FROM ResearchDataRecord
            WHERE region_id = %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (region_id,))

    def find_by_time_range(self, start_time: datetime, end_time: datetime) -> List[Dict[str, Any]]:
        sql = """
            SELECT *
            FROM ResearchDataRecord
            WHERE collection_time BETWEEN %s AND %s
            ORDER BY collection_time DESC
        """
        return self.execute_query(sql, (start_time, end_time))

    def update(self, collection_id: str, update_data: Dict[str, Any]) -> int:
        allowed_fields = {
            'project_id',
            'collector_id',
            'collection_time',
            'region_id',
            'collection_content',
            'data_source',
            'sample_id',
            'monitoring_data_id',
            'data_file_path',
            'remarks',
            'is_verified',
            'verified_by',
            'verified_at'
        }

        update_fields = {k: v for k, v in update_data.items() if k in allowed_fields}
        if not update_fields:
            raise ValueError("No valid fields to update")

        if 'data_source' in update_fields:
            valid_sources = ['field', 'system']
            if update_fields['data_source'] not in valid_sources:
                raise ValueError(f"Invalid data_source. Must be one of: {valid_sources}")

        set_clause = ', '.join([f"{field} = %s" for field in update_fields])
        sql = f"UPDATE ResearchDataRecord SET {set_clause} WHERE collection_id = %s"
        params = tuple(update_fields.values()) + (collection_id,)

        return self.execute_update(sql, params)

    def delete(self, collection_id: str) -> int:
        sql = "DELETE FROM ResearchDataRecord WHERE collection_id = %s"
        return self.execute_update(sql, (collection_id,))

    def count_by_source(self) -> List[Dict[str, Any]]:
        sql = """
            SELECT data_source, COUNT(*) AS count
            FROM ResearchDataRecord
            GROUP BY data_source
            ORDER BY count DESC
        """
        return self.execute_query(sql)

    def exists(self, collection_id: str) -> bool:
        sql = "SELECT COUNT(*) AS count FROM ResearchDataRecord WHERE collection_id = %s"
        result = self.execute_query(sql, (collection_id,))
        return result[0]['count'] > 0 if result else False
