# 游客管理业务线存储过程说明

## 1. generate_reservation_summary

**适用范围**:
- 用于按日期范围生成预约统计报告
- 适用于景区管理人员进行预约情况分析
- 适用于财务部门进行收入统计

**参数说明**:
- `start_date`: 开始日期
- `end_date`: 结束日期

**返回结果**:
- `region_name`: 区域名称
- `reservation_date`: 预约日期
- `reservation_status`: 预约状态
- `reservation_count`: 预约数量
- `total_revenue`: 总收入

## 2. calculate_real_time_visitor_count

**适用范围**:
- 用于计算各区域的实时游客人数
- 适用于景区运营管理部门进行人流调度
- 适用于预警系统进行流量预警

**参数说明**:
- 无参数，自动计算当天的游客人数

**返回结果**:
- `region_name`: 区域名称
- `current_visitor_count`: 当前游客数

## 3. generate_out_of_route_report

**适用范围**:
- 用于生成越界行为报告
- 适用于安全监控部门进行违规行为追踪
- 适用于景区管理进行游客行为规范

**参数说明**:
- `start_date`: 开始时间
- `end_date`: 结束时间

**返回结果**:
- `visitor_name`: 游客姓名
- `contact_number`: 联系方式
- `region_name`: 区域名称
- `location_time`: 轨迹时间
- `longitude`: 经度
- `latitude`: 纬度