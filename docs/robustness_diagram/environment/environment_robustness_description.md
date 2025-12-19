# 生态环境监测鲁棒图

该图展示了生态环境监测系统中数据流、设备信息及管理接口的概念关系：

## 主要元素及关系

1. **IoT Device**
   - 采集环境数据并提交给 **Collection Interface**。

2. **Collection Interface**
   - 接收设备上传的数据流，并传递给 **Data & Threshold Control**。

3. **Data & Threshold Control**
   - 对数据进行处理和阈值检测。
   - 检查 **Indicator Standards**（指标标准）。
   - 保存监测记录到 **Monitoring Record**。
   - 验证技术员操作的 ID。

4. **Technician**
   - 执行校准操作并通过 **Management Interface** 提交校准日志。

5. **Management Interface**
   - 将日志传递给 **Status & Calibration Monitor**。

6. **Status & Calibration Monitor**
   - 更新设备状态并更新校准信息到 **Device Info**。

7. **Device Info**
   - 存储设备信息并与 **Functional Zone**（功能区域）关联。

8. **Indicator Standards**
   - 与 **Monitoring Record** 通过 ID 建立关联，用于阈值检测。

## 说明

- 系统以 IoT 设备数据为中心，数据流经采集接口、阈值控制、设备状态监控等模块。
- 技术员和管理接口负责校准和设备状态更新。
- 每条监测数据会与指标标准关联以判断异常。
- 设备信息与功能区域绑定，用于管理和统计。
