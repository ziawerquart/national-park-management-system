# 1️⃣ 鲁棒图说明一

## Upload Monitoring Record（生态监测员上传监测数据）

### 用例说明

本鲁棒图描述了生态监测员上传物种监测数据的业务过程。该用例的主要目标是将现场采集的监测数据录入系统，并由系统自动完成基础校验后生成一条新的监测记录。

### 参与对象说明

- **Actor：Ecological Monitor**  
    生态监测员，负责采集并提交物种监测数据。
    
- **Boundary：Monitoring Record Upload Interface**  
    监测记录上传界面，用于录入物种编号、监测时间、地点、监测方式及监测内容等信息。
    
- **Controller：Upload Monitoring Record Controller**  
    上传控制器，负责接收界面提交的数据并协调数据持久化操作。
    
- **Entity：Monitoring Record**  
    监测记录实体，对应数据库中的监测记录表。
    

### 业务流程说明

1. 生态监测员通过上传界面输入监测数据。
    
2. 上传界面将监测数据提交给上传控制器。
    
3. 控制器将数据写入监测记录实体，并创建新的监测记录。
    
4. 系统在插入数据时将记录状态初始化为 `status = 'pending'`，表示该数据尚未完成人工核实。
    
5. 系统返回上传成功信息，完成该用例。
    

### 状态变化说明

- 新建监测记录
    
- `status：NULL → 'pending'`
    

---

# 2️⃣ 鲁棒图说明二

## Recheck Monitoring Record（生态监测员复查待核实数据）

### 用例说明

本鲁棒图描述了生态监测员对系统标记为待核实（pending）的监测记录进行业务复查的过程。该用例用于对原始监测数据进行补充、修正或确认，以提高数据的真实性和完整性。

### 参与对象说明

- **Actor：Ecological Monitor**  
    生态监测员，对原始采集数据负责，执行业务层面的复查操作。
    
- **Boundary：Pending Monitoring Record List**  
    待核实监测记录列表界面，用于展示状态为 `pending` 的监测记录。
    
- **Boundary：Monitoring Record Recheck Form**  
    监测记录复查表单，用于查看并修改具体监测记录内容。
    
- **Controller：Recheck Monitoring Record Controller**  
    复查控制器，负责加载待核实记录并更新复查结果。
    
- **Entity：Monitoring Record**  
    监测记录实体。
    

### 业务流程说明

1. 生态监测员进入待核实监测记录列表，选择一条记录进行复查。
    
2. 系统通过复查控制器从监测记录实体中加载对应记录信息。
    
3. 生态监测员在复查表单中对监测内容进行补充或修正。
    
4. 提交复查结果后，控制器更新监测记录数据。
    
5. 系统将该记录状态更新为 `status = 'rechecked'`，表示已完成业务复核，等待专家终审。
    

### 状态变化说明

- `status：'pending' → 'rechecked'`
    

---

# 3️⃣ 鲁棒图说明三

## Review and Validate Monitoring Record（数据分析师终审数据）

### 用例说明

本鲁棒图描述了数据分析师对已复查监测记录进行最终审核确认的过程。该用例用于从专业和科学角度对监测数据进行终审，决定其是否可以作为有效数据参与统计分析与决策支持。

### 参与对象说明

- **Actor：Data Analyst**  
    数据分析师，负责对复查后的监测数据进行最终审核。
    
- **Boundary：Rechecked Monitoring Record List**  
    已复查监测记录列表界面，用于展示状态为 `rechecked` 的监测记录。
    
- **Boundary：Monitoring Record Valid Form**  
    监测记录审核界面，用于查看监测记录详情并执行审核操作。
    
- **Controller：Valid Monitoring Record Controller**  
    审核控制器，负责处理审核操作并更新记录状态。
    
- **Entity：Monitoring Record**  
    监测记录实体。
    

### 业务流程说明

1. 数据分析师进入已复查监测记录列表，选择需要审核的记录。
    
2. 系统通过审核控制器加载对应的监测记录信息。
    
3. 数据分析师对监测数据进行专业审核，确认其科学合理性。
    
4. 审核通过后，控制器更新监测记录状态。
    
5. 系统返回审核成功信息，完成终审流程。
    

### 状态变化说明

- `status：'rechecked' → 'valid'`
    

---

## 总结一句

> The three robustness diagrams clearly separate data creation, business recheck, and expert validation processes, ensuring clear responsibility boundaries and consistent monitoring record state transitions.
