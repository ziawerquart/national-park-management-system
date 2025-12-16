# 提交与命名规范
> 国家公园智慧管理系统  
> 数据库系统课程设计 · 团队协作与工程规范

---
## 1. 目的说明

为保证 **国家公园管理系统数据库课程设计** 项目在开发、设计与文档编写过程中的一致性、可维护性与可追溯性，特制定本协作规范文档。

本规范适用于本仓库内 **所有成员**，包括但不CONTRIBUTING.md限于：

- SQL 设计与实现
    
- Python 持久层代码
    
- UML / 用例图 / 鲁棒图
    
- 项目文档与报告
    

---

## 2. Git 提交（push / commit）命名规范

### 2.1 基本格式（必须遵守）

```text
<type>: <简要说明>
```

### 2.2 type 类型说明

| type     | 使用场景                            |
| -------- | ------------------------------- |
| feat     | 新功能 / 新业务（表、SQL、功能代码等）          |
| fix      | Bug 修复                          |
| sql      | 新增或修改 SQL（DDL / 查询 / 视图 / 触发器等） |
| docs     | 文档新增或修改                         |
| refactor | 重构（不改变功能，仅优化结构）                 |
| test     | 测试数据 / 测试代码                     |
| chore    | 杂项（目录调整、格式修改等）                  |

### 2.3 示例（✅ 推荐）

```text
feat: add biodiversity monitoring tables
sql: add ddl for species and habitat tables
docs: add biodiversity data dictionary
fix: correct foreign key constraint in monitoring_record
refactor: optimize sql query for habitat statistics
```

### 2.4 禁止行为（❌）

```text
update
fix bug
提交
改了一点东西
```

---

## 3. 分支使用规范（极简版）

### 3.1 总原则（所有成员必须遵守）
- main 分支：稳定版本，只合并成果（不直接开发，不 force push）
- 一件事一个分支：一个分支只做一个目标（例如：一张图 / 一组DDL / 一组SQL / 一个功能）
- 分支名全部使用英文小写 + 连字符（kebab-case），禁止中文、空格、下划线

---

### 3.2 分支命名统一格式（推荐）
< type>/< scope>-< short-desc>

- type：变更类型（下面给出固定取值）
- scope：业务线/模块范围（建议使用业务前缀）
- short-desc：本次工作内容的简短描述（2-5 个单词）

---

### 3.3 type 取值（固定选项）
- docs        文档/图（用例图、鲁棒图、UML、报告、规范）
- sql         SQL 相关（DDL / queries / views / triggers / procedures）
- feat        Python 代码/功能新增（src/main）
- test        测试代码/测试数据（src/test 或测试数据脚本）
- chore       工程杂项（目录调整、CI、模板、配置、格式化等）
- fix         修复（SQL 或代码的错误修复）

---

### 3.4 scope 取值（与业务线前缀一致）
- biodiversity
- environment
- visitor
- law-enforcement
- research
- global（跨业务线/全局规则/公共脚本）

---

### 3.5 示例（✅ 推荐照抄）
#### 文档 / 图
- docs/biodiversity-use-case
- docs/biodiversity-robustness
- docs/global-contributing-update

#### SQL（DDL / 查询 / 视图 / 触发器 / 存储过程）
- sql/biodiversity-ddl-species-habitat
- sql/visitor-queries-flow-statistics
- sql/environment-views-threshold-warning
- sql/law-enforcement-triggers-dispatch
- sql/research-procedures-permission-control

#### Python 功能 / 持久层
- feat/biodiversity-dao-crud
- feat/visitor-service-reservation

#### 修复
- fix/sql-foreign-key-error
- fix/visitor-query-time-filter

#### 工程杂项
- chore/global-restructure-folders
- chore/global-update-issue-templates

---

### 3.6 禁止分支名（❌）
- test / tmp / new / aaa
- ziawerquart/xxx（不要用个人名做前缀）
- feature_xxx（不要下划线）
        
### 3.7 何时必须创建分支（重要）

为避免协作混乱、降低返工成本，项目约定在以下情况 **必须创建新分支，并通过 Pull Request 合并到 main 分支**：

#### 必须开分支的情况
- **修改项目规则或协作规范**  
  例如：`CONTRIBUTING.md`、命名规范、协作流程说明等。
- **调整项目目录结构**  
  包括新增、删除或大规模移动目录 / 文件。
- **数据库相关变更**  
  涉及 `sql/` 目录下的 DDL、复杂查询、视图、触发器、存储过程等。
- **公共代码或公共配置修改**  
  会影响其他成员使用的 Python 代码、公共脚本、环境配置等。
- **一次性改动内容较多**  
  单次工作涉及多个文件或多个模块，影响范围不清晰时。

#### 可以直接提交到 main 的情况
- 新增会议记录、进度记录等过程性文档。
- 补充已经约定好的设计图、截图、说明性材料，且不涉及规则变更。
- 小幅度文字修正（如错别字、格式微调）。

> **快速记忆规则**  
> **改规则 / 改结构 / 改数据库 / 改公共内容 → 必须开分支 + PR**  
> **只加材料 / 会议记录 / 小改文案 → 可直接提交 main**

---

## 4. 文件与目录命名规范

### 4.1 通用原则（所有文件）

- **统一使用英文小写 + 下划线**
    
- 禁止使用中文、空格、特殊符号
    
- 文件名应体现 **业务含义 + 内容类型**
    

✅ 推荐：

```text
biodiversity_monitoring.sql
habitat_analysis_view.sql
visitor_flow_statistics.sql
```

❌ 禁止：

```text
生物多样性.sql
SQL1.sql
new file.sql
```

---

### 4.2 SQL 文件命名规范（`/sql`）

#### 1️⃣ DDL（建表）

```text
sql/ddl/<业务>_<对象>_table.sql
```

示例：

```text
sql/ddl/species_table.sql
sql/ddl/habitat_table.sql
sql/ddl/monitoring_record_table.sql
```

#### 2️⃣ 查询语句

```text
sql/queries/<业务>_<查询含义>.sql
```

示例：

```text
sql/queries/biodiversity_recent_30days_statistics.sql
sql/queries/habitat_suitability_analysis.sql
```

#### 3️⃣ 视图 / 触发器 / 存储过程

```text
sql/views/<业务>_<view_name>.sql
sql/triggers/<业务>_<trigger_name>.sql
sql/stored_procedures/<业务>_<procedure_name>.sql
```

---

### 4.3 Python 文件命名规范（`/src`）

- 文件名：`snake_case`
    
- 类名：`CamelCase`
    
- 函数名：`snake_case`
    

示例：

```text
biodiversity_dao.py
visitor_flow_service.py
```

---

### 4.4 UML / 用例图 / 鲁棒图命名规范（`/docs`）

#### UML 类图

```text
docs/UML/<业务>_uml_class_diagram.png
```

示例：

```text
biodiversity_uml_class_diagram.png
```

#### 用例图

```text
docs/use_case_diagram/<业务>_use_case.png
```

#### 鲁棒图

```text
docs/robustness_diagram/<业务>_robustness.png
```

---

### 4.5 数据字典命名规范（`/docs/data_dictionary`）

```text
<业务>_data_dictionary.xlsx
```

示例：

```text
biodiversity_data_dictionary.xlsx
visitor_management_data_dictionary.xlsx
```

---

## 5. 文档（Markdown / 报告）命名规范

- Markdown：`snake_case.md`
    
- 报告 / PPT：体现用途与版本
    

示例：

```text
project_progress.md
meeting_record_2025_03_15.md
group_report_v1.0.docx
```

---

## 6. 提交前自检清单（强烈建议）

在 push 前，请确认：

-  commit message 符合规范
    
-  文件命名符合规范
    
-  SQL 可正常执行
    
-  未提交无关文件（临时文件、个人配置）
    

---

---

📌 **说明**：  
本文档是课程设计工程管理的重要组成部分，可作为

- 小组报告「工程管理」依据
    
- 个人报告「GitHub 使用与项目管理」依据
    



# 📌 附录：按业务线细化的文件命名规范（A–E）

> 本项目包含 5 条核心业务线。  
> 为便于协作、检查与答辩说明，**所有核心产出文件必须在文件名中体现业务线归属**。

---

## A — 生物多样性监测业务线（组长 A）

**关键词前缀统一：`biodiversity`**

### 1️⃣ SQL（A 负责）

#### 表结构（DDL）

```text
sql/ddl/biodiversity_species_table.sql
sql/ddl/biodiversity_habitat_table.sql
sql/ddl/biodiversity_monitoring_record_table.sql
```

#### 查询 SQL

```text
sql/queries/biodiversity_recent_30days_statistics.sql
sql/queries/biodiversity_species_distribution.sql
```

#### 视图 / 触发器 / 存储过程

```text
sql/views/biodiversity_species_level_view.sql
sql/triggers/biodiversity_monitoring_status_trigger.sql
sql/stored_procedures/biodiversity_data_review_procedure.sql
```

---

### 2️⃣ UML / 图类文档

```text
docs/UML/biodiversity_uml_class_diagram.png
docs/use_case_diagram/biodiversity_use_case.png
docs/robustness_diagram/biodiversity_robustness.png
```

---

### 3️⃣ 数据字典

```text
docs/data_dictionary/biodiversity_data_dictionary.xlsx
```

---

## B — 生态环境监测业务线（组员 B）

**关键词前缀统一：`environment`**

```text
sql/ddl/environment_monitoring_device_table.sql
sql/ddl/environment_monitoring_data_table.sql

sql/queries/environment_abnormal_data_statistics.sql
sql/views/environment_threshold_warning_view.sql
sql/triggers/environment_device_fault_trigger.sql

docs/UML/environment_uml_class_diagram.png
docs/data_dictionary/environment_data_dictionary.xlsx
```

---

## C — 游客智能管理业务线（组员 C）

**关键词前缀统一：`visitor`**

```text
sql/ddl/visitor_info_table.sql
sql/ddl/visitor_reservation_table.sql
sql/ddl/visitor_trajectory_table.sql

sql/queries/visitor_flow_statistics.sql
sql/views/visitor_realtime_flow_view.sql
sql/triggers/visitor_overflow_trigger.sql

docs/UML/visitor_uml_class_diagram.png
docs/data_dictionary/visitor_data_dictionary.xlsx
```

---

## D — 执法监管业务线（组员 D）

**关键词前缀统一：`law_enforcement`**

```text
sql/ddl/law_enforcement_officer_table.sql
sql/ddl/law_enforcement_illegal_record_table.sql
sql/ddl/law_enforcement_dispatch_table.sql

sql/queries/law_enforcement_case_efficiency.sql
sql/views/law_enforcement_case_status_view.sql
sql/triggers/law_enforcement_dispatch_trigger.sql

docs/UML/law_enforcement_uml_class_diagram.png
docs/data_dictionary/law_enforcement_data_dictionary.xlsx
```

---

## E — 科研数据支撑业务线（组员 E）

**关键词前缀统一：`research`**

```text
sql/ddl/research_project_table.sql
sql/ddl/research_data_collection_table.sql
sql/ddl/research_result_table.sql

sql/queries/research_project_progress.sql
sql/views/research_result_access_view.sql
sql/stored_procedures/research_permission_control_procedure.sql

docs/UML/research_uml_class_diagram.png
docs/data_dictionary/research_data_dictionary.xlsx
```

---

## 统一规则总结

> - 每条业务线使用**唯一英文前缀**
>     
> - 文件名即可直接反映：
>     
>     - 业务线
>         
>     - 文件类型（table / view / trigger / query）
>         
> - 任何人都可以通过文件名快速定位责任人和业务范围
>     
> - 方便代码检查、答辩说明和个人贡献说明
>     

---
