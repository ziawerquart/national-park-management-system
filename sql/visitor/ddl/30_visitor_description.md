# 游客管理系统数据库关系模式分析与范式验证
## 文档说明
本文档针对`visitor_management_system`数据库的4张核心表，详细梳理其**关系模式**（含主码、外码标注），并逐一验证各关系模式的范式级别（1NF、2NF、3NF、BCNF），确保数据库设计符合关系型数据库规范化要求。

## 一、数据库概述
游客管理系统数据库用于存储景区游客基础信息、预约信息、轨迹信息及区域流量控制信息，包含4个核心关系模式：`Visitor`（游客信息）、`Reservation`（预约信息）、`VisitorTrajectory`（游客轨迹）、`FlowControl`（流量控制）。

## 二、各关系模式详细说明
### 2.1 Visitor（游客信息表）
#### 关系模式表示
```
Visitor(
    visitor_id, 
    visitor_name, 
    id_number, 
    contact_number, 
    entry_time, 
    exit_time, 
    entry_method
)
```
#### 字段说明与约束
| 字段名         | 数据类型    | 约束                | 角色          | 说明               |
|----------------|-------------|---------------------|---------------|--------------------|
| visitor_id     | VARCHAR(64) | NOT NULL、PK        | 主码（PK）    | 唯一标识游客       |
| visitor_name   | VARCHAR(128)| NULL                | 非主属性      | 游客姓名           |
| id_number      | VARCHAR(64) | UNIQUE、NULL        | 唯一键（UK）  | 身份证号（唯一）   |
| contact_number | VARCHAR(32) | NULL                | 非主属性      | 联系电话           |
| entry_time     | DATE        | NULL                | 非主属性      | 入园时间           |
| exit_time      | DATE        | NULL                | 非主属性      | 离园时间           |
| entry_method   | VARCHAR(32) | NULL                | 非主属性      | 入园方式（如闸机、人工） |

#### 关键标注
- 主码（PK）：`visitor_id`（单属性主码，唯一标识每条游客记录）；
- 唯一键（UK）：`id_number`（身份证号唯一，非主码）；
- 外码（FK）：无（该表为基础表，无外键依赖）。

### 2.2 FlowControl（流量控制表）
#### 关系模式表示
```
FlowControl(
    region_id, 
    daily_capacity, 
    current_visitor_count, 
    warning_threshold, 
    flow_status
)
```
#### 字段说明与约束
| 字段名                | 数据类型    | 约束         | 角色          | 说明               |
|-----------------------|-------------|--------------|---------------|--------------------|
| region_id             | VARCHAR(64) | NOT NULL、PK | 主码（PK）    | 唯一标识景区区域   |
| daily_capacity        | INT         | NULL         | 非主属性      | 区域日承载量       |
| current_visitor_count | INT         | NULL         | 非主属性      | 区域当前游客数     |
| warning_threshold     | INT         | NULL         | 非主属性      | 流量预警阈值       |
| flow_status           | VARCHAR(32) | NULL         | 非主属性      | 流量状态（如正常、预警） |

#### 关键标注
- 主码（PK）：`region_id`（单属性主码，唯一标识每个区域）；
- 外码（FK）：无（该表为基础表，无外键依赖）。

### 2.3 Reservation（预约信息表）
#### 关系模式表示
```
Reservation(
    reservation_id, 
    visitor_id, 
    reservation_date, 
    entry_time_slot, 
    group_size, 
    reservation_status, 
    ticket_amount, 
    payment_status
)
```
#### 字段说明与约束
| 字段名             | 数据类型     | 约束         | 角色          | 说明               |
|--------------------|--------------|--------------|---------------|--------------------|
| reservation_id     | VARCHAR(64)  | NOT NULL、PK | 主码（PK）    | 唯一标识预约记录   |
| visitor_id         | VARCHAR(64)  | NULL、FK     | 外码（FK）    | 关联Visitor(visitor_id) |
| reservation_date   | DATE         | NULL         | 非主属性      | 预约日期           |
| entry_time_slot    | VARCHAR(32)  | NULL         | 非主属性      | 入园时段（如上午9-10点） |
| group_size         | INT          | NULL         | 非主属性      | 同行人数           |
| reservation_status | VARCHAR(32)  | NULL         | 非主属性      | 预约状态（如待确认、已取消） |
| ticket_amount      | DECIMAL(10,2)| NULL         | 非主属性      | 门票总金额         |
| payment_status     | VARCHAR(32)  | NULL         | 非主属性      | 支付状态（如未支付、已支付） |

#### 关键标注
- 主码（PK）：`reservation_id`（单属性主码，唯一标识每条预约记录）；
- 外码（FK）：`visitor_id` → `Visitor(visitor_id)`（关联游客表，表示该预约所属游客）；
- 索引：`visitor_id`建普通索引（提升关联查询效率）。

### 2.4 VisitorTrajectory（游客轨迹表）
#### 关系模式表示
```
VisitorTrajectory(
    trajectory_id, 
    visitor_id, 
    location_time, 
    longitude, 
    latitude, 
    region_id, 
    is_out_of_route
)
```
#### 字段说明与约束
| 字段名         | 数据类型     | 约束         | 角色          | 说明               |
|----------------|--------------|--------------|---------------|--------------------|
| trajectory_id  | VARCHAR(64)  | NOT NULL、PK | 主码（PK）    | 唯一标识轨迹记录   |
| visitor_id     | VARCHAR(64)  | NULL、FK     | 外码（FK）    | 关联Visitor(visitor_id) |
| location_time  | DATETIME     | NULL         | 非主属性      | 定位时间           |
| longitude      | DECIMAL(10,6)| NULL         | 非主属性      | 经度（精确到6位小数） |
| latitude       | DECIMAL(10,6)| NULL         | 非主属性      | 纬度（精确到6位小数） |
| region_id      | VARCHAR(64)  | NULL、FK     | 外码（FK）    | 关联FlowControl(region_id) |
| is_out_of_route| BOOLEAN      | NULL         | 非主属性      | 是否偏离规划路线（True/False） |

#### 关键标注
- 主码（PK）：`trajectory_id`（单属性主码，唯一标识每条轨迹记录）；
- 外码（FK）：
  - `visitor_id` → `Visitor(visitor_id)`（关联游客表，表示该轨迹所属游客）；
  - `region_id` → `FlowControl(region_id)`（关联流量控制表，表示轨迹所属区域）；
- 索引：`visitor_id`、`region_id`建普通索引（提升关联查询效率）。

## 三、范式级别验证
### 3.1 范式基础定义（新手友好版）
- **1NF（第一范式）**：表中所有字段都是“原子性”的（不可再分），无重复字段/重复组，每行记录唯一。
- **2NF（第二范式）**：在1NF基础上，**非主属性完全函数依赖于主码**（无“部分依赖”）；若主码是单属性，则天然满足2NF（无部分依赖的可能）。
- **3NF（第三范式）**：在2NF基础上，**非主属性不传递函数依赖于主码**（非主属性之间无依赖关系，仅依赖主码）。
- **BCNF（巴斯-科德范式）**：在3NF基础上，**所有决定因素都是候选码**（无任何属性依赖于非候选码的字段），是3NF的强化版。

### 3.2 各关系模式范式验证
#### 3.2.1 Visitor表范式验证
1. **1NF验证**：所有字段（如visitor_name、id_number）均为原子类型（VARCHAR/DATE），无复合字段（如“姓名+电话”），无重复组，满足1NF。
2. **2NF验证**：主码为单属性`visitor_id`，所有非主属性（visitor_name、id_number等）都完全依赖于`visitor_id`（无部分依赖），满足2NF。
3. **3NF验证**：非主属性之间无传递依赖（如visitor_name不依赖id_number，contact_number不依赖entry_time），所有非主属性仅依赖主码`visitor_id`，满足3NF。
4. **BCNF验证**：唯一的决定因素是主码`visitor_id`（唯一键id_number虽为决定因素，但id_number是“候选码”<sup>注</sup>），满足BCNF。

<sup>注</sup>：id_number是唯一键，属于候选码（候选码是能唯一标识记录的字段/字段组），因此“id_number→visitor_id”的依赖也符合BCNF（决定因素是候选码）。

#### 3.2.2 FlowControl表范式验证
1. **1NF验证**：所有字段（daily_capacity、flow_status等）均为原子类型，无重复组，满足1NF。
2. **2NF验证**：主码为单属性`region_id`，非主属性（daily_capacity、current_visitor_count等）完全依赖于`region_id`，满足2NF。
3. **3NF验证**：非主属性之间无传递依赖（如current_visitor_count不依赖warning_threshold，flow_status不依赖daily_capacity），仅依赖主码`region_id`，满足3NF。
4. **BCNF验证**：所有决定因素只有主码`region_id`，无其他非候选码的决定因素，满足BCNF。

#### 3.2.3 Reservation表范式验证
1. **1NF验证**：所有字段（reservation_date、ticket_amount等）均为原子类型，无复合字段，满足1NF。
2. **2NF验证**：主码为单属性`reservation_id`，非主属性（visitor_id、group_size等）完全依赖于`reservation_id`，满足2NF。
3. **3NF验证**：非主属性之间无传递依赖（如ticket_amount不依赖payment_status，group_size不依赖reservation_status），仅依赖主码`reservation_id`；外码`visitor_id`是“关联字段”，并非“传递依赖”（传递依赖指非主属性→非主属性→主码），满足3NF。
4. **BCNF验证**：所有决定因素只有主码`reservation_id`，无其他非候选码的决定因素，满足BCNF。

#### 3.2.4 VisitorTrajectory表范式验证
1. **1NF验证**：所有字段（longitude、latitude、is_out_of_route等）均为原子类型（DECIMAL/BOOLEAN），无复合字段，满足1NF。
2. **2NF验证**：主码为单属性`trajectory_id`，非主属性（visitor_id、location_time等）完全依赖于`trajectory_id`，满足2NF。
3. **3NF验证**：非主属性之间无传递依赖（如longitude不依赖region_id，is_out_of_route不依赖visitor_id），仅依赖主码`trajectory_id`；外码`visitor_id`/`region_id`是关联字段，非传递依赖，满足3NF。
4. **BCNF验证**：所有决定因素只有主码`trajectory_id`，无其他非候选码的决定因素，满足BCNF。

### 3.3 整体范式结论
| 关系模式          | 1NF | 2NF | 3NF | BCNF |
|-------------------|-----|-----|-----|------|
| Visitor           | ✅   | ✅   | ✅   | ✅    |
| FlowControl       | ✅   | ✅   | ✅   | ✅    |
| Reservation       | ✅   | ✅   | ✅   | ✅    |
| VisitorTrajectory | ✅   | ✅   | ✅   | ✅    |

所有关系模式均满足**BCNF**（范式的最高级别之一），数据库设计无冗余、无异常（插入/更新/删除异常），符合工业级数据库规范化要求。

## 四、总结
1. **关系模式设计**：4张表的主码均为单属性（visitor_id/reservation_id等），外码关联合理（如VisitorTrajectory关联Visitor和FlowControl），保证了数据的完整性和一致性；
2. **范式合规性**：所有表均满足BCNF，消除了数据冗余和操作异常，便于后续数据维护（如更新游客信息、调整区域流量阈值）；
