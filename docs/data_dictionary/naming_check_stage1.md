1.longitude 经度
重复表格：Visitor Trajectory、MonitoringRecord、Video_Monitor_Point
修改:1.将Visitor Trajectory表中的数据类型修改为DECIMAL(10,6)

2.latitude 纬度
重复表格：Visitor Trajectory、MonitoringRecord、Video_Monitor_Point
修改：1.将Visitor Trajectory表中的数据类型修改为DECIMAL(10,6)

3.所有的数据类型我都重新统一生成了一下，按照我生成的数据类型写表格，不要再看自己之前的了。

4.生成了全局表（User、Region、MonitoringDevice）的外键均按约定格式标注关联关系（如FK → Region(region_id), NULL）。
注意：之前的表因为合并有时候会出错，所以写表格完全对照着数据字典完成就好，不要忽略给一些跟全局数据项关联的数据项加外键。