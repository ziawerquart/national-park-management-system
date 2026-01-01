# 生物多样性模块 - DAO 与测试（biodiversity）

本目录提供 biodiversity 相关表的 **DAO（持久层 CRUD）** 与 **unittest 测试用例**，用于验证：
- 表结构可用（DDL 已执行）
- 种子数据已导入（DML 已执行）
- DAO 的核心 CRUD 与“待核实列表（to_verify）”查询可正常运行

---

## 📁 目录结构

`project/`
- `src/dao/biodiversity/`
  - `base_dao.py`
  - `habitat_dao.py`
  - `species_dao.py`
  - `habitat_primary_species_dao.py`
  - `monitoring_record_dao.py`
- `src/test/biodiversity/`
  - `common.py`
  - `test_habitat_dao.py`
  - `test_species_dao.py`
  - `test_habitat_primary_species_dao.py`
  - `test_monitoring_record_dao.py`

---

## ✅ 前置条件（必须满足）

1. MySQL 服务已启动
2. 已创建数据库并建表（已执行 DDL）
3. 已导入 biodiversity 种子数据（已执行 DML，建议使用“相对时间版 seed”）
4. Python 环境已安装依赖：
   - `pymysql`

---

## 🧪 如何运行测试（Windows / PowerShell）

### 方式 A：临时设置环境变量（推荐）
在项目根目录执行：

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_USER="root"
$env:DB_PASSWORD="你的密码"
$env:DB_NAME="national_park_db"

python -m unittest tests.biodiversity.test_habitat_dao -v
python -m unittest tests.biodiversity.test_species_dao -v
python -m unittest tests.biodiversity.test_habitat_primary_species_dao -v
python -m unittest tests.biodiversity.test_monitoring_record_dao -v

# 或者一次跑完 biodiversity 所有测试
python -m unittest tests.biodiversity -v
```

### 方式 B：CMD（临时环境变量）
```bat
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=你的密码
set DB_NAME=national_park_db

python -m unittest tests.biodiversity -v
```

---

## 📊 覆盖范围

- `HabitatDAO`
  - create / find_by_id / update / delete
- `SpeciesDAO`
  - create / find_by_id / update
- `HabitatPrimarySpeciesDAO`
  - create / find_by_pk / update / delete
- `MonitoringRecordDAO`
  - create / update(status) / find_pending_list_recent（贴合“待核实列表”用例）

---

## ⚠️ 注意事项

1. **测试会写入数据库**
   - 测试使用 `TST_` 前缀主键（如 `TST_HB001` / `TST_MR001`）
   - 每个用例结束会清理这些测试数据

2. **如果测试被 Skip**
   - 表示无法连接 MySQL
   - 请检查环境变量与 MySQL 账号密码是否正确

3. **外键相关**
   - 测试用例依赖 seed 里存在：
     - `R001`（Region）
     - `HB001`（Habitat）
     - `SP001`（Species）
     - `MD001`（MonitoringDevice）
     - `U001`（User）

---

## 🛠️ 常见报错排查

- `pymysql.err.OperationalError: ... Access denied`
  - 用户名/密码不对，或 MySQL 未允许远程/本地登录

- `pymysql.err.ProgrammingError: Table ... doesn't exist`
  - 你没有先执行 DDL（或执行的是另一个库）

- `Cannot add or update a child row: a foreign key constraint fails`
  - 你 seed 缺少依赖数据（Region/User/Device/Species/Habitat）

---
