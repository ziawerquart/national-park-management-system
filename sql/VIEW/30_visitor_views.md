# 游客管理业务线视图说明

## 1. ReservationSummary (预约统计视图)

**适用范围**:
- 用于生成按日期、区域、预约状态的预约统计报告
- 适用于景区管理人员进行预约情况分析
- 适用于财务部门进行收入统计

**字段说明**:
- `region_name`: 区域名称
- `reservation_date`: 预约日期
- `reservation_status`: 预约状态
- `reservation_count`: 预约数量
- `total_revenue`: 总收入

## 2. VisitorEntrySummary (入园情况视图)

**适用范围**:
- 用于实时监控游客入园情况
- 适用于景区入口管理
- 适用于游客行为分析

**字段说明**:
- `visitor_name`: 游客姓名
- `entry_method`: 入园方式（线上/现场）
- `entry_date`: 入园日期
- `region_name`: 区域名称
- `location_time`: 轨迹时间

## 3. OutOfRouteTrajectories (轨迹/越界视图)

**适用范围**:
- 用于发现和分析游客越界行为
- 适用于安全监控部门进行违规行为追踪
- 适用于景区管理进行游客行为规范

**字段说明**:
- `visitor_name`: 游客姓名
- `contact_number`: 联系方式
- `region_name`: 区域名称
- `location_time`: 轨迹时间
- `longitude`: 经度
- `latitude`: 纬度
- `is_out_of_route`: 是否越界

## 4. RegionFlowControlSummary (区域流量控制视图)

**适用范围**:
- 用于实时监控各区域的流量控制状态
- 适用于景区运营管理部门进行人流调度
- 适用于预警系统进行流量预警

**字段说明**:
- `region_name`: 区域名称
- `daily_capacity`: 日容量
- `current_visitor_count`: 当前游客数
- `warning_threshold`: 预警阈值
- `flow_status`: 流量状态
- `occupancy_pct`: 占用率