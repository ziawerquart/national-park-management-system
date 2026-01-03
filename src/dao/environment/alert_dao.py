from .base_dao import BaseDAO

class AlertDAO(BaseDAO):

    def insert(self, alert_id, data_id, alert_level):
        self.execute(
            "INSERT INTO Alert VALUES (?, ?, ?)",
            (alert_id, data_id, alert_level)
        )

    def get_by_data(self, data_id):
        return self.query_one(
            "SELECT * FROM Alert WHERE data_id = ?",
            (data_id,)
        )

    def update_level(self, alert_id, level):
        self.execute(
            "UPDATE Alert SET alert_level = ? WHERE alert_id = ?",
            (level, alert_id)
        )

    def delete(self, alert_id):
        self.execute(
            "DELETE FROM Alert WHERE alert_id = ?",
            (alert_id,)
        )
