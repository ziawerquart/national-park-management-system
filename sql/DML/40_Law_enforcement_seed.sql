SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
USE national_park_db;

-- =====================================================
-- Step 1: Insert Base Master Data (外键依赖源头表)
-- 执行顺序：Region → User → MonitoringDevice (必须在前)
-- =====================================================
-- 1. Region (区域表) | 对应REG001-REG010，与VideoMonitorPoint关联
INSERT INTO Region (region_id, region_name, region_type)
VALUES
('REG001', 'Core Reserve Area A', 'Core'),
('REG002', 'Buffer Zone B', 'Buffer'),
('REG003', 'Experimental Area C', 'Experimental'),
('REG004', 'Core Reserve Area D', 'Core'),
('REG005', 'Buffer Zone E', 'Buffer'),
('REG006', 'Core Reserve Area F', 'Core'),
('REG007', 'Buffer Zone G', 'Buffer'),
('REG008', 'Experimental Area H', 'Experimental'),
('REG009', 'Core Reserve Area I', 'Core'),
('REG010', 'Buffer Zone J', 'Buffer');

-- 2. User (用户表) | 对应USER001-USER021，与LawEnforcementOfficer关联
INSERT INTO User (user_id, user_name, role)
VALUES
('USER001', 'Zhang Wei', 'LawEnforcer'),
('USER002', 'Li Na', 'LawEnforcer'),
('USER003', 'Wang Qiang', 'LawEnforcer'),
('USER004', 'Zhao Jing', 'LawEnforcer'),
('USER005', 'Chen Ming', 'LawEnforcer'),
('USER006', 'Yang Li', 'LawEnforcer'),
('USER007', 'Liu Yong', 'LawEnforcer'),
('USER008', 'Huang Min', 'LawEnforcer'),
('USER009', 'Zhou Jie', 'LawEnforcer'),
('USER010', 'Wu Fang', 'LawEnforcer'),
('USER011', 'Zheng Tao', 'LawEnforcer'),
('USER012', 'Sun Li', 'LawEnforcer'),
('USER013', 'Ma Ming', 'LawEnforcer'),
('USER014', 'Zhu Lin', 'LawEnforcer'),
('USER015', 'Hu Gang', 'LawEnforcer'),
('USER016', 'Lin Qiao', 'LawEnforcer'),
('USER017', 'Gao Wei', 'LawEnforcer'),
('USER018', 'Luo Ting', 'LawEnforcer'),
('USER019', 'Tian Yu', 'LawEnforcer'),
('USER020', 'Xie Min', 'LawEnforcer'),
('USER021', 'Han Jun', 'LawEnforcer');

-- 3. MonitoringDevice (监测设备表) | 对应DEV001-DEV021，与LawEnforcementOfficer关联
INSERT INTO MonitoringDevice (device_id, device_type, install_time, calibration_cycle, run_status, communication_protocol, region_id)
VALUES
('DEV001', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG001'),
('DEV002', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG002'),
('DEV003', 'Law Enforcement Recorder', NOW(), 30, 'fault', '4G', 'REG003'),
('DEV004', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG004'),
('DEV005', 'Law Enforcement Recorder', NOW(), 30, 'offline', '4G', 'REG005'),
('DEV006', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG001'),
('DEV007', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG002'),
('DEV008', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG003'),
('DEV009', 'Law Enforcement Recorder', NOW(), 30, 'fault', '4G', 'REG004'),
('DEV010', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG005'),
('DEV011', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG006'),
('DEV012', 'Law Enforcement Recorder', NOW(), 30, 'offline', '4G', 'REG007'),
('DEV013', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG008'),
('DEV014', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG009'),
('DEV015', 'Law Enforcement Recorder', NOW(), 30, 'fault', '4G', 'REG010'),
('DEV016', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG001'),
('DEV017', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG002'),
('DEV018', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG003'),
('DEV019', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG004'),
('DEV020', 'Law Enforcement Recorder', NOW(), 30, 'offline', '4G', 'REG005'),
('DEV021', 'Law Enforcement Recorder', NOW(), 30, 'normal', '4G', 'REG006');

-- =====================================================
-- Step 2: Insert Business Data (业务表，依赖前置主表)
-- 执行顺序：LawEnforcementOfficer → VideoMonitorPoint → IllegalBehaviorRecord → LawEnforcementDispatch
-- =====================================================
-- 1. Law Enforcement Officer Table (21 rows) | 执法人员表
INSERT INTO LawEnforcementOfficer (law_id, name, department, authority, contact, device_id, user_id)
VALUES
('LEO001', 'Zhang Wei', 'Forest Police Branch', 'Level 1 Law Enforcement', '13800138001', 'DEV001', 'USER001'),
('LEO002', 'Li Na', 'Ecological Law Enforcement Brigade', 'Level 2 Law Enforcement', '13800138002', 'DEV002', 'USER002'),
('LEO003', 'Wang Qiang', 'Protected Area Law Enforcement Section', 'Level 1 Law Enforcement', '13800138003', 'DEV003', 'USER003'),
('LEO004', 'Zhao Jing', 'Forest Police Branch', 'Level 3 Law Enforcement', '13800138004', 'DEV004', 'USER004'),
('LEO005', 'Chen Ming', 'Ecological Law Enforcement Brigade', 'Level 2 Law Enforcement', '13800138005', 'DEV005', 'USER005'),
('LEO006', 'Yang Li', 'Protected Area Law Enforcement Section', 'Level 1 Law Enforcement', '13800138006', 'DEV006', 'USER006'),
('LEO007', 'Liu Yong', 'Forest Police Branch', 'Level 3 Law Enforcement', '13800138007', 'DEV007', 'USER007'),
('LEO008', 'Huang Min', 'Ecological Law Enforcement Brigade', 'Level 2 Law Enforcement', '13800138008', 'DEV008', 'USER008'),
('LEO009', 'Zhou Jie', 'Protected Area Law Enforcement Section', 'Level 1 Law Enforcement', '13800138009', 'DEV009', 'USER009'),
('LEO010', 'Wu Fang', 'Forest Police Branch', 'Level 3 Law Enforcement', '13800138010', 'DEV010', 'USER010'),
('LEO011', 'Zheng Tao', 'Ecological Law Enforcement Brigade', 'Level 2 Law Enforcement', '13800138011', 'DEV011', 'USER011'),
('LEO012', 'Sun Li', 'Protected Area Law Enforcement Section', 'Level 1 Law Enforcement', '13800138012', 'DEV012', 'USER012'),
('LEO013', 'Ma Ming', 'Forest Police Branch', 'Level 3 Law Enforcement', '13800138013', 'DEV013', 'USER013'),
('LEO014', 'Zhu Lin', 'Ecological Law Enforcement Brigade', 'Level 2 Law Enforcement', '13800138014', 'DEV014', 'USER014'),
('LEO015', 'Hu Gang', 'Protected Area Law Enforcement Section', 'Level 1 Law Enforcement', '13800138015', 'DEV015', 'USER015'),
('LEO016', 'Lin Qiao', 'Forest Police Branch', 'Level 3 Law Enforcement', '13800138016', 'DEV016', 'USER016'),
('LEO017', 'Gao Wei', 'Ecological Law Enforcement Brigade', 'Level 2 Law Enforcement', '13800138017', 'DEV017', 'USER017'),
('LEO018', 'Luo Ting', 'Protected Area Law Enforcement Section', 'Level 1 Law Enforcement', '13800138018', 'DEV018', 'USER018'),
('LEO019', 'Tian Yu', 'Forest Police Branch', 'Level 3 Law Enforcement', '13800138019', 'DEV019', 'USER019'),
('LEO020', 'Xie Min', 'Ecological Law Enforcement Brigade', 'Level 2 Law Enforcement', '13800138020', 'DEV020', 'USER020'),
('LEO021', 'Han Jun', 'Protected Area Law Enforcement Section', 'Level 1 Law Enforcement', '13800138021', 'DEV021', 'USER021');

-- 2. Video Monitor Point Table (25 rows) | 视频监控点表 ✅ device_status 改为小写
INSERT INTO VideoMonitorPoint (monitor_id, region_id, latitude, longitude, monitor_range, device_status, storage_cycle)
VALUES
('VMP001', 'REG001', 30.678234, 103.845678, 'Core Reserve Area A', 'normal', 90),
('VMP002', 'REG002', 30.712345, 103.912345, 'Buffer Zone B', 'normal', 60),
('VMP003', 'REG003', 30.654321, 103.876543, 'Experimental Area C', 'fault', 90),
('VMP004', 'REG004', 30.734567, 103.934567, 'Core Reserve Area D', 'normal', 60),
('VMP005', 'REG005', 30.698765, 103.898765, 'Buffer Zone E', 'offline', 90),
('VMP006', 'REG001', 30.687654, 103.856789, 'Core Reserve Area A2', 'normal', 60),
('VMP007', 'REG002', 30.723456, 103.923456, 'Buffer Zone B2', 'normal', 90),
('VMP008', 'REG003', 30.643210, 103.865432, 'Experimental Area C2', 'normal', 60),
('VMP009', 'REG004', 30.745678, 103.945678, 'Core Reserve Area D2', 'fault', 90),
('VMP010', 'REG005', 30.687543, 103.887654, 'Buffer Zone E2', 'normal', 60),
('VMP011', 'REG006', 30.701234, 103.901234, 'Core Reserve Area F', 'normal', 90),
('VMP012', 'REG007', 30.665432, 103.854321, 'Buffer Zone G', 'offline', 60),
('VMP013', 'REG008', 30.713456, 103.913456, 'Experimental Area H', 'normal', 90),
('VMP014', 'REG009', 30.676543, 103.875432, 'Core Reserve Area I', 'normal', 60),
('VMP015', 'REG010', 30.724567, 103.924567, 'Buffer Zone J', 'fault', 90),
('VMP016', 'REG001', 30.691234, 103.861234, 'Core Reserve Area A3', 'normal', 60),
('VMP017', 'REG002', 30.731234, 103.931234, 'Buffer Zone B3', 'normal', 90),
('VMP018', 'REG003', 30.651234, 103.881234, 'Experimental Area C3', 'normal', 60),
('VMP019', 'REG004', 30.751234, 103.951234, 'Core Reserve Area D3', 'normal', 90),
('VMP020', 'REG005', 30.671234, 103.891234, 'Buffer Zone E3', 'offline', 60),
('VMP021', 'REG006', 30.705678, 103.905678, 'Core Reserve Area F2', 'normal', 90),
('VMP022', 'REG007', 30.661234, 103.841234, 'Buffer Zone G2', 'normal', 60),
('VMP023', 'REG008', 30.717890, 103.917890, 'Experimental Area H2', 'fault', 90),
('VMP024', 'REG009', 30.681234, 103.867890, 'Core Reserve Area I2', 'normal', 60),
('VMP025', 'REG010', 30.728901, 103.928901, 'Buffer Zone J2', 'normal', 90);

-- 3. Illegal Behavior Record Table (30 rows) | 违规行为记录表 ✅ process_status 改为小写
INSERT INTO IllegalBehaviorRecord (record_id, behavior_type, occur_time, region_id, monitor_id, evidence_path, process_status, law_id, process_result, punishment_basis)
VALUES
('IBR001', 'Illegal Hunting', '2024-01-15 08:32:10', 'REG001', 'VMP001', '/evidence/20240115/ibr001.mp4', 'unprocessed', 'LEO001', '', 'Article 20 of the Wildlife Protection Law'),
('IBR002', 'Illegal Camping', '2024-01-20 19:45:33', 'REG002', 'VMP002', '/evidence/20240120/ibr002.jpg', 'processing', 'LEO002', 'Interview and Education Completed', 'Article 27 of the Nature Reserve Regulations'),
('IBR003', 'Illegal Felling', '2024-02-05 10:12:45', 'REG003', 'VMP003', '/evidence/20240205/ibr003.mp4', 'closed', 'LEO003', 'Fined 5000 Yuan', 'Article 39 of the Forest Law'),
('IBR004', 'Littering', '2024-02-12 14:28:17', 'REG004', 'VMP004', '/evidence/20240212/ibr004.jpg', 'unprocessed', 'LEO004', '', 'Article 60 of the Environmental Protection Law'),
('IBR005', 'Illegal Fire Use', '2024-02-20 16:55:22', 'REG005', 'VMP005', '/evidence/20240220/ibr005.mp4', 'processing', 'LEO005', 'Hidden Danger Eliminated', 'Article 25 of the Forest Fire Prevention Regulations'),
('IBR006', 'Illegal Fishing', '2024-03-03 07:40:19', 'REG001', 'VMP006', '/evidence/20240303/ibr006.jpg', 'closed', 'LEO006', 'Tools Confiscated + Fined 3000 Yuan', 'Article 30 of the Fisheries Law'),
('IBR007', 'Cross-border Entry into Core Area', '2024-03-10 09:15:38', 'REG002', 'VMP007', '/evidence/20240310/ibr007.mp4', 'unprocessed', 'LEO007', '', 'Article 23 of the Nature Reserve Regulations'),
('IBR008', 'Vegetation Destruction', '2024-03-18 11:22:49', 'REG003', 'VMP008', '/evidence/20240318/ibr008.jpg', 'processing', 'LEO008', 'Ordered to Restore', 'Article 64 of the Environmental Protection Law'),
('IBR009', 'Illegal Mining', '2024-04-02 13:35:12', 'REG004', 'VMP009', '/evidence/20240402/ibr009.mp4', 'closed', 'LEO009', 'Fined 10000 Yuan', 'Article 39 of the Mineral Resources Law'),
('IBR010', 'Illegal Shooting', '2024-04-10 15:48:27', 'REG005', 'VMP010', '/evidence/20240410/ibr010.jpg', 'unprocessed', 'LEO010', '', 'Article 28 of the Nature Reserve Regulations'),
('IBR011', 'Illegal Grazing', '2024-04-18 08:12:33', 'REG006', 'VMP011', '/evidence/20240418/ibr011.mp4', 'processing', 'LEO011', 'Livestock Driven Away', 'Article 49 of the Grassland Law'),
('IBR012', 'Illegal Angling', '2024-05-02 10:55:47', 'REG007', 'VMP012', '/evidence/20240502/ibr012.jpg', 'closed', 'LEO012', 'Fishing Gear Confiscated + Fined 500 Yuan', 'Article 31 of the Fisheries Law'),
('IBR013', 'Monitoring Equipment Damage', '2024-05-10 14:22:19', 'REG008', 'VMP013', '/evidence/20240510/ibr013.mp4', 'unprocessed', 'LEO013', '', 'Article 49 of the Public Security Administration Punishment Law'),
('IBR014', 'Illegal Specimen Collection', '2024-05-18 16:38:52', 'REG009', 'VMP014', '/evidence/20240518/ibr014.jpg', 'processing', 'LEO014', 'Specimens Confiscated', 'Article 23 of the Wild Plant Protection Regulations'),
('IBR015', 'Illegal Driving', '2024-06-02 09:45:16', 'REG010', 'VMP015', '/evidence/20240602/ibr015.mp4', 'closed', 'LEO015', 'Fined 2000 Yuan', 'Article 90 of the Road Traffic Safety Law'),
('IBR016', 'Illegal Incineration', '2024-06-10 11:28:34', 'REG001', 'VMP016', '/evidence/20240610/ibr016.jpg', 'unprocessed', 'LEO016', '', 'Article 119 of the Air Pollution Prevention and Control Law'),
('IBR017', 'Cross-border Camping', '2024-06-18 19:35:48', 'REG002', 'VMP017', '/evidence/20240618/ibr017.mp4', 'processing', 'LEO017', 'Persuaded to Leave', 'Article 27 of the Nature Reserve Regulations'),
('IBR018', 'Illegal Fishing', '2024-07-02 07:22:11', 'REG003', 'VMP018', '/evidence/20240702/ibr018.jpg', 'closed', 'LEO018', 'Fined 4000 Yuan', 'Article 30 of the Fisheries Law'),
('IBR019', 'Hazardous Waste Littering', '2024-07-10 14:55:37', 'REG004', 'VMP019', '/evidence/20240710/ibr019.mp4', 'unprocessed', 'LEO019', '', 'Article 117 of the Solid Waste Pollution Prevention and Control Law'),
('IBR020', 'Illegal Fire Use', '2024-07-18 16:12:49', 'REG005', 'VMP020', '/evidence/20240718/ibr020.jpg', 'processing', 'LEO020', 'Punished and Educated', 'Article 25 of the Forest Fire Prevention Regulations'),
('IBR021', 'Illegal Hunting', '2024-08-02 08:55:23', 'REG006', 'VMP021', '/evidence/20240802/ibr021.mp4', 'closed', 'LEO001', 'Fined 8000 Yuan', 'Article 20 of the Wildlife Protection Law'),
('IBR022', 'Vegetation Destruction', '2024-08-10 10:32:18', 'REG007', 'VMP022', '/evidence/20240810/ibr022.jpg', 'unprocessed', 'LEO002', '', 'Article 64 of the Environmental Protection Law'),
('IBR023', 'Illegal Entry into Core Area', '2024-08-18 09:48:35', 'REG008', 'VMP023', '/evidence/20240818/ibr023.mp4', 'processing', 'LEO003', 'Interview Completed', 'Article 23 of the Nature Reserve Regulations'),
('IBR024', 'Illegal Felling', '2024-09-02 13:15:42', 'REG009', 'VMP024', '/evidence/20240902/ibr024.jpg', 'closed', 'LEO004', 'Fined 6000 Yuan', 'Article 39 of the Forest Law'),
('IBR025', 'Littering', '2024-09-10 15:28:57', 'REG010', 'VMP025', '/evidence/20240910/ibr025.mp4', 'unprocessed', 'LEO005', '', 'Article 60 of the Environmental Protection Law'),
('IBR026', 'Illegal Shooting', '2024-09-18 14:12:33', 'REG001', 'VMP001', '/evidence/20240918/ibr026.jpg', 'processing', 'LEO006', 'Stopped in Time', 'Article 28 of the Nature Reserve Regulations'),
('IBR027', 'Illegal Collection', '2024-10-02 11:45:19', 'REG002', 'VMP002', '/evidence/20241002/ibr027.mp4', 'closed', 'LEO007', 'Collected Items Confiscated', 'Article 23 of the Wild Plant Protection Regulations'),
('IBR028', 'Illegal Driving', '2024-10-10 09:22:48', 'REG003', 'VMP003', '/evidence/20241010/ibr028.jpg', 'unprocessed', 'LEO008', '', 'Article 90 of the Road Traffic Safety Law'),
('IBR029', 'Illegal Incineration', '2024-10-18 16:38:25', 'REG004', 'VMP004', '/evidence/20241018/ibr029.mp4', 'processing', 'LEO009', 'Fire Extinguished', 'Article 119 of the Air Pollution Prevention and Control Law'),
('IBR030', 'Cross-border Grazing', '2024-10-25 08:15:36', 'REG005', 'VMP005', '/evidence/20241025/ibr030.jpg', 'closed', 'LEO010', 'Driven Away + Fined 1000 Yuan', 'Article 49 of the Grassland Law');

-- 4. Law Enforcement Dispatch Table (30 rows) | 执法调度表 ✅ dispatch_status 为小写合规值
INSERT INTO LawEnforcementDispatch (dispatch_id, record_id, law_id, dispatch_time, response_time, finish_time, dispatch_status)
VALUES
('LED001', 'IBR001', 'LEO001', '2024-01-15 08:40:10', '2024-01-15 09:15:33', NULL, 'pending'),
('LED002', 'IBR002', 'LEO002', '2024-01-20 20:00:33', '2024-01-20 20:30:17', '2024-01-20 21:45:22', 'dispatched'),
('LED003', 'IBR003', 'LEO003', '2024-02-05 10:20:45', '2024-02-05 10:50:28', '2024-02-05 12:30:49', 'completed'),
('LED004', 'IBR004', 'LEO004', '2024-02-12 14:35:17', '2024-02-12 15:10:42', NULL, 'pending'),
('LED005', 'IBR005', 'LEO005', '2024-02-20 17:10:22', '2024-02-20 17:45:38', '2024-02-20 18:30:55', 'dispatched'),
('LED006', 'IBR006', 'LEO006', '2024-03-03 07:50:19', '2024-03-03 08:25:44', '2024-03-03 09:40:12', 'completed'),
('LED007', 'IBR007', 'LEO007', '2024-03-10 09:25:38', '2024-03-10 10:00:53', NULL, 'pending'),
('LED008', 'IBR008', 'LEO008', '2024-03-18 11:30:49', '2024-03-18 12:05:14', '2024-03-18 13:20:37', 'dispatched'),
('LED009', 'IBR009', 'LEO009', '2024-04-02 13:45:12', '2024-04-02 14:20:38', '2024-04-02 15:50:22', 'completed'),
('LED010', 'IBR010', 'LEO010', '2024-04-10 15:58:27', '2024-04-10 16:35:11', NULL, 'pending'),
('LED011', 'IBR011', 'LEO011', '2024-04-18 08:20:33', '2024-04-18 08:55:47', '2024-04-18 10:15:32', 'dispatched'),
('LED012', 'IBR012', 'LEO012', '2024-05-02 11:05:47', '2024-05-02 11:40:12', '2024-05-02 12:30:58', 'completed'),
('LED013', 'IBR013', 'LEO013', '2024-05-10 14:30:19', '2024-05-10 15:05:34', NULL, 'pending'),
('LED014', 'IBR014', 'LEO014', '2024-05-18 16:48:52', '2024-05-18 17:25:17', '2024-05-18 18:40:23', 'dispatched'),
('LED015', 'IBR015', 'LEO015', '2024-06-02 09:55:16', '2024-06-02 10:30:41', '2024-06-02 11:50:37', 'completed'),
('LED016', 'IBR016', 'LEO016', '2024-06-10 11:38:34', '2024-06-10 12:15:28', NULL, 'pending'),
('LED017', 'IBR017', 'LEO017', '2024-06-18 19:45:48', '2024-06-18 20:20:13', '2024-06-18 21:30:49', 'dispatched'),
('LED018', 'IBR018', 'LEO018', '2024-07-02 07:32:11', '2024-07-02 08:05:36', '2024-07-02 09:20:15', 'completed'),
('LED019', 'IBR019', 'LEO019', '2024-07-10 15:05:37', '2024-07-10 15:40:22', NULL, 'pending'),
('LED020', 'IBR020', 'LEO020', '2024-07-18 16:22:49', '2024-07-18 16:55:14', '2024-07-18 17:40:38', 'dispatched'),
('LED021', 'IBR021', 'LEO001', '2024-08-02 09:05:23', '2024-08-02 09:40:48', '2024-08-02 11:10:25', 'completed'),
('LED022', 'IBR022', 'LEO002', '2024-08-10 10:42:18', '2024-08-10 11:15:33', NULL, 'pending'),
('LED023', 'IBR023', 'LEO003', '2024-08-18 09:58:35', '2024-08-18 10:30:59', '2024-08-18 11:45:17', 'dispatched'),
('LED024', 'IBR024', 'LEO004', '2024-09-02 13:25:42', '2024-09-02 14:00:16', '2024-09-02 15:20:43', 'completed'),
('LED025', 'IBR025', 'LEO005', '2024-09-10 15:38:57', '2024-09-10 16:10:32', NULL, 'pending'),
('LED026', 'IBR026', 'LEO006', '2024-09-18 14:22:33', '2024-09-18 14:55:18', '2024-09-18 15:40:29', 'dispatched'),
('LED027', 'IBR027', 'LEO007', '2024-10-02 11:55:19', '2024-10-02 12:30:44', '2024-10-02 13:50:16', 'completed'),
('LED028', 'IBR028', 'LEO008', '2024-10-10 09:32:48', '2024-10-10 10:05:23', NULL, 'pending'),
('LED029', 'IBR029', 'LEO009', '2024-10-18 16:48:25', '2024-10-18 17:20:50', '2024-10-18 18:30:34', 'dispatched'),
('LED030', 'IBR030', 'LEO010', '2024-10-25 08:25:36', '2024-10-25 09:00:11', '2024-10-25 10:15:47', 'completed');

SET FOREIGN_KEY_CHECKS = 1;