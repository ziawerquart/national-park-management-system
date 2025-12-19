# 执法监管业务线鲁棒图说明

## 一、业务启动：非法行为监测
通过**视频监控（Video Surveillance）**功能识别非法活动，触发业务流程的起点。


## 二、核心流程与模块交互
### 1. 检测接口（Detection Interface）
接收视频监控的非法行为检测结果后，同步执行两个动作：
- 向**自动告警控制器（Auto-Alert Controller）**发送「告警触发（Send Alert Trigger）」；
- 向**调度逻辑（Dispatch Logic）**发起「触发调度（Trigger Dispatch）」。


### 2. 自动告警与执法介入
- **自动告警控制器（Auto-Alert Controller）**：接收告警触发信号后，向**执法操作界面（Enforcement UI）**推送信息；
- **执法操作界面（Enforcement UI）**：由**执法人员（Law Officer）**开展「现场处置+证据上传（Handle Scene & Upload Evidence）」操作。


### 3. 调度指令生成与下发
- **调度逻辑（Dispatch Logic）**：触发调度后，先向**摄像头点位信息（Camera Point Info）**校验监控点位，再结合**执法人员信息（Officer Info）**生成「调度指令（Generate Dispatch Order）」；
- **调度信息（Dispatch Info）**：接收调度指令后，将指令推送至**调度终端（Dispatch Terminal）**。


## 三、处置闭环与记录管理
### 1. 执法处置操作
执法人员完成现场处置后，在**执法操作界面（Enforcement UI）**执行：
- 「创建违规记录（Create Violation Record）」；
- 「更新处置详情（Update Handling Details）」；
信息同步至**案件状态管理器（Case Status Manager）**。


### 2. 案件状态与调度闭环
**案件状态管理器（Case Status Manager）**接收处置详情后，同步执行：
- 向**调度终端（Dispatch Terminal）**反馈「完成调度周期（Complete Dispatch Cycle）」；
- 向**违规记录（Violation Record）**同步「证据关联（Associated with Evidence）」信息。


### 3. 违规记录归档
**违规记录（Violation Record）**接收案件状态信息后：
- 更新记录状态（如标记为“已结案”）；
- 关联**执法人员信息（Officer Info）**的「处置人员（Handed By）」信息，完成业务全闭环。


## 业务逻辑总结
该流程实现了**“非法行为监测→自动告警+调度触发→执法处置→案件记录与结案”**的全链路执法监管，通过检测、调度、执法、记录等模块的协同，完成从违规发现到处置归档的完整业务流程。