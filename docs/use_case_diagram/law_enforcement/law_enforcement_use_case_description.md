# 执法监管业务线用例图说明

## 一、核心参与角色
本用例图围绕执法监管业务，定义三类核心参与角色：
- **执法人员（law_enforcement_officer）**：一线执法操作执行者；
- **系统管理员（system_administrator）**：系统基础信息与安全维护者；
- **公园管理者（park_manager）**：业务监管与规则配置者。

## 二、各角色核心用例与操作逻辑
### 1. 执法人员（law_enforcement_officer）
作为核心执行角色，承接现场执法全流程操作，核心用例包括：
- 「接收执法调度（Receive Enforcement Dispatch）」：接收系统下发的执法任务调度指令；
- 「处置非法行为（Handle Illegal Behavior）」：针对监测到的非法活动开展现场执法处置；
- 「上传处置结果与证据（Upload Handling Result and Evidence）」：将处置过程、结果及相关证据同步上传至系统；
- 「查看个人执法记录（View Personal Enforcement Records）」：查阅本人参与的所有执法案件记录。

### 2. 系统管理员（system_administrator）
聚焦系统底层支撑与管理，核心用例包括：
- 「管理执法人员信息（Manage Enforcement Personnel Information）」：维护执法人员的基础档案、权限等信息；
- 「管理监控点位信息（Manage Surveillance Point Information）」：配置、更新摄像头等监控设备的点位、状态等信息；
- 「维护系统安全与日志（Maintain System Security and Logs）」：保障系统稳定运行，管理操作日志、权限安全等。

### 3. 公园管理者（park_manager）
侧重业务层面的监管与规则配置，核心用例包括：
- 「查看非法行为告警（View Illegal Behavior Alerts）」：接收并查看系统推送的非法行为监测告警信息；
- 「查看执法处置状态（View Enforcement Handling Status）」：实时跟踪执法任务的处置进度、结果等状态；
- 「定义执法调度规则（Define Enforcement Dispatch Rules）」：配置执法任务的调度逻辑、派单规则等。

## 三、用例逻辑总结
本用例图清晰划分了执法、管理、监管三类角色的核心职责，实现“**系统支撑（管理员）→ 规则配置（管理者）→ 现场执法（执法人员）**”的协作闭环，覆盖从执法任务下发、现场处置到结果追溯的全业务环节，保障执法监管业务的规范化与流程化。