
# 一、📋 全系统【表清单速查表】（按业务线）

## （一）全局公共表（所有业务线都会用）

|表名|中文名|作用一句话|
|---|---|---|
|`Region`|区域表|定义国家公园的空间划分（核心区/缓冲区/实验区）|
|`User`|系统用户表|统一管理所有工作人员身份|
|`MonitoringDevice`|监测设备表|记录所有传感器、相机等设备信息|

---

## （二）生物多样性监测业务线

|表名|中文名|作用一句话|
|---|---|---|
|`Species`|物种表|记录国家公园内的物种基本信息|
|`Habitat`|栖息地表|描述物种生活的生态环境|
|`HabitatPrimarySpecies`|栖息地-物种关联表|解决“一个栖息地有多个物种”的多对多关系|
|`MonitoringRecord`|生物监测记录表|记录一次具体的物种监测行为|

---

## （三）生态环境监测业务线

|表名|中文名|作用一句话|
|---|---|---|
|`MonitoringIndicator`|监测指标表|定义监测内容（空气/水质等）|
|`EnvironmentalData`|环境监测数据表|存储设备采集的环境数据|
|`CalibrationRecord`|设备校准记录表|记录设备校准情况，保证数据可靠|
|`Alert`|异常预警表|记录环境数据异常产生的预警|

---

## （四）游客智能管理业务线

|表名|中文名|作用一句话|
|---|---|---|
|`Visitor`|游客表|记录入园游客的基本信息|
|`Reservation`|游客预约表|管理游客预约入园信息|
|`VisitorTrajectory`|游客轨迹表|记录游客在园区内的活动轨迹|
|`FlowControl`|区域流量控制表|控制区域游客承载量|

---

## （五）执法监管业务线

|表名|中文名|作用一句话|
|---|---|---|
|`VideoMonitorPoint`|视频监控点表|记录监控设备部署情况|
|`IllegalBehaviorRecord`|非法行为记录表|记录一次非法行为事件|
|`LawEnforcementOfficer`|执法人员表|管理执法人员信息|
|`LawEnforcementDispatch`|执法调度表|记录执法调度全过程|

---

## （六）科研数据支撑业务线

|表名|中文名|作用一句话|
|---|---|---|
|`ResearchProject`|科研项目表|记录科研项目基本信息|
|`ResearchDataRecord`|科研数据采集表|存储科研过程中采集/引用的数据|
|`ResearchAchievement`|科研成果表|管理论文、报告等科研成果|

---

# 二、🔗【表–表对应关系速查表】
---

## 1️⃣ 全局空间关系（以 Region 为中心）

|主表|关系|从表|说明|
|---|---|---|---|
|`Region`|1 : N|`Habitat`|一个区域有多个栖息地|
|`Region`|1 : N|`EnvironmentalData`|一个区域产生多条环境数据|
|`Region`|1 : N|`VisitorTrajectory`|游客在区域内活动|
|`Region`|1 : 1|`FlowControl`|每个区域一条流量控制记录|
|`Region`|1 : N|`VideoMonitorPoint`|一个区域部署多个监控点|
|`Region`|1 : N|`IllegalBehaviorRecord`|非法行为发生在某区域|
|`Region`|1 : N|`ResearchDataRecord`|科研数据采集于某区域|

---

## 2️⃣ 人（User）相关关系

|主表|关系|从表|说明|
|---|---|---|---|
|`User`|1 : N|`MonitoringRecord`|用户记录生物监测数据|
|`User`|1 : N|`CalibrationRecord`|技术人员校准设备|
|`User`|1 : N|`ResearchProject`|用户作为项目负责人|
|`User`|1 : N|`ResearchDataRecord`|用户采集/审核科研数据|

---

## 3️⃣ 设备相关关系

|主表|关系|从表|说明|
|---|---|---|---|
|`MonitoringDevice`|1 : N|`MonitoringRecord`|设备产生监测记录|
|`MonitoringDevice`|1 : N|`EnvironmentalData`|设备采集环境数据|
|`MonitoringDevice`|1 : N|`CalibrationRecord`|设备有多次校准|

---

## 4️⃣ 生物多样性业务线内部关系

|主表|关系|从表|说明|
|---|---|---|---|
|`Habitat`|N : M|`Species`|一个栖息地有多种物种|
|`Species`|1 : N|`MonitoringRecord`|一个物种有多条监测记录|

> 👉 **N:M 通过 `HabitatPrimarySpecies` 实现**

---

## 5️⃣ 生态环境监测业务线内部关系

|主表|关系|从表|说明|
|---|---|---|---|
|`MonitoringIndicator`|1 : N|`EnvironmentalData`|指标对应多条数据|
|`EnvironmentalData`|1 : 0/1|`Alert`|异常数据触发预警|

---

## 6️⃣ 游客管理业务线内部关系

|主表|关系|从表|说明|
|---|---|---|---|
|`Visitor`|1 : N|`Reservation`|游客可多次预约|
|`Visitor`|1 : N|`VisitorTrajectory`|游客产生多条轨迹|

---

## 7️⃣ 执法监管业务线内部关系

|主表|关系|从表|说明|
|---|---|---|---|
|`VideoMonitorPoint`|1 : N|`IllegalBehaviorRecord`|监控点捕捉非法行为|
|`LawEnforcementOfficer`|1 : N|`IllegalBehaviorRecord`|执法人员处理案件|
|`IllegalBehaviorRecord`|1 : N|`LawEnforcementDispatch`|一个案件可多次调度|

---

## 8️⃣ 科研数据支撑业务线内部关系

|主表|关系|从表|说明|
|---|---|---|---|
|`ResearchProject`|1 : N|`ResearchDataRecord`|项目产生多条采集记录|
|`ResearchProject`|1 : N|`ResearchAchievement`|项目对应多个成果|

---

## 9️⃣ 跨业务“软引用”关系（不强制外键）

|来源表|引用表|说明|
|---|---|---|
|`ResearchDataRecord`|`MonitoringRecord`|科研可复用生物监测数据|
|`ResearchDataRecord`|`EnvironmentalData`|科研可复用环境监测数据|
