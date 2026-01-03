from .base_dao import BaseDAO

class MonitoringIndicatorDAO(BaseDAO):

    def insert(self, indicator_id, indicator_name, unit):
        self.execute(
            "INSERT INTO MonitoringIndicator VALUES (?, ?, ?)",
            (indicator_id, indicator_name, unit)
        )

    def get_by_id(self, indicator_id):
        return self.query_one(
            "SELECT * FROM MonitoringIndicator WHERE indicator_id = ?",
            (indicator_id,)
        )

    def update_unit(self, indicator_id, unit):
        self.execute(
            "UPDATE MonitoringIndicator SET unit = ? WHERE indicator_id = ?",
            (unit, indicator_id)
        )

    def delete(self, indicator_id):
        self.execute(
            "DELETE FROM MonitoringIndicator WHERE indicator_id = ?",
            (indicator_id,)
        )
