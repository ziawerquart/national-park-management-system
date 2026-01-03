# 10_biodiversity_proc.md（Stage4｜存储过程 适用范围说明）

## sp_submit_monitoring_record（提交监测记录：多步 SQL 自动化）
- 解决什么业务问题：把“参数校验 → 外键存在性检查 → 生成 record_id → 插入 MonitoringRecord 并强制状态为 to_verify”封装成一次调用，避免应用端漏填字段或绕过工作流。
- 适用范围/什么时候用：生态监测员/设备接入服务在写入新监测数据时使用；需要确保插入记录必然从 `status='to_verify'` 开始，进入后续核验流程。
- 注意事项/限制条件：过程会对 `Species / MonitoringDevice / User` 做存在性检查，不满足会抛错；`record_id` 由 UUID 生成（去掉短横线），如你们有统一编号规则可替换生成逻辑。
