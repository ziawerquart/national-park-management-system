# 数据库设计文档

## 一、关系模式转换及范式分析

### 1. 实体类转换规则
基于UML类图，按照以下规则转换为关系模式：
- 实体类（C标记）→ 关系表
- 枚举类（E标记）→ 约束条件或独立枚举表
- 关联关系 → 外键或关联表

### 2. 转换后的关系模式

#### 2.1 User（用户）
```
User(user_id, name, role)
主码：user_id
外码：无
范式级别：BCNF
说明：所有非主属性完全依赖于主码
```

#### 2.2 ResearchProject（研究项目）
```
ResearchProject(project_id, project_name, principal_investigator_id, 
                applicant_organization, start_time, end_time, 
                project_status, research_field, leader_user_id)
主码：project_id
外码：principal_investigator_id REFERENCES User(user_id)
     leader_user_id REFERENCES User(user_id)
范式级别：BCNF
说明：项目状态使用枚举类型约束
```

#### 2.3 ResearchDataCollection（研究数据收集）
```
ResearchDataCollection(collection_id, collection_time, collector_id, 
                        area_id, collection_content, data_source, project_id)
主码：collection_id
外码：project_id REFERENCES ResearchProject(project_id)
范式级别：BCNF
说明：数据来源使用枚举类型约束
```

#### 2.4 ResearchResult（研究结果）
```
ResearchResult(result_id, result_type, result_name, publish_time, 
               access_level, file_path, project_id)
主码：result_id
外码：project_id REFERENCES ResearchProject(project_id)
范式级别：BCNF
说明：结果类型和访问级别使用枚举类型约束
```

#### 2.5 MonitoringRecord（监测记录）
```
MonitoringRecord(record_id, monitor_time, data_type, data_value, 
                 habitat_id, species_id, collection_id)
主码：record_id
外码：habitat_id REFERENCES Habitat(habitat_id)
     species_id REFERENCES Species(species_id)
     collection_id REFERENCES ResearchDataCollection(collection_id)
范式级别：BCNF
说明：关联栖息地、物种和数据收集
```

#### 2.6 Species（物种）
```
Species(species_id, scientific_name, common_name, protection_level)
主码：species_id
外码：无
范式级别：BCNF
说明：物种基本信息表
```

#### 2.7 Habitat（栖息地）
```
Habitat(habitat_id, habitat_name, region_code)
主码：habitat_id
外码：无
范式级别：BCNF
说明：栖息地基本信息表
```

#### 2.8 HabitatPrimarySpecies（栖息地主要物种）
```
HabitatPrimarySpecies(id, habitat_id, species_id)
主码：id
外码：habitat_id REFERENCES Habitat(habitat_id)
     species_id REFERENCES Species(species_id)
候选码：(habitat_id, species_id)
范式级别：BCNF
说明：栖息地与物种的多对多关系连接表
```

---

## 二、范式分析总结

### 2.1 范式判定依据

所有关系模式均满足 **BCNF（Boyce-Codd范式）**：
- ✅ **1NF**：所有属性均为原子值，不可再分
- ✅ **2NF**：所有非主属性完全依赖于主码（无部分依赖）
- ✅ **3NF**：所有非主属性不传递依赖于主码
- ✅ **BCNF**：每个决定因素都包含码

### 2.2 设计优势

1. **消除冗余**：通过合理的外键关联避免数据重复
2. **保证一致性**：使用枚举约束确保数据有效性
3. **易于维护**：清晰的主外键关系便于数据更新
4. **查询效率**：合理的索引设计支持高效查询

---

## 三、关系图说明

### 3.1 实体关系
- User ← ResearchProject（一对多：用户可负责多个项目）
- ResearchProject ← ResearchDataCollection（一对多）
- ResearchProject ← ResearchResult（一对多）
- ResearchDataCollection ← MonitoringRecord（一对多）
- Habitat ↔ Species（多对多：通过HabitatPrimarySpecies关联）
- Habitat ← MonitoringRecord（一对多）
- Species ← MonitoringRecord（一对多）

### 3.2 枚举类型
- ProjectStatus：项目状态（待审批/进行中/已结项/已终止）
- DataSource：数据来源（现场采集/卫星遥感/历史资料/第三方数据）
- ResultType：结果类型（论文/报告/专利/数据集）
- AccessLevel：访问级别（公开/内部/保密）

---

## 四、完整性约束

### 4.1 实体完整性
- 每个表都有主码且非空
- 主码唯一标识每条记录

### 4.2 参照完整性
- 外键必须引用存在的主码值或为NULL
- 级联操作保证数据一致性

### 4.3 用户定义完整性
- 枚举类型约束
- 日期范围约束（start_time < end_time）
- 非空约束（NOT NULL）