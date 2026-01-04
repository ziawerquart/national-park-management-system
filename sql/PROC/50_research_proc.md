# 科研支撑模块存储过程说明

## sp_check_project_completion - 项目结题检查

**适用范围：** 在项目申请结题前，检查是否满足结题条件（必须有采集记录和成果产出）。

**参数：**
- `p_project_id` (IN): 项目ID
- `p_can_complete` (OUT): 是否可以结题
- `p_message` (OUT): 检查结果说明

**调用示例：**
```sql
CALL sp_check_project_completion('P001', @can, @msg);
SELECT @can, @msg;
```

**使用场景：**
- 项目结题审批流程
- 项目状态变更前置校验

---

## sp_export_results_by_access - 按访问级别导出成果清单

**适用范围：** 根据指定的访问级别（Public/Internal/Restricted）导出成果列表，包含项目和负责人信息。

**参数：**
- `p_access_level` (IN): 访问级别

**调用示例：**
```sql
CALL sp_export_results_by_access('Public');
```

**使用场景：**
- 公开成果展示页面
- 内部成果汇总报告
- 数据共享审计
