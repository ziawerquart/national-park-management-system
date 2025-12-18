

## UML 类图描述（生物多样性监测业务线）

本 UML 类图用于描述生物多样性监测业务线的核心数据实体、属性及实体间关系，覆盖物种管理、栖息地管理、监测记录采集与审核流转等业务需求。

### 1. 枚举类型定义（Enums）

- **RecordStatus**：用于描述监测记录的数据状态，取值包括  
    `pending`（待核实）、`rechecked`（已复查）、`valid`（有效）。
    
- **MonitoringMethod**：用于描述监测方式，取值包括  
    `camera`（红外相机）、`manual`（人工巡查）、`drone`（无人机）。
    
- **ProtectionLevel**：用于描述物种保护级别，取值包括  
    `first_class`（国家一级）、`second_class`（国家二级）、`none`（无）。
    
- **UserRole**：用于区分系统用户角色，取值包括  
    `ecological_monitor`（生态监测员）、`data_analyst`（数据分析师）。
    

---

### 2. 核心类及属性说明（Core Classes）

#### （1）Species（物种）

用于存储物种基础信息及分类信息，主键为 `species_id`。  
包括中文名、拉丁名、分类层级（界/门/纲/目/科/属/种）、保护级别、生活习性与分布描述等字段。  
其中 `habitat_id` 为可选外键字段，用于表示物种关联的主要栖息地（可为空）。

#### （2）Habitat（栖息地）

用于存储栖息地基础信息，主键为 `habitat_id`。  
包含区域名称、生态类型、面积、核心保护范围描述、环境适宜性评分等字段。

#### （3）HabitatPrimarySpecies（栖息地主物种关联）

用于表示“栖息地—主物种”的关联关系。  
采用复合主键 `(habitat_id, species_id)`，并以 `is_primary` 标识该物种是否为该栖息地的主物种。  
该类相当于数据库中的关联表，用于支持“一个栖息地包含多个主物种”的需求。

#### （4）MonitoringRecord（监测记录）

用于存储监测采集数据，主键为 `record_id`。  
包含监测时间、经纬度位置、监测方式、影像路径、数量统计、行为描述等字段；  
其中：

- `species_id` 关联物种；
    
- `device_id` 关联监测设备（允许为空以支持人工巡查场景）；
    
- `recorder_id` 关联记录人（生态监测员）；
    
- `status` 用于描述记录状态（pending → rechecked → valid）。
    

#### （5）MonitoringDevice（监测设备）

用于存储监测设备基础信息，主键为 `device_id`。  
包含设备类型、部署区域等字段，可用于追踪监测数据来源。

#### （6）User（用户）

用于存储系统用户信息，主键为 `user_id`。  
`role` 字段用于区分用户角色（生态监测员/数据分析师），支持后续 RBAC 权限控制及审核职责划分。

---

### 3. 类之间关系与多重性说明（Relationships）

1. **Habitat 与 Species（栖息地包含物种）**
    
    - `Habitat 1 -- 0..* Species`：一个栖息地可包含多个物种；
        
    - `Species 0..1 -- 1 Habitat`：一个物种可选关联一个主要栖息地（允许暂不关联）。
        
2. **Habitat 与 Species 的主物种关联（通过 HabitatPrimarySpecies 实现）**
    
    - `Habitat 1 -- 0..* HabitatPrimarySpecies`
        
    - `Species 1 -- 0..* HabitatPrimarySpecies`  
        表示栖息地与物种在“主物种”层面存在多对多关系，并通过关联类/关联表进行表达。
        
3. **Species 与 MonitoringRecord（物种产生监测记录）**
    
    - `Species 1 -- 0..* MonitoringRecord`  
        表示一个物种可对应多条监测记录，每条监测记录必须关联一个物种。
        
4. **MonitoringDevice 与 MonitoringRecord（设备产生监测记录）**
    
    - `MonitoringDevice 0..1 -- 0..* MonitoringRecord`  
        表示一条监测记录可选关联一个设备，支持人工巡查记录无设备编号的情况；一个设备可产生多条监测记录。
        
5. **User 与 MonitoringRecord（记录人上传监测记录）**
    
    - `User 1 -- 0..* MonitoringRecord`（records）  
        表示一个用户（生态监测员）可以上传多条监测记录，每条记录必须有记录人。
        

---

### 4. 业务一致性说明（与用例/鲁棒图对应）

监测记录的状态字段 `status` 与业务流程一致：

- 生态监测员上传监测记录后，系统初始标记为 `pending`；
    
- 生态监测员复查后更新为 `rechecked`；
    
- 数据分析师终审后更新为 `valid`。
    

该设计保证了监测数据从采集、复查到终审的全流程可追踪，且数据结构能够支持后续统计报表与分析任务。
