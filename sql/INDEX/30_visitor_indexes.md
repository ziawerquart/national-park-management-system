# 游客管理业务线索引说明

## 1. idx_reservation_date (Reservation 表)

**适用范围**:
- 用于按预约日期查询预约记录
- 适用于生成按日期的预约统计报告
- 适用于预约状态查询

**字段说明**:
- `reservation_date`: 预约日期

## 2. idx_trajectory_location_time_region (VisitorTrajectory 表)

**适用范围**:
- 用于按轨迹时间范围和区域查询游客轨迹
- 适用于生成轨迹报告和越界行为分析
- 适用于实时监控游客位置

**字段说明**:
- `location_time`: 轨迹时间
- `region_id`: 区域ID

## 3. idx_visitor_id (Visitor 表)

**适用范围**:
- 用于快速查询游客信息
- 适用于游客详情展示
- 适用于关联查询游客的预约和轨迹信息

**字段说明**:
- `visitor_id`: 游客ID

## 4. idx_flowcontrol_region (FlowControl 表)

**适用范围**:
- 用于快速查询区域流量控制状态
- 适用于实时监控各区域的流量情况
- 适用于预警系统快速获取流量数据

**字段说明**:
- `region_id`: 区域ID