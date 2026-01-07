## 触发器：trg_envdata_fill_time

**业务线**：生态环境监测（Environmental Monitoring）

**触发时机**：BEFORE INSERT ON EnvironmentalData

**功能说明**：
- 当插入新环境监测数据时，如果 `collect_time` 字段为空，则自动填充当前时间
- 仅修改即将插入的行的字段

**适用场景**：
- 确保每条环境监测数据都有时间戳
- 避免因漏填 collect_time 导致查询或统计异常
- 与存储过程配合使用，实现异常判定和告警生成
