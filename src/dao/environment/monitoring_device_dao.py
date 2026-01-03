from .base_dao import BaseDAO

class MonitoringDeviceDAO(BaseDAO):

    def insert(self, device_id, region_id, cycle):
        self.execute(
            "INSERT INTO MonitoringDevice VALUES (?, ?, ?)",
            (device_id, region_id, cycle)
        )

    def get(self, device_id):
        return self.query_one(
            "SELECT * FROM MonitoringDevice WHERE device_id = ?",
            (device_id,)
        )

    def update_cycle(self, device_id, cycle):
        self.execute(
            "UPDATE MonitoringDevice SET calibration_cycle = ? WHERE device_id = ?",
            (cycle, device_id)
        )

    def delete(self, device_id):
        self.execute(
            "DELETE FROM MonitoringDevice WHERE device_id = ?",
            (device_id,)
        )
