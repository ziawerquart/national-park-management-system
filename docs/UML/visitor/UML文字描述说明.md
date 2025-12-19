UML文字描述说明：

1. 实体与属性设计说明
约束精准适配需求：
Visitor.id_number标注(UNIQUE)，严格匹配 “游客 ID 与身份证号绑定，唯一标识游客身份” 的关键要求，避免身份重复；
VisitorTrajectory包含area_id (FK)，完全还原需求中 “游客轨迹数据含所在区域编号” 的明确数据项，无遗漏、无冗余；
枚举类型（如EntryMethod、FlowStatus）与需求中的中文状态一一对应，标准化命名便于数据库实现与业务逻辑判断。
数据粒度贴合业务：
VisitorTrajectory.location_time采用Date类型，支持 “分钟级采集” 的时序精度，每条记录对应游客某一分钟的瞬时状态，确保轨迹追踪的实时性；
FlowControl.current_visitor_count为整数类型，适配 “实时更新在园人数” 的需求，支撑流量阈值判断。
2. 关系设计逻辑说明
1:*(一对多) 关系：
Visitor - Reservation：一个游客可多次预约（如年度内多次入园），每条预约记录仅对应一个游客，支撑 “预约申请 - 审核 - 生成记录” 的业务流程；
Visitor - VisitorTrajectory：一个游客在园期间产生多条分钟级轨迹，每条轨迹仅归属一个游客，确保轨迹数据可追溯至具体游客，支撑 “实时追踪” 与 “违规追责”。
*(多对一) 关系：
VisitorTrajectory - FlowControl：多条轨迹对应一个区域（如核心保护区内所有游客的瞬时轨迹），一条轨迹仅对应一个区域，完全匹配 “每条轨迹的所在区域” 的需求定义。该关系直接支撑两大核心业务：
区域流量统计：通过汇总某区域下的VisitorTrajectory记录（去重游客 ID），更新FlowControl.current_visitor_count；
精准预警：结合VisitorTrajectory.is_out_of_route（路线违规）与FlowControl.warning_threshold（流量阈值），触发针对性预警。
3. 业务活动适配性说明
预约流程：Visitor提交申请→系统生成Reservation记录，通过visitor_id关联，实现 “预约状态查询”“入园凭证核验”；
入园流程：游客核验身份后，系统更新Visitor.entry_time，并通过area_id关联FlowControl，自动累加current_visitor_count；
轨迹追踪与预警流程：系统每分钟采集VisitorTrajectory数据，通过area_id关联对应区域的FlowControl规则：
若is_out_of_route=true，触发安全预警；
若current_visitor_count ≥ warning_threshold，更新flow_status为 “预警”，启动限流措施。