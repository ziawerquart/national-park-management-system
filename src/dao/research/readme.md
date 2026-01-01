
# 生物多样性模块（Biodiversity）— DAO 与单元测试说明

本目录提供 **biodiversity 模块**相关表的 **DAO（数据访问层 / 持久层）** 及其 **unittest 单元测试**，用于验证：

* 数据库表结构（DDL）正确
* 生物多样性模块种子数据（DML）可用
* DAO 的核心 CRUD 与业务查询逻辑可正常运行
* **仅覆盖 biodiversity 模块，不包含 research 等其他模块**

---

## 📁 项目目录结构

```
project/
├─ src/
│  ├─ dao/
│  │  └─ biodiversity/
│  │     ├─ base_dao.py
│  │     ├─ habitat_dao.py
│  │     ├─ species_dao.py
│  │     ├─ habitat_primary_species_dao.py
│  │     └─ monitoring_record_dao.py
│  └─ test/
│     └─ biodiversity/
│        ├─ common.py
│        ├─ test_habitat_dao.py
│        ├─ test_species_dao.py
│        ├─ test_habitat_primary_species_dao.py
│        └─ test_monitoring_record_dao.py
```

---

## ✅ 前置条件（必须全部满足）

1. **MySQL 服务已启动**
2. **已创建数据库并执行 DDL**

   * 例如：`99_all_in_one.sql`
3. **已导入 biodiversity 种子数据（DML）**

   * 推荐使用 *相对时间版 seed*（如 `10_biodiversity_seed_relative_time.sql`）
4. **Python 环境已安装依赖**

   ```bash
   pip install pymysql
   ```

---

## 🔧 数据库连接配置（PowerShell）

在 **项目根目录** 执行（仅当前终端会话生效）：

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_USER="root"
$env:DB_PASSWORD="你的MySQL密码"
$env:DB_NAME="national_park_db"
```

> ⚠️ 注意
>
> * `DB_PASSWORD` 必须是真实密码
> * 测试使用的是 **root@localhost**

---

## 🧪 如何运行 biodiversity 模块的测试（推荐方式）

### ✅ 方式一：逐个模块运行（最清晰、最稳定）

```powershell
python -m unittest -v src.test.biodiversity.test_species_dao
python -m unittest -v src.test.biodiversity.test_habitat_dao
python -m unittest -v src.test.biodiversity.test_monitoring_record_dao
python -m unittest -v src.test.biodiversity.test_habitat_primary_species_dao
```

这是**最推荐**的方式，与你最终成功运行的命令完全一致。

---

### ✅ 方式二：一次性跑 biodiversity 全部测试

```powershell
python -m unittest discover -s src/test -t src -p "test_*.py" -v
```

说明：

* `-t src`：告诉 unittest **顶层包是 `src`**
* `-s src/test`：从 `src.test` 开始发现测试
* 该命令会同时发现 `biodiversity` 和其他模块
  👉 **只要 biodiversity 全部 OK，就视为本模块通过**

---

## ✅ 实际通过的测试结果（示例）

```text
test_species_dao ................ OK
test_habitat_dao ................ OK
test_monitoring_record_dao ...... OK
test_habitat_primary_species_dao  OK
```

这表示：

* biodiversity 模块的 **所有 DAO 均已通过单元测试**
* DAO 实现、SQL、事务、连接方式均正常

---

## 📊 DAO 覆盖范围说明

### `SpeciesDAO`

* create
* find_by_id
* update

### `HabitatDAO`

* create
* find_by_id
* update
* delete

### `HabitatPrimarySpeciesDAO`（N:M 中间表）

* create
* find_by_pk
* update
* delete

### `MonitoringRecordDAO`（生物多样性模块）

* create
* update_status
* find_pending_list_recent
  👉 对应「**待核实（to_verify）监测记录列表**」业务用例

---

## ⚠️ 注意事项（很重要）

1. **测试会真实写入数据库**

   * 测试数据统一使用 `TST_` 前缀主键
   * 每个测试用例结束后会自动清理

2. **只保证 biodiversity 模块**

3. **外键依赖说明**

   * seed 中需至少包含以下基础数据：

     * Region
     * Habitat
     * Species
     * User（ecological_monitor）
     * MonitoringDevice（如存在）

---

## 🛠️ 常见错误与排查

### ❌ `attempted relative import with no known parent package`

* 原因：未使用 `-t src`，或直接在子目录 discover
* 解决：**始终从项目根目录运行 unittest**

### ❌ `Access denied for user 'root'@'localhost'`

* 原因：数据库密码错误 / MySQL 未启动
* 解决：重新设置 `DB_PASSWORD`

### ❌ `Table doesn't exist`

* 原因：DDL 未执行或执行到错误的数据库
* 解决：确认 `USE national_park_db;`

---

## ✅ 总结

> 生物多样性（biodiversity）模块已完成 DAO 层实现，
> 覆盖 Species、Habitat、MonitoringRecord 及其关联表，
> 并通过 unittest 单元测试验证，测试结果均为 **OK**。
