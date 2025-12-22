## 1) UML → 关系模式（标 PK / FK）

### ① Species（物种）

**关系模式：**  
`Species( species_id PK, species_name_cn, species_name_latin, kingdom, phylum, tax_class, tax_order, family, genus, species, protection_level, living_habits, distribution_description, habitat_id FK→Habitat(habitat_id) )`

- **主码 PK**：`species_id`
    
- **外码 FK（本文件内可写）**：`habitat_id → Habitat(habitat_id)`  
    （数据字典里标注为 FK，且允许 NULL）
    

### ② Habitat（栖息地）

**关系模式：**  
`Habitat( habitat_id PK, area_name, ecological_type, area_size, core_protection_area, environment_suitability_score, region_id FK→Region(region_id) )`

- **主码 PK**：`habitat_id`
    
- **外码 FK（跨文件先不写约束）**：`region_id → Region(region_id)`（跨文件：全局表 Region）
    

### ③ HabitatPrimarySpecies（栖息地-物种 N:M 中间表）

**关系模式：**  
`HabitatPrimarySpecies( habitat_id PK/FK→Habitat(habitat_id), species_id PK/FK→Species(species_id), is_primary )`

- **主码 PK**：`(habitat_id, species_id)`（联合主键）
    
- **外码 FK（本文件内可写）**：
    
    - `habitat_id → Habitat(habitat_id)`
        
    - `species_id → Species(species_id)`
        

### ④ MonitoringRecord（生物监测记录）

**关系模式：**  
`MonitoringRecord( record_id PK, species_id FK→Species(species_id), device_id FK→MonitoringDevice(device_id), monitoring_time, longitude, latitude, monitoring_method, image_path, count_number, behavior_description, recorder_id FK→User(user_id), status )`

- **主码 PK**：`record_id`
    
- **外码 FK（本文件内可写）**：`species_id → Species(species_id)`
    
- **外码 FK（跨文件先不写约束）**：
    
    - `device_id → MonitoringDevice(device_id)`（全局表）
        
    - `recorder_id → User(user_id)`（全局表）
        

> 上面字段类型/可空性以全局数据字典为准。
> 
> naming_check_stage1

---

## 2) 范式验证（到 3NF/BCNF）

### Species

- **函数依赖**：`species_id → 其余所有非主属性(… , habitat_id)`
    
- 非主属性都**完全依赖**主键 `species_id`，无部分依赖、无传递依赖  
    ✅ **满足 3NF（也可视为 BCNF）**
    

### Habitat

- **函数依赖**：`habitat_id → (area_name, ecological_type, area_size, core_protection_area, environment_suitability_score, region_id)`
    
- 非主属性完全依赖主键 `habitat_id`  
    ✅ **满足 3NF（也可视为 BCNF）**
    

### HabitatPrimarySpecies

- 主键是联合键 `(habitat_id, species_id)`
    
- `is_primary` 依赖于**整个联合键**（某栖息地-某物种这条关联是否为主要物种）  
    ✅ **满足 3NF（也可视为 BCNF）**
    

### MonitoringRecord

- **函数依赖**：`record_id → (species_id, device_id, monitoring_time, longitude, latitude, monitoring_method, image_path, count_number, behavior_description, recorder_id, status)`
    
- 无部分依赖、无传递依赖（把“设备信息/用户信息/物种信息”放在各自表里，通过外键引用）  
    ✅ **满足 3NF（也可视为 BCNF）**