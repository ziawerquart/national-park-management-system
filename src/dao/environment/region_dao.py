from .base_dao import BaseDAO

class RegionDAO(BaseDAO):

    def insert(self, region_id, region_name):
        self.execute(
            "INSERT INTO Region(region_id, region_name) VALUES (?, ?)",
            (region_id, region_name)
        )

    def get_by_id(self, region_id):
        return self.query_one(
            "SELECT * FROM Region WHERE region_id = ?",
            (region_id,)
        )

    def update_name(self, region_id, region_name):
        self.execute(
            "UPDATE Region SET region_name = ? WHERE region_id = ?",
            (region_name, region_id)
        )

    def delete(self, region_id):
        self.execute(
            "DELETE FROM Region WHERE region_id = ?",
            (region_id,)
        )
