# 10_biodiversity_trigger.md（Stage4｜触发器 适用范围说明）

## trg_mr_before_insert（MonitoringRecord：插入前自动维护业务逻辑）
- 解决什么业务问题：保证所有新监测记录进入统一工作流（默认 `status='to_verify'`），并在入库时拦截明显异常的空间数据（经纬度越界）/缺失时间字段。
- 适用范围/什么时候用：任何来源（人工录入、设备上报、批量导入）向 `MonitoringRecord` 插入新记录时自动生效，防止应用层绕过校验导致脏数据进入分析与统计。
- 注意事项/限制条件：触发器只在 INSERT 时校验；若后续允许 UPDATE 修改经纬度/时间，建议另补一个 BEFORE UPDATE 触发器；同时触发器报错会导致整条 INSERT 失败，需要应用端捕获错误信息。
