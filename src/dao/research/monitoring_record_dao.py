"""
MonitoringRecord DAO - Data Access Object for MonitoringRecord table
Implements CRUD operations for monitoring record management
"""
from typing import Optional, Dict, Any, List
from datetime import datetime
from .base_dao import BaseDAO


class MonitoringRecordDAO(BaseDAO):
    """监测记录数据访问对象"""
    
    def create(self, record_data: Dict[str, Any]) -> str:
        """
        创建新的监测记录
        
        Args:
            record_data: 监测记录数据字典，必须包含:
                - record_id: 记录ID
                - monitor_time: 监测时间
                - data_type: 数据类型
                可选字段:
                - data_value: 数据值
                - habitat_id: 栖息地ID
                - species_id: 物种ID
                - collection_id: 数据采集ID
                
        Returns:
            str: 创建的记录ID
            
        Raises:
            ValueError: 缺少必填字段
            pymysql.IntegrityError: 违反数据库约束（如外键不存在）
            pymysql.Error: 其他数据库错误
        """
        # 验证必填字段
        required_fields = ['record_id', 'monitor_time', 'data_type']
        for field in required_fields:
            if field not in record_data:
                raise ValueError(f"Missing required field: {field}")
        
        sql = """
            INSERT INTO MonitoringRecord 
            (record_id, monitor_time, data_type, data_value,
             habitat_id, species_id, collection_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        params = (
            record_data['record_id'],
            record_data['monitor_time'],
            record_data['data_type'],
            record_data.get('data_value'),
            record_data.get('habitat_id'),
            record_data.get('species_id'),
            record_data.get('collection_id')
        )
        
        return self.execute_insert(sql, params)
    
    def find_by_id(self, record_id: str) -> Optional[Dict[str, Any]]:
        """
        根据记录ID查询监测记录
        
        Args:
            record_id: 记录ID
            
        Returns:
            Optional[Dict[str, Any]]: 监测记录信息字典，不存在返回None
        """
        sql = """
            SELECT record_id, monitor_time, data_type, data_value,
                   habitat_id, species_id, collection_id
            FROM MonitoringRecord
            WHERE record_id = %s
        """
        
        results = self.execute_query(sql, (record_id,))
        return results[0] if results else None
    
    def find_all(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        """
        查询所有监测记录（支持分页）
        
        Args:
            limit: 返回记录数限制（默认100）
            offset: 偏移量（默认0）
            
        Returns:
            List[Dict[str, Any]]: 监测记录信息列表
        """
        sql = """
            SELECT record_id, monitor_time, data_type, data_value,
                   habitat_id, species_id, collection_id
            FROM MonitoringRecord
            ORDER BY monitor_time DESC
            LIMIT %s OFFSET %s
        """
        
        return self.execute_query(sql, (limit, offset))
    
    def find_by_species(self, species_id: str) -> List[Dict[str, Any]]:
        """
        根据物种ID查询该物种的所有监测记录
        
        Args:
            species_id: 物种ID
            
        Returns:
            List[Dict[str, Any]]: 监测记录信息列表
        """
        sql = """
            SELECT record_id, monitor_time, data_type, data_value,
                   habitat_id, species_id, collection_id
            FROM MonitoringRecord
            WHERE species_id = %s
            ORDER BY monitor_time DESC
        """
        
        return self.execute_query(sql, (species_id,))
    
    def find_by_habitat(self, habitat_id: str) -> List[Dict[str, Any]]:
        """
        根据栖息地ID查询该栖息地的所有监测记录
        
        Args:
            habitat_id: 栖息地ID
            
        Returns:
            List[Dict[str, Any]]: 监测记录信息列表
        """
        sql = """
            SELECT record_id, monitor_time, data_type, data_value,
                   habitat_id, species_id, collection_id
            FROM MonitoringRecord
            WHERE habitat_id = %s
            ORDER BY monitor_time DESC
        """
        
        return self.execute_query(sql, (habitat_id,))
    
    def find_by_collection(self, collection_id: str) -> List[Dict[str, Any]]:
        """
        根据数据采集ID查询该次采集的所有监测记录
        
        Args:
            collection_id: 数据采集ID
            
        Returns:
            List[Dict[str, Any]]: 监测记录信息列表
        """
        sql = """
            SELECT record_id, monitor_time, data_type, data_value,
                   habitat_id, species_id, collection_id
            FROM MonitoringRecord
            WHERE collection_id = %s
            ORDER BY monitor_time DESC
        """
        
        return self.execute_query(sql, (collection_id,))
    
    def find_by_data_type(self, data_type: str) -> List[Dict[str, Any]]:
        """
        根据数据类型查询监测记录
        
        Args:
            data_type: 数据类型（如 'Population Count', 'Behavior Observation'）
            
        Returns:
            List[Dict[str, Any]]: 监测记录信息列表
        """
        sql = """
            SELECT record_id, monitor_time, data_type, data_value,
                   habitat_id, species_id, collection_id
            FROM MonitoringRecord
            WHERE data_type = %s
            ORDER BY monitor_time DESC
        """
        
        return self.execute_query(sql, (data_type,))
    
    def find_by_time_range(self, start_time: datetime, end_time: datetime) -> List[Dict[str, Any]]:
        """
        根据时间范围查询监测记录
        
        Args:
            start_time: 开始时间
            end_time: 结束时间
            
        Returns:
            List[Dict[str, Any]]: 监测记录信息列表
        """
        sql = """
            SELECT record_id, monitor_time, data_type, data_value,
                   habitat_id, species_id, collection_id
            FROM MonitoringRecord
            WHERE monitor_time BETWEEN %s AND %s
            ORDER BY monitor_time DESC
        """
        
        return self.execute_query(sql, (start_time, end_time))
    
    def update(self, record_id: str, update_data: Dict[str, Any]) -> int:
        """
        更新监测记录信息
        
        Args:
            record_id: 记录ID
            update_data: 要更新的字段字典（不包含record_id）
            
        Returns:
            int: 受影响的行数（0表示记录不存在）
            
        Raises:
            ValueError: 尝试更新不允许的字段
            pymysql.Error: 数据库错误
        """
        # 允许更新的字段
        allowed_fields = {
            'monitor_time', 'data_type', 'data_value',
            'habitat_id', 'species_id', 'collection_id'
        }
        
        # 过滤出允许更新的字段
        update_fields = {k: v for k, v in update_data.items() if k in allowed_fields}
        
        if not update_fields:
            raise ValueError("No valid fields to update")
        
        # 构建SQL语句
        set_clause = ', '.join([f"{field} = %s" for field in update_fields.keys()])
        sql = f"UPDATE MonitoringRecord SET {set_clause} WHERE record_id = %s"
        
        params = tuple(update_fields.values()) + (record_id,)
        
        return self.execute_update(sql, params)
    
    def delete(self, record_id: str) -> int:
        """
        删除监测记录
        
        Args:
            record_id: 记录ID
            
        Returns:
            int: 受影响的行数（0表示记录不存在）
            
        Raises:
            pymysql.Error: 数据库错误
        """
        sql = "DELETE FROM MonitoringRecord WHERE record_id = %s"
        return self.execute_update(sql, (record_id,))
    
    def count_by_data_type(self) -> List[Dict[str, Any]]:
        """
        统计各数据类型的记录数量
        
        Returns:
            List[Dict[str, Any]]: 包含data_type和count的列表
        """
        sql = """
            SELECT data_type, COUNT(*) AS count
            FROM MonitoringRecord
            GROUP BY data_type
            ORDER BY count DESC
        """
        
        return self.execute_query(sql)
    
    def count_by_species(self) -> List[Dict[str, Any]]:
        """
        统计各物种的监测记录数量
        
        Returns:
            List[Dict[str, Any]]: 包含species_id和count的列表
        """
        sql = """
            SELECT species_id, COUNT(*) AS count
            FROM MonitoringRecord
            WHERE species_id IS NOT NULL
            GROUP BY species_id
            ORDER BY count DESC
        """
        
        return self.execute_query(sql)
    
    def exists(self, record_id: str) -> bool:
        """
        检查监测记录是否存在
        
        Args:
            record_id: 记录ID
            
        Returns:
            bool: 存在返回True，否则返回False
        """
        sql = "SELECT COUNT(*) AS count FROM MonitoringRecord WHERE record_id = %s"
        result = self.execute_query(sql, (record_id,))
        return result[0]['count'] > 0 if result else False