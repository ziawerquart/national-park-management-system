
# 2.1.1 生物多样性监测业务线

## 1. 该业务数据

### 物种信息（Species）

- 物种编号（`species_id`）
    
- 物种名称（中文 / 拉丁名）（`species_name_cn` / `species_name_latin`）
    
- 物种分类（界 / 门 / 纲 / 目 / 科 / 属 / 种）
    
    - 界（`kingdom`）
        
    - 门（`phylum`）
        
    - 纲（`class`）
        
    - 目（`order`）
        
    - 科（`family`）
        
    - 属（`genus`）
        
    - 种（`species`）
        
- 保护级别（国家一级 / 二级 / 无）（`protection_level`）
    
- 生存习性（`living_habits`）
    
- 分布范围描述（`distribution_description`）
    

---

### 监测记录（Monitoring Record）

- 记录编号（`record_id`）
    
- 物种编号（`species_id`）
    
- 监测设备编号（`device_id`）
    
- 监测时间（`monitoring_time`）
    
- 监测地点（经纬度）（`longitude` / `latitude`）
    
- 监测方式（红外相机 / 人工巡查 / 无人机）（`monitoring_method`）
    
- 监测内容
    
    - 影像路径（`image_path`）
        
    - 数量统计（`count_number`）
        
    - 行为描述（`behavior_description`）
        
- 记录人 ID（`recorder_id`）
    
- 数据状态（有效 / 待核实）（`status`）
    

---

### 栖息地信息（Habitat）

- 栖息地编号（`habitat_id`）
    
- 区域名称（`area_name`）
    
- 生态类型（森林 / 湿地 / 草原等）（`ecological_type`）
    
- 面积（公顷）（`area_size`）
    
- 核心保护范围（`core_protection_area`）
    
- 主要物种编号（`primary_species_id`）
    
- 环境适宜性评分（`environment_suitability_score`）
    

---

## 2. 关键属性说明（字段层面）

- 物种编号为唯一标识（`species_id` 为主键），关联至对应的栖息地信息（`habitat_id`）。
    
- 监测记录需绑定监测设备（`device_id`）与记录人（`recorder_id`），影像数据以路径形式存储（`image_path`）。
    
- 栖息地信息支持多物种关联，一个栖息地可包含多个主要物种（`primary_species_id` 可多值关联）。
    

---

## 3. 业务活动说明（用于 UML 行为理解）

- 生态监测员（`ecological_monitor`）通过设备或人工方式采集物种数据并上传。
    
- 系统自动校验监测数据完整性，将状态标记为待核实（`status = 'pending'`）。
    
- 数据分析师（`data_analyst`）审核数据并更新状态（`status = 'valid'`）。
    

---

# 2.1.2 生态环境监测业务线

## 1. 该业务数据

### 监测指标信息（Monitoring Indicator）

- 指标编号（`indicator_id`）
    
- 指标名称（空气质量 / 水质 / 土壤湿度等）（`indicator_name`）
    
- 计量单位（`unit`）
    
- 标准阈值
    
    - 上限（`upper_threshold`）
        
    - 下限（`lower_threshold`）
        
- 监测频率（小时 / 日 / 周）（`monitoring_frequency`）
    

---

### 环境监测数据（Environment Monitoring Data）

- 数据编号（`data_id`）
    
- 指标编号（`indicator_id`）
    
- 监测设备编号（`device_id`）
    
- 采集时间（`collection_time`）
    
- 监测值（`monitoring_value`）
    
- 区域编号（`area_id`）
    
- 数据质量（优 / 良 / 中 / 差）（`data_quality`）
    

---

### 监测设备信息（Monitoring Device）

- 设备编号（`device_id`）
    
- 设备类型（`device_type`）
    
- 部署区域编号（`deployment_area_id`）
    
- 安装时间（`installation_time`）
    
- 校准周期（`calibration_cycle`）
    
- 运行状态（正常 / 故障 / 离线）（`device_status`）
    
- 通信协议（`communication_protocol`）
    

---

## 2.1.3 游客智能管理业务线

## 1. 该业务数据

### 游客信息（Visitor）

- 游客 ID（`visitor_id`）
    
- 姓名（`visitor_name`）
    
- 身份证号（`id_number`）
    
- 联系方式（`contact_number`）
    
- 预约记录编号（`reservation_id`）
    
- 入园时间（`entry_time`）
    
- 离园时间（`exit_time`）
    
- 入园方式（线上预约 / 现场购票）（`entry_method`）
    

---

### 预约记录（Reservation）

- 预约编号（`reservation_id`）
    
- 游客 ID（`visitor_id`）
    
- 预约日期（`reservation_date`）
    
- 入园时段（`entry_time_slot`）
    
- 同行人数（`group_size`）
    
- 预约状态（已确认 / 已取消 / 已完成）（`reservation_status`）
    
- 购票金额（`ticket_amount`）
    
- 支付状态（`payment_status`）
    

---

### 游客轨迹数据（Visitor Trajectory）

- 轨迹编号（`trajectory_id`）
    
- 游客 ID（`visitor_id`）
    
- 定位时间（`location_time`）
    
- 实时位置（经纬度）（`longitude` / `latitude`）
    
- 所在区域编号（`area_id`）
    
- 是否超出规定路线（`is_out_of_route`）
    

---

### 流量控制信息（Flow Control）

- 区域编号（`area_id`）
    
- 日最大承载量（`daily_capacity`）
    
- 实时在园人数（`current_visitor_count`）
    
- 预警阈值（`warning_threshold`）
    
- 当前状态（正常 / 预警 / 限流）（`flow_status`）
    

---

# 2.1.4 执法监管业务线

## 1. 该业务数据

### 执法人员信息（Law Enforcement Officer）

- 执法 ID（`officer_id`）
    
- 姓名（`officer_name`）
    
- 所属部门（`department`）
    
- 执法权限（`authority_level`）
    
- 联系方式（`contact_number`）
    
- 执法设备编号（`equipment_id`）
    

---

### 非法行为记录（Illegal Activity Record）

- 记录编号（`illegal_record_id`）
    
- 行为类型（`illegal_type`）
    
- 发生时间（`occurrence_time`）
    
- 发生区域编号（`area_id`）
    
- 影像证据路径（`evidence_path`）
    
- 处理状态（未处理 / 处理中 / 已结案）（`processing_status`）
    
- 执法 ID（`officer_id`）
    
- 处理结果（`handling_result`）
    
- 处罚依据（`penalty_basis`）
    

---

### 执法调度信息（Enforcement Dispatch）

- 调度编号（`dispatch_id`）
    
- 非法行为记录编号（`illegal_record_id`）
    
- 执法 ID（`officer_id`）
    
- 调度时间（`dispatch_time`）
    
- 响应时间（`response_time`）
    
- 处置完成时间（`completion_time`）
    
- 调度状态（待响应 / 已派单 / 已完成）（`dispatch_status`）
    

---

### 视频监控点信息（Surveillance Point）

- 监控点编号（`surveillance_point_id`）
    
- 部署区域编号（`deployment_area_id`）
    
- 安装位置（经纬度）（`longitude` / `latitude`）
    
- 监控范围（`coverage_area`）
    
- 设备状态（正常 / 故障）（`device_status`）
    
- 数据存储周期（`data_retention_period`）
    

---

# 2.1.5 科研数据支撑业务线

## 1. 该业务数据

### 科研项目信息（Research Project）

- 项目编号（`project_id`）
    
- 项目名称（`project_name`）
    
- 负责人 ID（`principal_investigator_id`）
    
- 申请单位（`applicant_organization`）
    
- 立项时间（`start_time`）
    
- 结题时间（`end_time`）
    
- 项目状态（在研 / 已结题 / 暂停）（`project_status`）
    
- 研究领域（`research_field`）
    

---

### 科研数据采集记录（Research Data Collection）

- 采集编号（`collection_id`）
    
- 项目编号（`project_id`）
    
- 采集人 ID（`collector_id`）
    
- 采集时间（`collection_time`）
    
- 区域编号（`area_id`）
    
- 采集内容（`collection_content`）
    
- 数据来源（实地采集 / 系统调用）（`data_source`）
    

---

### 科研成果信息（Research Result）

- 成果编号（`result_id`）
    
- 项目编号（`project_id`）
    
- 成果类型（论文 / 报告 / 专利等）（`result_type`）
    
- 成果名称（`result_name`）
    
- 发表 / 提交时间（`publish_time`）
    
- 共享权限（公开 / 内部共享 / 保密）（`access_level`）
    
- 文件路径（`file_path`）
    

---

---
