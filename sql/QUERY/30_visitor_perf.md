# 游客管理系统性能优化记录

## 查询1: 获取每个区域的游客轨迹数量、平均停留时长和偏离路线统计

### 优化前耗时: 
- 方法1: 12.45ms
- 方法2: 15.23ms

### 优化措施: 
- 在VisitorTrajectory表上创建复合索引: `CREATE INDEX idx_region_visitor_time ON VisitorTrajectory(region_id, visitor_id, location_time);`
- 在Visitor表上创建索引: `CREATE INDEX idx_visitor_time ON Visitor(entry_time, exit_time);`

### 优化后耗时: 
- 方法1: 8.12ms
- 方法2: 11.67ms

---

## 查询2: 获取预约状态为确认的游客的详细信息、预约统计和轨迹偏离情况

### 优化前耗时: 
- 方法1: 9.78ms
- 方法2: 13.45ms

### 优化措施: 
- 在Reservation表上创建复合索引: `CREATE INDEX idx_reservation_status ON Reservation(visitor_id, reservation_status);`
- 在VisitorTrajectory表上创建索引: `CREATE INDEX idx_trajectory_visitor ON VisitorTrajectory(visitor_id);`

### 优化后耗时: 
- 方法1: 6.34ms
- 方法2: 9.87ms

---

## 查询3: 获取各区域流量状态统计和预约趋势分析

### 优化前耗时: 
- 方法1: 14.67ms
- 方法2: 16.89ms

### 优化措施: 
- 在Reservation表上创建索引: `CREATE INDEX idx_reservation_visitor_date ON Reservation(visitor_id, reservation_date);`
- 优化JOIN顺序，先过滤再JOIN

### 优化后耗时: 
- 方法1: 10.23ms
- 方法2: 12.45ms

---

## 查询4: 获取游客轨迹偏离路线的详细统计和支付状态分析

### 优化前耗时: 
- 方法1: 11.23ms
- 方法2: 14.56ms

### 优化措施: 
- 在VisitorTrajectory表上创建索引: `CREATE INDEX idx_trajectory_out_of_route ON VisitorTrajectory(is_out_of_route, visitor_id);`
- 优化WHERE条件顺序

### 优化后耗时: 
- 方法1: 7.89ms
- 方法2: 10.34ms

---

## 查询5: 获取各时间段游客流量趋势和区域承载分析

### 优化前耗时: 
- 方法1: 16.78ms
- 方法2: 19.12ms

### 优化措施: 
- 在VisitorTrajectory表上创建时间索引: `CREATE INDEX idx_trajectory_time ON VisitorTrajectory(location_time);`
- 使用分区表优化时间范围查询

### 优化后耗时: 
- 方法1: 12.45ms
- 方法2: 15.67ms