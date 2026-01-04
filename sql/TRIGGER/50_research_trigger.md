# 科研支撑模块触发器说明

## tr_prevent_collection_on_completed - 已结题项目禁止新增采集记录

**适用范围：** 当项目状态为 `Completed` 时，自动阻止向该项目新增数据采集记录，保证已结题项目数据的完整性和一致性。

**触发时机：** BEFORE INSERT ON ResearchDataCollection

**业务规则：** 
- 检查关联项目的 project_status
- 如果为 Completed 则抛出错误，拒绝插入

**使用场景：**
- 防止误操作向已归档项目添加数据
- 保证结题项目的数据封存

---

## tr_result_auto_archive - 成果插入自动记录发布时间

**适用范围：** 当插入新的研究成果时，如果未指定发布时间，自动设置为当前时间，确保成果有明确的时间戳。

**触发时机：** BEFORE INSERT ON ResearchResult

**业务规则：**
- 检查 publish_time 是否为 NULL
- 如果为空则自动填充当前时间

**使用场景：**
- 成果快速录入（无需手动填写时间）
- 保证所有成果都有发布时间记录
