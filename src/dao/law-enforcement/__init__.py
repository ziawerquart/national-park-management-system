# 统一导出业务DAO类，简化上层调用
from .illegal_behavior_dao import IllegalBehaviorDao
from .law_enforcement_officer_dao import LawEnforcementOfficerDao

__all__ = ["IllegalBehaviorDao", "LawEnforcementOfficerDao"]