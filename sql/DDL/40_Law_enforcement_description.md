# 基于UML类图的关系模式转换与范式验证

## 一、关系模式转换（主码/外码标注）
根据UML类图的实体、属性及关联关系，转换为如下关系模式（`PK` 表示主码，`FK` 表示外码）：

### 1. LawDevice（执法设备表）
| 字段名         | 数据类型   | 约束说明          |
|----------------|------------|-------------------|
| device_id      | VARCHAR(32)| 主码（PK）        |
| device_status  | VARCHAR(20)| -                 |
| device_type    | VARCHAR(50)| -                 |
| device_model   | VARCHAR(50)| -                 |
| purchase_date  | DATE       | -                 |

### 2. LawEnforcementOfficer（执法人员表）
| 字段名         | 数据类型   | 约束说明                          |
|----------------|------------|-----------------------------------|
| law_id         | VARCHAR(32)| 主码（PK）                        |
| name           | VARCHAR(50)| -                                 |
| department     | VARCHAR(50)| -                                 |
| authority      | VARCHAR(50)| -                                 |
| contact        | VARCHAR(30)| -                                 |
| device_id      | VARCHAR(32)| 外码（FK），参考 LawDevice(device_id) |

### 3. VideoMonitorPoint（视频监控点表）
| 字段名         | 数据类型       | 约束说明                          |
|----------------|----------------|-----------------------------------|
| monitor_id     | VARCHAR(32)    | 主码（PK）                        |
| region_id      | VARCHAR(32)    | -                                 |
| latitude       | DECIMAL(10,6)  | -                                 |
| longitude      | DECIMAL(10,6)  | -                                 |
| monitor_range  | VARCHAR(100)   | -                                 |
| device_id      | VARCHAR(32)    | 外码（FK），参考 LawDevice(device_id) |
| storage_cycle  | INT            | -                                 |

### 4. IllegalBehaviorRecord（非法行为记录表）
| 字段名          | 数据类型   | 约束说明                                  |
|-----------------|------------|-------------------------------------------|
| record_id       | VARCHAR(32)| 主码（PK）                                |
| behavior_type   | VARCHAR(20)| -                                         |
| occur_time      | DATETIME   | -                                         |
| region_id       | VARCHAR(32)| -                                         |
| evidence_path   | VARCHAR(200)| -                                        |
| process_status  | VARCHAR(10)| -                                         |
| law_id          | VARCHAR(32)| 外码（FK），参考 LawEnforcementOfficer(law_id) |
| process_result  | VARCHAR(100)| -                                        |
| punishment_basis| VARCHAR(100)| -                                        |
| monitor_id      | VARCHAR(32)| 外码（FK），参考 VideoMonitorPoint(monitor_id) |

### 5. LawEnforcementDispatch（执法调度表）
| 字段名          | 数据类型   | 约束说明                                  |
|-----------------|------------|-------------------------------------------|
| dispatch_id     | VARCHAR(32)| 主码（PK）                                |
| record_id       | VARCHAR(32)| 外码（FK），参考 IllegalBehaviorRecord(record_id) |
| law_id          | VARCHAR(32)| 外码（FK），参考 LawEnforcementOfficer(law_id) |
| dispatch_time   | DATETIME   | -                                         |
| response_time   | DATETIME   | -                                         |
| finish_time     | DATETIME   | -                                         |
| dispatch_status | VARCHAR(10)| -                                         |

## 二、范式级别验证
所有关系模式均满足 **第三范式（3NF）**，验证过程如下：

### 1. 第一范式（1NF）验证
所有字段均为 **原子值**（不可再分），无复合字段（如未出现“地址-街道-门牌号”这类组合字段），符合第一范式的定义要求。

### 2. 第二范式（2NF）验证
- 所有关系模式的主码均为 **单属性主码**（如 `device_id`、`law_id`、`monitor_id` 等），不存在复合主码；
- 非主属性仅依赖于主码整体，不存在“部分函数依赖”（即非主属性不会只依赖主码的某一个子集）；
- 因此，所有关系模式自动满足第二范式。

### 3. 第三范式（3NF）验证
- 第三范式要求：非主属性既不部分依赖于主码，也不传递依赖于主码（无“主码→中间属性→非主属性”的依赖链）；
- 验证示例：
  1.  `LawEnforcementOfficer` 表中，`device_id` 直接依赖主码 `law_id`（执法人员绑定设备），无中间传递属性；
  2.  `IllegalBehaviorRecord` 表中，`law_id`、`monitor_id` 均直接关联主码 `record_id`（非法行为记录关联执法人员和监控点），无传递依赖；
  3.  其余表的非主属性均直接依赖对应主码，无传递依赖关系；
- 综上，所有关系模式均满足第三范式。

## 总结
本次转换得到的5张关系表均明确标注主码与外码，且全部满足第三范式（3NF），数据冗余低、一致性强，符合关系型数据库的设计规范。