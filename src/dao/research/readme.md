# 科研支撑模块 - Python DAO 层

## 📁 目录结构

```
project/
├── src/
│   └── dao/
│       └── research/
│           ├── __init__.py                   # 包初始化
│           ├── base_dao.py                   # 基础DAO类
│           ├── research_project_dao.py        # 研究项目DAO
│           └── monitoring_record_dao.py       # 监测记录DAO
└── tests/
    └── research/
        ├── __init__.py
        ├── test_research_project_dao.py       # 研究项目测试
        └── test_monitoring_record_dao.py      # 监测记录测试
```

## 🎯 功能说明

### 1. ResearchProjectDAO (研究项目DAO)

**支持的操作**:
- ✅ `create()` - 创建新项目
- ✅ `find_by_id()` - 根据ID查询
- ✅ `find_all()` - 查询所有项目（支持分页）
- ✅ `find_by_status()` - 根据状态查询
- ✅ `find_by_investigator()` - 根据研究员查询
- ✅ `update()` - 更新项目信息
- ✅ `delete()` - 删除项目
- ✅ `count_by_status()` - 统计各状态项目数
- ✅ `exists()` - 检查项目是否存在

### 2. MonitoringRecordDAO (监测记录DAO)

**支持的操作**:
- ✅ `create()` - 创建新记录
- ✅ `find_by_id()` - 根据ID查询
- ✅ `find_all()` - 查询所有记录（支持分页）
- ✅ `find_by_species()` - 根据物种查询
- ✅ `find_by_habitat()` - 根据栖息地查询
- ✅ `find_by_collection()` - 根据数据采集查询
- ✅ `find_by_data_type()` - 根据数据类型查询
- ✅ `find_by_time_range()` - 根据时间范围查询
- ✅ `update()` - 更新记录信息
- ✅ `delete()` - 删除记录
- ✅ `count_by_data_type()` - 统计各类型记录数
- ✅ `count_by_species()` - 统计各物种记录数
- ✅ `exists()` - 检查记录是否存在

## 🚀 使用示例

### 安装依赖

```bash
pip install pymysql
```

### 基本使用

```python
from src.dao.research import ResearchProjectDAO, MonitoringRecordDAO
from datetime import date

# 配置数据库连接
config = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'your_password',
    'database': 'wildlife_conservation'
}

# 创建DAO实例
project_dao = ResearchProjectDAO(config)

# 创建项目
project_data = {
    'project_id': 'PRJ_NEW_001',
    'project_name': 'Giant Panda Conservation Project',
    'principal_investigator_id': 'U001',
    'project_status': 'InProgress',
    'start_time': date(2024, 1, 1),
    'end_time': date(2026, 12, 31),
    'research_field': 'Conservation Biology'
}
project_dao.create(project_data)

# 查询项目
project = project_dao.find_by_id('PRJ_NEW_001')
print(f"Project: {project['project_name']}")

# 更新项目
project_dao.update('PRJ_NEW_001', {
    'project_status': 'Completed'
})

# 查询进行中的所有项目
ongoing_projects = project_dao.find_by_status('InProgress')
print(f"Found {len(ongoing_projects)} ongoing projects")
```

### 监测记录示例

```python
from datetime import datetime

# 创建监测记录DAO
record_dao = MonitoringRecordDAO(config)

# 创建监测记录
record_data = {
    'record_id': 'MR_NEW_001',
    'monitor_time': datetime.now(),
    'data_type': 'Population Count',
    'data_value': '15 individuals observed',
    'habitat_id': 'HB001',
    'species_id': 'SP001',
    'collection_id': 'DC001'
}
record_dao.create(record_data)

# 查询某个物种的所有监测记录
species_records = record_dao.find_by_species('SP001')
print(f"Found {len(species_records)} records for species SP001")

# 查询时间范围内的记录
from datetime import timedelta
start = datetime.now() - timedelta(days=30)
end = datetime.now()
recent_records = record_dao.find_by_time_range(start, end)
print(f"Found {len(recent_records)} records in the last 30 days")
```

## 🧪 运行测试

### 前提条件

1. 确保MySQL服务正在运行
2. 数据库 `wildlife_conservation` 已创建
3. 已执行DDL创建表结构
4. 已执行seed文件插入测试数据
5. 修改测试文件中的数据库密码

### 运行所有测试

```bash
# 进入项目根目录
cd /Users/evenyoung/national-park-management-system

# 运行ResearchProject测试
python -m pytest tests/research/test_research_project_dao.py -v

# 运行MonitoringRecord测试
python -m pytest tests/research/test_monitoring_record_dao.py -v

# 或使用unittest
python tests/research/test_research_project_dao.py
python tests/research/test_monitoring_record_dao.py
```

### 运行特定测试

```bash
# 运行特定测试类
python -m pytest tests/research/test_research_project_dao.py::TestResearchProjectDAO -v

# 运行特定测试方法
python -m pytest tests/research/test_research_project_dao.py::TestResearchProjectDAO::test_create_project_success -v
```

## 📊 测试覆盖范围

### ResearchProjectDAO 测试

**正常场景** (9个测试):
- ✅ 成功创建项目
- ✅ 根据ID查询项目
- ✅ 查询不存在的项目
- ✅ 根据状态查询
- ✅ 根据研究员查询
- ✅ 成功更新项目
- ✅ 更新不存在的项目
- ✅ 成功删除项目
- ✅ 统计各状态项目数

**异常场景** (6个测试):
- ✅ 缺少必填字段
- ✅ 使用无效的项目状态
- ✅ 创建重复的项目ID
- ✅ 使用不存在的研究员ID
- ✅ 更新为无效状态
- ✅ 更新时没有有效字段

**总计**: 15个测试用例

### MonitoringRecordDAO 测试

**正常场景** (13个测试):
- ✅ 成功创建监测记录
- ✅ 只用必填字段创建
- ✅ 根据ID查询记录
- ✅ 查询不存在的记录
- ✅ 根据物种查询
- ✅ 根据栖息地查询
- ✅ 根据数据采集查询
- ✅ 根据数据类型查询
- ✅ 根据时间范围查询
- ✅ 成功更新记录
- ✅ 更新不存在的记录
- ✅ 成功删除记录
- ✅ 统计功能测试

**异常场景** (5个测试):
- ✅ 缺少必填字段
- ✅ 创建重复的记录ID
- ✅ 使用不存在的物种ID
- ✅ 使用不存在的数据采集ID
- ✅ 更新时没有有效字段

**总计**: 18个测试用例

**全部测试用例总数**: 33个

## ⚠️ 注意事项

1. **数据库配置**: 修改测试文件中的数据库密码为你的实际密码
2. **外键约束**: 创建记录时确保外键引用的记录存在
3. **枚举值**: 项目状态只能是 `InProgress`, `Completed`, `Suspended`
4. **测试隔离**: 每个测试方法会自动清理测试数据
5. **并发安全**: 当前实现不支持并发控制，生产环境需要添加

## 🛠️ 故障排查

### 常见错误

1. **连接失败**
```
pymysql.err.OperationalError: (2003, "Can't connect to MySQL server")
```
**解决**: 检查MySQL是否运行，配置是否正确

2. **外键约束错误**
```
pymysql.err.IntegrityError: (1452, 'Cannot add or update a child row')
```
**解决**: 确保引用的user_id, species_id等在数据库中存在

3. **表不存在**
```
pymysql.err.ProgrammingError: (1146, "Table 'wildlife_conservation.ResearchProject' doesn't exist")
```
**解决**: 
- 检查表名大小写（macOS区分大小写）
- 确保已执行DDL创建表

4. **测试失败**
```
AssertionError: 0 != 1
```
**解决**: 检查测试前提条件，确保数据库中存在必要的外键记录

## 📈 后续优化建议

1. **连接池**: 使用连接池代替每次创建新连接
2. **事务管理**: 添加显式事务控制
3. **批量操作**: 实现批量插入/更新方法
4. **缓存**: 添加查询结果缓存
5. **日志**: 添加操作日志记录
6. **异步支持**: 使用 asyncio + aiomysql

---

**创建日期**: 2024-12-30  
**作者**: Even  
**版本**: 1.0.0