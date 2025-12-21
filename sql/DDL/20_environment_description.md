# environment关系模式与规范化分析

## 1. MonitoringIndicator（监测指标表）

### 1.1 关系模式

MonitoringIndicator(indicator_id (PK),indicator_name,unit,upper_limit,lower_limit,monitor_frequency)

### 1.2 范式级别验证

- **第一范式（1NF）**  
  所有属性均为原子属性，不存在重复组，满足 1NF。
- **第二范式（2NF）**  
  主码为单属性主码 indicator_id，不存在部分函数依赖，满足 2NF。
- **第三范式（3NF）**  
  所有非主属性均直接依赖于主码 indicator_id，不存在传递依赖，满足 3NF。

**最高范式：第三范式（3NF）**

---

## 2. EnvironmentalData（环境监测数据表）

### 2.1 关系模式

EnvironmentalData(data_id (PK),indicator_id (FK ),device_id (FK ),region_id (FK ),collect_time,monitor_value,data_quality,is_abnormal)

### 2.2 范式级别验证

- **第一范式（1NF）**  
  各字段均为不可再分的原子值，满足 1NF。
- **第二范式（2NF）**  
  主码 data_id 为单属性，所有非主属性完全依赖于 data_id，满足 2NF。
- **第三范式（3NF）**  
  不存在非主属性对非主属性的函数依赖，外键不构成传递依赖，满足 3NF。

**最高范式：第三范式（3NF）**

---

## 3. CalibrationRecord（设备校准记录表）

### 3.1 关系模式

CalibrationRecord(record_id (PK),device_id (FK),calibration_time,technician_id (FK ), remark)

### 3.2 范式级别验证

- **第一范式（1NF）**  
  所有字段均为原子属性，满足 1NF。
- **第二范式（2NF）**  
  主码为 record_id，非主属性完全依赖主码，满足 2NF。
- **第三范式（3NF）**  
  非主属性之间不存在传递函数依赖，满足 3NF。

**最高范式：第三范式（3NF）**

---

## 4. Alert（告警信息表）

### 4.1 关系模式

Alert(alert_id (PK),data_id (FK),alert_time,alert_level,alert_status)

### 4.2 范式级别验证

- **第一范式（1NF）**  
  各属性均为原子属性，满足 1NF。
- **第二范式（2NF）**  
  主码为单属性 alert_id，不存在部分依赖，满足 2NF。
- **第三范式（3NF）**  
  所有非主属性仅依赖于 alert_id，不存在传递依赖，满足 3NF。

**最高范式：第三范式（3NF）**

---
