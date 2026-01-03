环境监测系统持久层（DAO）与测试说明
1. 项目说明

本模块实现了环境监测系统的持久层（Data Access Layer, DAO），并配套编写了单元测试代码，用于验证各数据表的核心 CRUD（新增、查询、修改、删除）操作是否正确。

持久层采用 DAO 模式，将 SQL 操作与业务逻辑解耦，测试阶段使用 SQLite 内存数据库，以保证测试的独立性与可重复性。

2. 目录结构说明
project_root/
├── src/
│   └── dao/
│       └── environment/
│           ├── base_dao.py
│           ├── region_dao.py
│           ├── monitoring_indicator_dao.py
│           ├── monitoring_device_dao.py
│           ├── environmental_data_dao.py
│           ├── alert_dao.py
│           └── calibration_record_dao.py
│
├── tests/
│   └── environment/
│       ├── test_region.py
│       ├── test_monitoring_indicator.py
│       ├── test_monitoring_device.py
│       ├── test_environmental_data.py
│       ├── test_alert.py
│       └── test_calibration_record.py
│
└── README.md

3. 持久层设计说明（DAO）
3.1 BaseDAO（基础类）

BaseDAO 负责：

建立数据库连接

提供通用的 execute、query_one、query_all 方法

统一管理事务提交与资源释放

class BaseDAO:
    def __init__(self, db_path=":memory:"):
        ...


特点：

默认使用 :memory:，适合单元测试

支持后续替换为文件数据库或 MySQL

启用外键约束（PRAGMA foreign_keys = ON）

3.2 各业务 DAO

每个 DAO 类对应一张数据表，仅负责该表的 SQL 操作，例如：

RegionDAO → Region

MonitoringIndicatorDAO → MonitoringIndicator

MonitoringDeviceDAO → MonitoringDevice

EnvironmentalDataDAO → EnvironmentalData

AlertDAO → Alert

CalibrationRecordDAO → CalibrationRecord

每个 DAO 至少包含：

insert(...)

get_by_id(...)

update(...)

delete(...)

4. 测试设计说明
4.1 测试目标

测试代码用于验证：

数据是否能够正确插入数据库

查询结果是否符合预期

更新操作是否生效

删除操作是否真正删除数据

异常情况（如重复主键）是否被正确处理

4.2 测试方式

使用 unittest 框架

每个测试文件对应一个 DAO

测试数据库为 SQLite 内存数据库

每个测试用例独立执行，不依赖其他测试结果

示例测试流程：

def test_crud(self):
    self.dao.insert(...)
    row = self.dao.get_by_id(...)
    self.assertEqual(...)
    self.dao.update(...)
    self.dao.delete(...)

5. 如何运行测试
5.1 进入项目根目录
cd project_root

5.2 运行所有环境系统持久层测试
python -m unittest discover tests/environment

5.3 正常执行结果示例
......
----------------------------------------------------------------------
Ran 6 tests in 0.008s

OK


说明：

所有 DAO 的 CRUD 操作执行成功

持久层逻辑正确

数据库约束生效


6. 设计说明

采用 DAO 模式实现数据访问层，提升系统可维护性

测试阶段使用 SQLite 内存数据库，避免污染真实数据库

CRUD 测试覆盖所有核心数据表

异常情况测试验证数据库完整性约束的有效性