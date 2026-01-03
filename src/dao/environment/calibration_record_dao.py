from .base_dao import BaseDAO

class CalibrationRecordDAO(BaseDAO):

    def insert(self, record_id, device_id, time):
        self.execute(
            "INSERT INTO CalibrationRecord VALUES (?, ?, ?)",
            (record_id, device_id, time)
        )

    def get_by_device(self, device_id):
        return self.query_all(
            "SELECT * FROM CalibrationRecord WHERE device_id = ?",
            (device_id,)
        )

    def delete(self, record_id):
        self.execute(
            "DELETE FROM CalibrationRecord WHERE record_id = ?",
            (record_id,)
        )
