from .base_dao import BaseDAO

class EnvironmentalDataDAO(BaseDAO):

    def insert(self, data_id, indicator_id, region_id, device_id,
               monitor_value, is_abnormal):
        self.execute(
            """
            INSERT INTO EnvironmentalData
            (data_id, indicator_id, region_id, device_id, monitor_value, is_abnormal)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (data_id, indicator_id, region_id, device_id, monitor_value, is_abnormal)
        )

    def get_by_id(self, data_id):
        return self.query_one(
            "SELECT * FROM EnvironmentalData WHERE data_id = ?",
            (data_id,)
        )

    def update_value(self, data_id, value):
        self.execute(
            "UPDATE EnvironmentalData SET monitor_value = ? WHERE data_id = ?",
            (value, data_id)
        )

    def delete(self, data_id):
        self.execute(
            "DELETE FROM EnvironmentalData WHERE data_id = ?",
            (data_id,)
        )
