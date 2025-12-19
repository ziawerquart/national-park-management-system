
# 1️⃣ 鲁棒图说明一

## Submit Project Application（科研人员提交项目申请）

### 用例说明

本鲁棒图描述了科研人员通过系统提交科研项目申请，并在系统中生成科研项目信息的业务流程。该用例的核心目标是将科研项目的基础申请信息标准化录入系统，为后续数据采集与成果管理提供项目基础。

This robustness diagram describes the process by which a researcher submits a project application through the system and generates formal research project information. The core objective of this use case is to standardize the entry of project application data and establish the foundation for subsequent data collection and achievement management.

----------

### 参与对象说明（Participants）

-   **Actor：Researcher**  
    科研人员，作为系统的直接使用者，负责填写并提交科研项目申请信息。
    
-   **Boundary：Project Application Upload Interface**  
    项目申请上传界面，用于科研人员录入项目名称、研究方向、负责人信息等申请内容。
    
-   **Controller：Application Controller**  
    项目申请控制器，负责接收界面传入的申请信息，并协调科研项目信息的创建与存储。
    
-   **Entity：Research Project Information**  
    科研项目信息实体，对应数据库中的科研项目表，用于持久化存储项目基本信息。
    

----------

### 业务流程说明（Business Flow）

1.  科研人员通过项目申请上传界面提交项目申请信息。
    
2.  项目申请上传界面将申请数据传递给项目申请控制器。
    
3.  项目申请控制器对数据进行处理，并创建科研项目信息实体记录。
    
4.  系统返回“更新成功（update successfully）”提示，完成项目申请流程。
    

----------

### 状态变化说明（State Changes）

-   新建科研项目记录
    
-   项目初始状态设置为 `pending`（待审核）
    

----------

# 2️⃣ 鲁棒图说明二

## Enter / Retrieve Collected Data（科研人员录入或调用采集数据）

### 用例说明

本鲁棒图描述了科研人员在项目执行阶段录入或调用科研采集数据，并将采集数据与对应科研项目进行关联的业务流程。该用例的目标是形成结构化、可追溯的科研数据采集记录。

This robustness diagram illustrates the process in which researchers enter or retrieve collected research data during project execution and associate the data with the corresponding research project. The goal is to establish structured and traceable data collection records.

----------

### 参与对象说明（Participants）

-   **Actor：Researcher**  
    科研人员，负责输入或调用科研数据采集信息。
    
-   **Boundary：Data Collection Entry Interface**  
    数据采集录入界面，用于填写采集时间、采集内容、采集方式等信息，或检索已有采集数据。
    
-   **Controller：Data Collection Controller**  
    数据采集控制器，负责接收采集数据、校验项目信息并协调采集记录的创建。
    
-   **Entity：Research Data Collection Information**  
    科研数据采集信息实体，用于存储项目相关的数据采集记录。
    
-   **Entity：Research Project Information**  
    科研项目信息实体，用于与采集数据建立关联关系。
    

----------

### 业务流程说明（Business Flow）

1.  科研人员通过数据采集录入界面输入或查询采集数据。
    
2.  数据采集录入界面将采集信息传递给数据采集控制器。
    
3.  数据采集控制器根据项目编号关联对应的科研项目。
    
4.  系统创建科研数据采集记录并保存至数据库。
    
5.  系统返回“更新成功（update successfully）”提示，完成数据采集流程。
    

----------

### 状态变化说明（State Changes）

-   新建科研数据采集记录
    
-   采集数据与指定科研项目成功关联
    

----------

# 3️⃣ 鲁棒图说明三

## Submit Achievement Information（科研人员提交成果信息）

### 用例说明

本鲁棒图描述了科研人员在科研项目完成后提交科研成果信息，并由系统进行归档和管理的业务流程。该用例确保科研成果与项目之间的有效关联，实现成果的规范化存储与管理。

This robustness diagram describes the process by which researchers submit research achievements after project completion, and the system archives and manages these achievements. The use case ensures proper association between research projects and outcomes.

----------

### 参与对象说明（Participants）

-   **Actor：Researcher**  
    科研人员，负责提交科研成果信息。
    
-   **Boundary：Achievement Submission Interface**  
    成果提交界面，用于填写成果名称、成果类型、成果描述等信息。
    
-   **Controller：Achievement Archiving Controller**  
    成果归档控制器，负责接收成果数据、校验项目关联关系并协调成果存储。
    
-   **Entity：Research Achievement Information**  
    科研成果信息实体，用于保存科研项目产出的成果数据。
    
-   **Entity：Research Project Information**  
    科研项目信息实体，用于标识成果所属的科研项目。
    

----------

### 业务流程说明（Business Flow）

1.  科研人员通过成果提交界面提交成果信息。
    
2.  成果提交界面将成果数据传递给成果归档控制器。
    
3.  成果归档控制器关联对应的科研项目。
    
4.  系统创建科研成果信息记录并完成归档。
    
5.  系统返回“更新成功（update successfully）”提示，完成成果提交流程。
    

----------

### 状态变化说明（State Changes）

-   新建科研成果记录
    
-   成果信息与对应科研项目成功关联
    

----------

## 总结（Summary）

> These robustness diagrams describe the complete lifecycle of a research project, covering project application, data collection, and achievement submission. They clearly define the responsibilities of actors, boundary objects, controllers, and entities, ensuring a structured and maintainable system design.

----------
