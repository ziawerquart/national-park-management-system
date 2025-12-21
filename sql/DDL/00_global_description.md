# 数据库关系模式与范式分析

## 一、关系模式设计（Relation Schema）

### 1. Region（区域信息表）

用于描述系统中各区域的基础信息。

关系模式：
Region(region_id(PK) ,  region_name,region_type)

### 2. User（用户信息表）

用于存储系统用户的基本信息及其角色信息。

关系模式：
User( user_id(PK) , user_name, role )

### 3. MonitoringDevice（监测设备表）

用于描述部署在各区域内的监测设备信息。

关系模式：
MonitoringDevice(device_id(PK) , device_type , install_time , calibration_cycle , run_status , communication_protocol , region_id(FK) )

### 4. 实体关系说明

- Region 与 MonitoringDevice 之间为一对多（1:N）关系

---

## 二、主码与外码设计

### Region

主码：
- region_id

外码：
- 无

### User

主码：
- user_id

外码：
- 无

### MonitoringDevice

主码：
- device_id

外码：
- region_id → Region(region_id)

---

## 三、范式级别验证

### 第一范式（1NF）

说明：
- 所有字段均为原子属性
- 不存在重复组或多值属性

结论：
Region、User、MonitoringDevice 均满足第一范式（1NF）

---

### 第二范式（2NF）

说明：
- 已满足第一范式
- 各关系模式均使用单属性主码
- 非主属性完全依赖于主码

结论：
Region、User、MonitoringDevice 均满足第二范式（2NF）

---

### 第三范式（3NF）

说明：
- 不存在非主属性对非主属性的传递函数依赖
- 所有非主属性均直接依赖于主码

结论：
Region、User、MonitoringDevice 均满足第三范式（3NF）

---


