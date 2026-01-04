# 科研支撑模块 DAO

数据访问对象层，封装 `ResearchProject` 和 `ResearchDataRecord` 表的 CRUD 操作。

## 文件结构

```
src/dao/research/
├── __init__.py
├── base_dao.py                 # 基础DAO类
├── research_project_dao.py     # 研究项目DAO
└── research_data_record_dao.py # 数据采集记录DAO
```

## 快速开始

```python
from dao.research import ResearchProjectDAO, ResearchDataRecordDAO

config = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'your_password',
    'database': 'national_park_db'
}

project_dao = ResearchProjectDAO(config)
record_dao = ResearchDataRecordDAO(config)
```

## API 说明

### ResearchProjectDAO

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `create(data)` | dict | str (project_id) | 创建项目 |
| `find_by_id(id)` | str | dict \| None | 按ID查询 |
| `find_all(limit, offset)` | int, int | list[dict] | 分页查询 |
| `find_by_status(status)` | str | list[dict] | 按状态查询 |
| `find_by_leader(leader_id)` | str | list[dict] | 按负责人查询 |
| `update(id, data)` | str, dict | int (affected rows) | 更新项目 |
| `delete(id)` | str | int | 删除项目 |
| `count_by_status()` | - | list[dict] | 按状态统计 |
| `exists(id)` | str | bool | 判断是否存在 |

**create 必填字段：** `project_id`, `project_name`, `leader_id`, `approval_date`, `project_status`

**project_status 枚举值：** `ongoing`, `completed`, `paused`

### ResearchDataRecordDAO

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `create(data)` | dict | str (collection_id) | 创建记录 |
| `find_by_id(id)` | str | dict \| None | 按ID查询 |
| `find_all(limit, offset)` | int, int | list[dict] | 分页查询 |
| `find_by_project(project_id)` | str | list[dict] | 按项目查询 |
| `find_by_collector(collector_id)` | str | list[dict] | 按采集员查询 |
| `find_by_region(region_id)` | str | list[dict] | 按区域查询 |
| `find_by_time_range(start, end)` | datetime, datetime | list[dict] | 按时间范围查询 |
| `update(id, data)` | str, dict | int | 更新记录 |
| `delete(id)` | str | int | 删除记录 |
| `count_by_source()` | - | list[dict] | 按数据来源统计 |
| `exists(id)` | str | bool | 判断是否存在 |

**create 必填字段：** `collection_id`, `project_id`, `collector_id`, `collection_time`, `region_id`, `data_source`

**data_source 枚举值：** `field`, `system`

## 使用示例

```python
# 创建项目
project_dao.create({
    'project_id': 'P001',
    'project_name': '大熊猫保护研究',
    'leader_id': 'U001',
    'approval_date': '2024-01-01',
    'project_status': 'ongoing',
    'research_field': '生态学'
})

# 查询进行中的项目
ongoing = project_dao.find_by_status('ongoing')

# 创建数据记录
record_dao.create({
    'collection_id': 'C001',
    'project_id': 'P001',
    'collector_id': 'U002',
    'collection_time': '2024-06-01 10:00:00',
    'region_id': 'R001',
    'data_source': 'field',
    'collection_content': '野外调查数据'
})

# 更新审核状态
record_dao.update('C001', {
    'is_verified': True,
    'verified_by': 'U001',
    'verified_at': '2024-06-02 10:00:00'
})
```

## 依赖

```
pymysql>=1.0.0
```