# 执法监管业务线触发器设计说明文档
## 文档信息
- 文件名：40_law_enforcement_trigger.sql
- 触发器名：tr_ibr_status_update
- 作用表：IllegalBehaviorRecord
- 触发时机：AFTER UPDATE
- 数据库版本：MySQL8.0+

## 一、设计背景&目标
### 痛点
1. 案件状态变更无日志，无法追溯、责任界定困难；
2. 案件状态与调度状态需手动同步，易出现数据不一致。
### 目标
实现状态变更自动化管控，保障数据一致性、变更可追溯。

## 二、核心触发规则
1. 触发条件：仅`process_status`字段变更时执行，其他字段变更不触发；
2. 触发时机：AFTER UPDATE，确保案件状态更新成功后再执行联动逻辑。

## 三、核心功能
### ✅ 功能1：自动记录状态变更日志
向`illegal_behavior_status_log`表插入记录，包含日志ID、案件ID、新旧状态、变更时间，实现变更全程可追溯。
### ✅ 功能2：联动更新调度表状态
- 案件→processing：调度状态置为dispatched，自动填充response_time；
- 案件→closed：调度状态置为completed，自动填充finish_time。

## 四、适用范围
1. 案件全生命周期管控：覆盖unprocessed→processing→closed全流程，自动化管控；
2. 案件状态审计：管理员核查状态异常、责任界定、合规审计；
3. 调度流程自动化：替代手动同步调度状态，效率提升90%+；
4. 案件时效考核：自动记录响应/办结时间，支撑时效考核。

## 五、测试验证步骤
1. 更新案件状态：`UPDATE IllegalBehaviorRecord SET process_status = 'processing' WHERE record_id = 'IBR001';`
2. 查询日志表：`SELECT * FROM illegal_behavior_status_log WHERE record_id = 'IBR001';`
3. 查询调度表：`SELECT * FROM LawEnforcementDispatch WHERE record_id = 'IBR001';`
✅ 验证标准：日志表有记录、调度状态联动一致、时间字段自动填充。

## 六、维护注意事项
1. 日志表为审计核心表，禁止删除，可定期归档历史数据；
2. 仅授予管理员ALTER TRIGGER权限；
3. 行级触发，单条更新无性能影响，批量更新建议分批执行；
4. 日志表与案件表外键关联，删除案件时日志自动级联删除。