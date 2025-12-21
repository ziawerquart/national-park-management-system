# 执法系统UML类图详细描述

## 一、UML类图整体概览
本UML类图呈现了执法业务系统的核心对象结构，包含5个业务实体类，通过关联关系映射了“执法设备管理-执法人员履职-监控点位采集-违规行为记录-执法任务调度”的全业务流程，明确了类的属性、访问控制及类间的关联规则。


## 二、核心业务类详情

### 1. LawDevice（执法设备类）
#### 类基本信息
- 类类型：持久化实体类
- 访问级别：`public`
- 核心作用：封装执法设备的基础信息与状态

#### 属性列表
| 属性名          | 类型       | 访问修饰符 | 说明                     | 约束标识       |
|-----------------|------------|------------|--------------------------|----------------|
| deviceId        | String     | private    | 设备唯一标识             | 主键（PK）、不可空 |
| deviceName      | String     | private    | 设备名称（如“执法记录仪001”） | 可空           |
| deviceType      | String     | private    | 设备类型（如“执法记录仪”“监控摄像头”） | 可空           |
| deviceStatus    | String     | private    | 设备状态（如“在用”“维修中”） | 可空           |
| deviceModel     | String     | private    | 设备型号                 | 可空           |
| purchaseDate    | Date       | private    | 设备采购日期             | 可空           |

#### 关联关系
| 关联类                          | 关系类型 | 关联名称 | 基数约束（LawDevice → 关联类） |
|---------------------------------|----------|----------|--------------------------------|
| LawEnforcementOfficer           | 关联     | 分配     | 1 : 0..*（1台设备可分配给多名人员） |
| VideoMonitorPoint               | 关联     | 绑定     | 1 : 0..*（1台设备可绑定多个监控点位） |


### 2. LawEnforcementOfficer（执法人员类）
#### 类基本信息
- 类类型：持久化实体类
- 访问级别：`public`
- 核心作用：封装执法人员的身份与履职信息

#### 属性列表
| 属性名          | 类型       | 访问修饰符 | 说明                     | 约束标识       |
|-----------------|------------|------------|--------------------------|----------------|
| lawId           | String     | private    | 执法人员工号             | 主键（PK）、不可空 |
| name            | String     | private    | 人员姓名                 | 不可空         |
| department      | String     | private    | 所属部门                 | 可空           |
| authority       | String     | private    | 执法权限（如“一级执法”） | 可空           |
| contact         | String     | private    | 联系方式                 | 可空           |
| deviceId        | String     | private    | 关联的设备ID             | 外键（FK）、可空 |

#### 关联关系
| 关联类                          | 关系类型 | 关联名称 | 基数约束（LawEnforcementOfficer → 关联类） |
|---------------------------------|----------|----------|-------------------------------------------|
| LawDevice                       | 关联     | 领用     | 0..* : 1（多名人员可领用1台设备） |
| IllegalBehaviorRecord           | 关联     | 经办     | 1 : 0..*（1名人员可经办多条违规记录） |
| LawEnforcementDispatch          | 关联     | 处理     | 1 : 0..*（1名人员可处理多个调度任务） |


### 3. VideoMonitorPoint（视频监控点位类）
#### 类基本信息
- 类类型：持久化实体类
- 访问级别：`public`
- 核心作用：封装监控点位的位置与设备信息

#### 属性列表
| 属性名          | 类型       | 访问修饰符 | 说明                     | 约束标识       |
|-----------------|------------|------------|--------------------------|----------------|
| monitorId       | String     | private    | 监控点位ID               | 主键（PK）、不可空 |
| regionId        | String     | private    | 所属区域ID               | 可空           |
| latitude        | Decimal    | private    | 纬度坐标                 | 不可空         |
| longitude       | Decimal    | private    | 经度坐标                 | 不可空         |
| monitorRange    | String     | private    | 监控范围（如“50米”）| 可空           |
| deviceId        | String     | private    | 关联的设备ID             | 外键（FK）、不可空 |
| storageCycle    | Integer    | private    | 视频存储周期（天）| 可空           |

#### 关联关系
| 关联类                          | 关系类型 | 关联名称 | 基数约束（VideoMonitorPoint → 关联类） |
|---------------------------------|----------|----------|----------------------------------------|
| LawDevice                       | 关联     | 挂载     | 0..* : 1（多个点位可挂载1台设备） |
| IllegalBehaviorRecord           | 关联     | 证据来源 | 1 : 0..*（1个点位可作为多条记录的证据） |


### 4. IllegalBehaviorRecord（违规行为记录类）
#### 类基本信息
- 类类型：持久化实体类
- 访问级别：`public`
- 核心作用：封装违规行为的信息与处置记录

#### 属性列表
| 属性名          | 类型       | 访问修饰符 | 说明                     | 约束标识       |
|-----------------|------------|------------|--------------------------|----------------|
| recordId        | String     | private    | 违规记录ID               | 主键（PK）、不可空 |
| behaviorType    | String     | private    | 违规类型（如“占道经营”） | 不可空         |
| occurTime       | DateTime   | private    | 违规发生时间             | 不可空         |
| regionId        | String     | private    | 违规区域ID               | 可空           |
| evidencePath    | String     | private    | 证据文件路径             | 可空           |
| lawId           | String     | private    | 经办人员ID               | 外键（FK）、可空 |
| processResult   | String     | private    | 处理结果（如“已处罚”）| 可空           |
| punishBasis     | String     | private    | 处罚依据（如“《治安管理处罚法》第XX条”） | 可空           |
| monitorId       | String     | private    | 关联的监控点位ID         | 外键（FK）、可空 |

#### 关联关系
| 关联类                          | 关系类型 | 关联名称 | 基数约束（IllegalBehaviorRecord → 关联类） |
|---------------------------------|----------|----------|-------------------------------------------|
| LawEnforcementOfficer           | 关联     | 经办     | 0..* : 1（多条记录可由1名人员经办） |
| VideoMonitorPoint               | 关联     | 证据来源 | 0..* : 1（多条记录可关联1个监控点位） |
| LawEnforcementDispatch          | 关联     | 触发     | 1 : 1..*（1条记录可触发多个调度任务） |


### 5. LawEnforcementDispatch（执法调度类）
#### 类基本信息
- 类类型：持久化实体类
- 访问级别：`public`
- 核心作用：封装执法任务的调度与执行信息

#### 属性列表
| 属性名          | 类型       | 访问修饰符 | 说明                     | 约束标识       |
|-----------------|------------|------------|--------------------------|----------------|
| dispatchId      | String     | private    | 调度任务ID               | 主键（PK）、不可空 |
| recordId        | String     | private    | 关联的违规记录ID         | 外键（FK）、不可空 |
| lawId           | String     | private    | 指派的执法人员ID         | 外键（FK）、不可空 |
| dispatchTime    | DateTime   | private    | 调度发起时间             | 不可空         |
| responseTime    | DateTime   | private    | 人员响应时间             | 可空           |
| finishTime      | DateTime   | private    | 任务完成时间             | 可空           |
| dispatchStatus  | String     | private    | 调度状态（如“已派单”“已完成”） | 不可空         |

#### 关联关系
| 关联类                          | 关系类型 | 关联名称 | 基数约束（LawEnforcementDispatch → 关联类） |
|---------------------------------|----------|----------|-------------------------------------------|
| LawEnforcementOfficer           | 关联     | 指派     | 0..* : 1（多个任务可指派给1名人员） |
| IllegalBehaviorRecord           | 关联     | 关联记录 | 1..* : 1（多个任务可关联1条违规记录） |


## 三、类间关系总结
| 业务流程链路                     | 涉及类（按流程顺序）|
|----------------------------------|--------------------------------|
| 设备管理 → 人员领用               | LawDevice → LawEnforcementOfficer |
| 设备挂载 → 监控点位采集           | LawDevice → VideoMonitorPoint |
| 监控点位 → 违规记录（证据）| VideoMonitorPoint → IllegalBehaviorRecord |
| 违规记录 → 执法调度 → 人员处理   | IllegalBehaviorRecord → LawEnforcementDispatch → LawEnforcementOfficer |