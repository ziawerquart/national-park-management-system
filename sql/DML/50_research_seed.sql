-- ================================================================
-- 科研支撑模块 - 完整测试数据种子文件
-- 数据库: national_park_db
-- 基于: 99_all_in_one.sql 全局DDL + global_uml.puml
-- ================================================================

USE national_park_db;

SET FOREIGN_KEY_CHECKS = 0;


-- ================================================================
-- 1. 确保全局依赖数据存在
-- ================================================================

-- 1.1 Region表 - 区域数据（如果不存在则插入）
INSERT IGNORE INTO Region (region_id, region_name, region_type) VALUES
('R001', 'Wolong Core Zone', 'core_protection'),
('R002', 'Changbai Mountain Reserve', 'nature_reserve'),
('R003', 'Shennongjia Forestry District', 'forestry_district'),
('R004', 'Poyang Lake Wetland', 'wetland'),
('R005', 'Zhalong Wetland', 'wetland'),
('R006', 'Qinling Mountains North', 'mountain'),
('R007', 'Greater Khingan Range', 'forest'),
('R008', 'Xishuangbanna Rainforest', 'tropical_forest'),
('R009', 'Kekexili Reserve', 'plateau'),
('R010', 'Qinghai Lake Reserve', 'lake');

-- 1.2 User表 - 用户数据（如果不存在则插入）
INSERT IGNORE INTO User (user_id, user_name, role) VALUES
('U001', 'Dr. Zhang Wei', 'researcher'),
('U002', 'Dr. Li Na', 'researcher'),
('U003', 'Wang Qiang', 'data_analyst'),
('U004', 'Dr. Liu Min', 'researcher'),
('U005', 'Chen Jie', 'ecological_monitor'),
('U006', 'Dr. Zhao Li', 'researcher'),
('U007', 'Prof. Sun Hao', 'researcher'),
('U008', 'Zhou Ping', 'admin'),
('U009', 'Dr. Wu Tao', 'researcher'),
('U010', 'Zheng Hong', 'ecological_monitor'),
('U011', 'Dr. Feng Chao', 'researcher'),
('U012', 'Prof. Yu Jing', 'researcher'),
('U013', 'Ma Jun', 'ecological_monitor'),
('U014', 'Dr. Zhu Xue', 'researcher'),
('U015', 'Hu Ming', 'admin'),
('U016', 'Prof. Lin Fang', 'researcher'),
('U017', 'Dr. Luo Gang', 'researcher'),
('U018', 'Liang Yan', 'ecological_monitor'),
('U019', 'Prof. Song Lei', 'researcher'),
('U020', 'Dr. Tang Hui', 'researcher'),
('U021', 'Prof. Xu Jian', 'researcher'),
('U022', 'Fu Dan', 'ecological_monitor'),
('U023', 'Dr. Cao Yong', 'researcher'),
('U024', 'Dong Juan', 'admin'),
('U025', 'Dr. Yuan Feng', 'researcher');

-- ================================================================
-- 2. ResearchProject表 - 研究项目数据（25条）
-- 枚举: ongoing, completed, paused
-- ================================================================
INSERT INTO ResearchProject (project_id, project_name, leader_id, apply_organization, 
                             approval_date, completion_date, project_status, 
                             research_field, description) VALUES
('PRJ001', 'Giant Panda Habitat Monitoring', 'U001', 'Chinese Academy of Sciences', '2022-01-01', '2024-12-31', 'ongoing', 'Conservation Biology', 'Long-term monitoring of panda habitat and population'),
('PRJ002', 'Tiger Population Recovery Study', 'U002', 'Peking University', '2021-06-01', '2023-12-31', 'completed', 'Species Conservation', 'Assessment of tiger population recovery efforts'),
('PRJ003', 'Golden Monkey Behavioral Research', 'U004', 'China Forestry University', '2023-03-01', '2025-03-01', 'ongoing', 'Animal Behavior', 'Social behavior and group dynamics study'),
('PRJ004', 'Pere Davids Deer Rewilding Project', 'U006', 'Nanjing University', '2022-09-01', '2024-09-01', 'ongoing', 'Species Restoration', 'Rewilding and adaptation monitoring'),
('PRJ005', 'Red-crowned Crane Migration Study', 'U007', 'Northeast Forestry University', '2021-01-01', '2023-06-30', 'completed', 'Migration Ecology', 'Tracking migration routes and stopover sites'),
('PRJ006', 'Crested Ibis Breeding Ecology', 'U009', 'Shaanxi Normal University', '2023-01-01', '2025-12-31', 'ongoing', 'Breeding Biology', 'Breeding success factors analysis'),
('PRJ007', 'Musk Deer Captive Breeding Technology', 'U011', 'Sichuan Agricultural University', '2022-05-01', '2024-05-01', 'ongoing', 'Captive Breeding', 'Improving captive breeding techniques'),
('PRJ008', 'Black Bear Hibernation Mechanism', 'U014', 'Chinese Academy of Sciences', '2021-10-01', '2023-10-01', 'completed', 'Physiology', 'Physiological adaptations during hibernation'),
('PRJ009', 'Red Deer Population Dynamics', 'U016', 'Inner Mongolia University', '2023-06-01', '2025-06-01', 'ongoing', 'Population Ecology', 'Population size and structure monitoring'),
('PRJ010', 'Serow Habitat Assessment', 'U019', 'Yunnan University', '2022-03-01', '2024-03-01', 'ongoing', 'Habitat Management', 'Habitat quality evaluation'),
('PRJ011', 'Wolf Pack Social Structure', 'U020', 'Lanzhou University', '2021-08-01', '2023-08-01', 'completed', 'Social Behavior', 'Pack dynamics and hierarchy study'),
('PRJ012', 'Lynx Predation Strategy Analysis', 'U021', 'Jilin University', '2023-04-01', '2025-04-01', 'ongoing', 'Predation Ecology', 'Hunting behavior and prey selection'),
('PRJ013', 'White-naped Crane Wintering Protection', 'U023', 'Jiangxi Normal University', '2022-11-01', '2024-11-01', 'ongoing', 'Wintering Ecology', 'Wintering site conservation'),
('PRJ014', 'Black Stork Breeding Site Survey', 'U002', 'Hebei University', '2021-05-01', '2023-05-01', 'completed', 'Breeding Ecology', 'Breeding habitat characterization'),
('PRJ015', 'Golden Eagle Territory Behavior', 'U025', 'Xinjiang University', '2023-02-01', '2025-02-01', 'ongoing', 'Territory Ecology', 'Territory size and defense behavior'),
('PRJ016', 'Peregrine Falcon Hunting Techniques', 'U004', 'Qinghai University', '2022-07-01', '2024-07-01', 'ongoing', 'Predation Behavior', 'Hunting success rate analysis'),
('PRJ017', 'Eagle-Owl Breeding Success Rate', 'U006', 'Gansu Agricultural University', '2021-09-01', '2023-09-01', 'completed', 'Breeding Strategy', 'Factors affecting breeding success'),
('PRJ018', 'Ring-necked Pheasant Recovery', 'U007', 'Anhui University', '2023-05-01', '2025-05-01', 'ongoing', 'Population Recovery', 'Population restoration project'),
('PRJ019', 'Chinese Hare Distribution Survey', 'U009', 'South China Normal University', '2022-02-01', '2024-02-01', 'ongoing', 'Distribution Survey', 'Range and density mapping'),
('PRJ020', 'Red Squirrel Habitat Selection', 'U011', 'Fujian Agriculture Forestry Univ', '2021-11-01', '2023-11-01', 'completed', 'Habitat Selection', 'Microhabitat preferences study'),
('PRJ021', 'Muntjac Activity Pattern Research', 'U014', 'Zhejiang University', '2023-07-01', '2025-07-01', 'ongoing', 'Activity Pattern', 'Diel activity rhythm analysis'),
('PRJ022', 'Wild Boar Population Control', 'U016', 'Shandong Agricultural University', '2022-04-01', '2024-04-01', 'ongoing', 'Population Management', 'Population control strategies'),
('PRJ023', 'Sika Deer Migration Routes', 'U019', 'Liaoning University', '2021-12-01', '2023-12-01', 'completed', 'Migration Ecology', 'Seasonal movement patterns'),
('PRJ024', 'Alpine Musk Deer Conservation', 'U020', 'Tibet University', '2023-08-01', '2025-08-01', 'ongoing', 'Species Conservation', 'Conservation status assessment'),
('PRJ025', 'Takin Genetic Diversity', 'U021', 'Sichuan University', '2022-10-01', '2024-10-01', 'ongoing', 'Genetics', 'Genetic structure analysis');

-- ================================================================
-- 3. ResearchDataRecord表 - 数据采集记录（30条）
-- 枚举: field, system
-- ================================================================
INSERT INTO ResearchDataRecord (collection_id, project_id, collector_id, collection_time, 
                                region_id, collection_content, data_source, sample_id,
                                monitoring_data_id, data_file_path, remarks, 
                                is_verified, verified_by, verified_at) VALUES
('DC001', 'PRJ001', 'U005', '2022-03-15 09:00:00', 'R001', 'Camera trap deployment for panda activity', 'field', 'S001', NULL, '/data/dc001.zip', 'Initial deployment', TRUE, 'U001', '2022-03-20 10:00:00'),
('DC002', 'PRJ001', 'U005', '2022-06-20 14:30:00', 'R001', 'Vegetation survey recording bamboo distribution', 'field', 'S002', NULL, '/data/dc002.zip', 'Summer survey', TRUE, 'U001', '2022-06-25 09:00:00'),
('DC003', 'PRJ001', 'U010', '2023-01-10 10:00:00', 'R001', 'Snow tracking for population estimation', 'field', 'S003', NULL, '/data/dc003.zip', 'Winter tracking', TRUE, 'U001', '2023-01-15 11:00:00'),
('DC004', 'PRJ002', 'U010', '2021-08-15 08:00:00', 'R002', 'Drone aerial survey for habitat mapping', 'system', 'S004', NULL, '/data/dc004.zip', 'Aerial mapping', TRUE, 'U002', '2021-08-20 14:00:00'),
('DC005', 'PRJ002', 'U013', '2022-05-20 11:00:00', 'R002', 'Tiger scat collection for DNA analysis', 'field', 'S005', NULL, '/data/dc005.zip', 'DNA samples', TRUE, 'U002', '2022-05-25 10:00:00'),
('DC006', 'PRJ003', 'U013', '2023-04-10 09:30:00', 'R003', 'Golden monkey social behavior observation', 'field', 'S006', NULL, '/data/dc006.zip', 'Behavior records', TRUE, 'U004', '2023-04-15 09:00:00'),
('DC007', 'PRJ003', 'U018', '2023-07-15 15:00:00', 'R003', 'Vocalization recording for individual ID', 'field', 'S007', NULL, '/data/dc007.zip', 'Audio recordings', FALSE, NULL, NULL),
('DC008', 'PRJ004', 'U018', '2022-11-05 10:00:00', 'R004', 'GPS collar data download from deer', 'system', 'S008', NULL, '/data/dc008.zip', 'GPS data', TRUE, 'U006', '2022-11-10 11:00:00'),
('DC009', 'PRJ004', 'U022', '2023-02-20 08:30:00', 'R004', 'Health assessment of deer population', 'field', 'S009', NULL, '/data/dc009.zip', 'Health records', TRUE, 'U006', '2023-02-25 09:00:00'),
('DC010', 'PRJ005', 'U022', '2021-03-25 07:00:00', 'R005', 'Satellite tracking of crane migration', 'system', 'S010', NULL, '/data/dc010.zip', 'Migration data', TRUE, 'U007', '2021-03-30 10:00:00'),
('DC011', 'PRJ005', 'U005', '2022-10-10 16:00:00', 'R005', 'Wintering site environmental measurements', 'field', 'S011', NULL, '/data/dc011.zip', 'Environmental data', TRUE, 'U007', '2022-10-15 14:00:00'),
('DC012', 'PRJ006', 'U010', '2023-05-15 09:00:00', 'R006', 'Ibis nest monitoring video collection', 'field', 'S012', NULL, '/data/dc012.zip', 'Video records', FALSE, NULL, NULL),
('DC013', 'PRJ006', 'U013', '2023-08-20 14:00:00', 'R006', 'Chick growth data recording', 'field', 'S013', NULL, '/data/dc013.zip', 'Growth data', TRUE, 'U009', '2023-08-25 10:00:00'),
('DC014', 'PRJ007', 'U018', '2022-07-10 11:00:00', 'R001', 'Captive musk deer health records', 'system', 'S014', NULL, '/data/dc014.zip', 'Health records', TRUE, 'U011', '2022-07-15 09:00:00'),
('DC015', 'PRJ007', 'U022', '2023-03-05 10:30:00', 'R001', 'Musk secretion measurement', 'field', 'S015', NULL, '/data/dc015.zip', 'Musk data', TRUE, 'U011', '2023-03-10 11:00:00'),
('DC016', 'PRJ008', 'U005', '2021-12-15 09:00:00', 'R002', 'Bear hibernation den temperature monitoring', 'field', 'S016', NULL, '/data/dc016.zip', 'Temperature data', TRUE, 'U014', '2021-12-20 10:00:00'),
('DC017', 'PRJ008', 'U010', '2022-03-01 08:00:00', 'R002', 'Metabolic rate measurement during hibernation', 'field', 'S017', NULL, '/data/dc017.zip', 'Metabolic data', TRUE, 'U014', '2022-03-05 09:00:00'),
('DC018', 'PRJ009', 'U013', '2023-09-10 10:00:00', 'R007', 'Aerial census of red deer population', 'system', 'S018', NULL, '/data/dc018.zip', 'Census data', FALSE, NULL, NULL),
('DC019', 'PRJ009', 'U018', '2023-11-20 15:00:00', 'R007', 'Rutting behavior observation', 'field', 'S019', NULL, '/data/dc019.zip', 'Behavior records', TRUE, 'U016', '2023-11-25 14:00:00'),
('DC020', 'PRJ010', 'U022', '2022-05-25 09:30:00', 'R008', 'Serow habitat vegetation coverage', 'system', 'S020', NULL, '/data/dc020.zip', 'Vegetation data', TRUE, 'U019', '2022-05-30 10:00:00'),
('DC021', 'PRJ010', 'U005', '2023-01-15 11:00:00', 'R008', 'Diet analysis sample collection', 'field', 'S021', NULL, '/data/dc021.zip', 'Diet samples', TRUE, 'U019', '2023-01-20 09:00:00'),
('DC022', 'PRJ011', 'U010', '2021-10-20 08:00:00', 'R009', 'Wolf pack individual identification', 'field', 'S022', NULL, '/data/dc022.zip', 'ID records', TRUE, 'U020', '2021-10-25 10:00:00'),
('DC023', 'PRJ011', 'U013', '2022-04-15 14:00:00', 'R009', 'Predation behavior video recording', 'field', 'S023', NULL, '/data/dc023.zip', 'Video records', TRUE, 'U020', '2022-04-20 11:00:00'),
('DC024', 'PRJ012', 'U018', '2023-06-05 09:00:00', 'R002', 'Lynx camera trap data', 'field', 'S024', NULL, '/data/dc024.zip', 'Camera data', FALSE, NULL, NULL),
('DC025', 'PRJ012', 'U022', '2023-09-20 16:00:00', 'R002', 'Prey composition analysis', 'field', 'S025', NULL, '/data/dc025.zip', 'Prey data', TRUE, 'U021', '2023-09-25 14:00:00'),
('DC026', 'PRJ013', 'U005', '2022-12-10 10:00:00', 'R004', 'Crane wintering site water quality', 'field', 'S026', NULL, '/data/dc026.zip', 'Water quality', TRUE, 'U023', '2022-12-15 09:00:00'),
('DC027', 'PRJ013', 'U010', '2023-03-25 08:30:00', 'R004', 'Population census of wintering cranes', 'field', 'S027', NULL, '/data/dc027.zip', 'Census data', TRUE, 'U023', '2023-03-30 10:00:00'),
('DC028', 'PRJ014', 'U013', '2021-06-15 09:00:00', 'R006', 'Black stork breeding site survey', 'system', 'S028', NULL, '/data/dc028.zip', 'Survey data', TRUE, 'U002', '2021-06-20 11:00:00'),
('DC029', 'PRJ015', 'U018', '2023-04-20 10:30:00', 'R009', 'Golden eagle territory GPS mapping', 'system', 'S029', NULL, '/data/dc029.zip', 'GPS data', TRUE, 'U025', '2023-04-25 09:00:00'),
('DC030', 'PRJ016', 'U022', '2022-09-10 11:00:00', 'R010', 'Falcon hunting success rate observation', 'field', 'S030', NULL, '/data/dc030.zip', 'Observation data', TRUE, 'U004', '2022-09-15 10:00:00');

-- ================================================================
-- 4. ResearchAchievement表 - 研究成果（30条）
-- 枚举: paper, report, patent, other
-- 枚举: public, internal, confidential
-- ================================================================
INSERT INTO ResearchAchievement (achievement_id, project_id, achievement_type, 
                                  achievement_name, submit_time, file_path, share_permission) VALUES
('ACH001', 'PRJ001', 'paper', 'Giant Panda Habitat Selection and Bamboo Distribution', '2023-06-15', '/results/paper_001.pdf', 'public'),
('ACH002', 'PRJ001', 'report', 'Wolong Reserve Panda Population Monitoring Annual Report', '2023-12-20', '/results/report_001.pdf', 'internal'),
('ACH003', 'PRJ001', 'other', 'Giant Panda Activity Image Database 2022-2023', '2023-08-10', '/results/data_001.zip', 'confidential'),
('ACH004', 'PRJ002', 'paper', 'Genetic Diversity Assessment of South China Tigers', '2023-05-20', '/results/paper_002.pdf', 'public'),
('ACH005', 'PRJ002', 'report', 'Tiger Population Recovery Feasibility Study', '2023-11-30', '/results/report_002.pdf', 'internal'),
('ACH006', 'PRJ003', 'paper', 'Golden Monkey Social Structure and Behavior Patterns', '2024-01-15', '/results/paper_003.pdf', 'public'),
('ACH007', 'PRJ003', 'other', 'Golden Monkey Vocalization Database', '2023-09-25', '/results/data_003.zip', 'internal'),
('ACH008', 'PRJ004', 'report', 'Pere Davids Deer Rewilding Effectiveness Assessment', '2023-07-10', '/results/report_004.pdf', 'internal'),
('ACH009', 'PRJ004', 'paper', 'Migration Routes and Habitat Use of Pere Davids Deer', '2023-10-05', '/results/paper_004.pdf', 'public'),
('ACH010', 'PRJ005', 'paper', 'East Asian Flyway of Red-crowned Cranes', '2023-04-20', '/results/paper_005.pdf', 'public'),
('ACH011', 'PRJ005', 'other', 'Crane Satellite Tracking Data 2021-2023', '2023-08-15', '/results/data_005.zip', 'public'),
('ACH012', 'PRJ006', 'paper', 'Factors Affecting Crested Ibis Breeding Success', '2024-02-10', '/results/paper_006.pdf', 'public'),
('ACH013', 'PRJ006', 'report', 'Crested Ibis Population Recovery Progress Report', '2023-12-05', '/results/report_006.pdf', 'internal'),
('ACH014', 'PRJ007', 'paper', 'Optimization of Musk Deer Captive Breeding Technology', '2023-09-15', '/results/paper_007.pdf', 'public'),
('ACH015', 'PRJ007', 'patent', 'Efficient Musk Collection Device for Musk Deer', '2023-11-20', '/results/patent_007.pdf', 'confidential'),
('ACH016', 'PRJ008', 'paper', 'Physiological Adaptations During Black Bear Hibernation', '2023-06-30', '/results/paper_008.pdf', 'public'),
('ACH017', 'PRJ008', 'other', 'Black Bear Hibernation Monitoring Data 2021-2023', '2023-10-25', '/results/data_008.zip', 'internal'),
('ACH018', 'PRJ009', 'report', 'Red Deer Population Dynamics Monitoring Report', '2024-01-20', '/results/report_009.pdf', 'internal'),
('ACH019', 'PRJ010', 'paper', 'Serow Habitat Quality Evaluation Index System', '2023-08-05', '/results/paper_010.pdf', 'public'),
('ACH020', 'PRJ011', 'paper', 'Cooperative Hunting Strategies in Gray Wolf Packs', '2023-03-15', '/results/paper_011.pdf', 'public'),
('ACH021', 'PRJ011', 'other', 'Wolf Predation Behavior Video Library', '2023-07-20', '/results/data_011.zip', 'internal'),
('ACH022', 'PRJ012', 'paper', 'Spatiotemporal Patterns of Lynx Predation Behavior', '2024-02-25', '/results/paper_012.pdf', 'public'),
('ACH023', 'PRJ013', 'report', 'White-naped Crane Wintering Site Protection Recommendations', '2023-12-15', '/results/report_013.pdf', 'internal'),
('ACH024', 'PRJ014', 'paper', 'Breeding Habitat Characteristics of Black Storks', '2023-09-10', '/results/paper_014.pdf', 'public'),
('ACH025', 'PRJ015', 'paper', 'Territory Defense Behavior in Golden Eagles', '2024-03-05', '/results/paper_015.pdf', 'public'),
('ACH026', 'PRJ016', 'report', 'Peregrine Falcon Hunting Technique Analysis', '2023-11-10', '/results/report_016.pdf', 'internal'),
('ACH027', 'PRJ017', 'paper', 'Eagle-Owl Breeding Success and Environmental Factors', '2023-08-25', '/results/paper_017.pdf', 'public'),
('ACH028', 'PRJ018', 'report', 'Ring-necked Pheasant Recovery Project Progress', '2024-01-30', '/results/report_018.pdf', 'internal'),
('ACH029', 'PRJ019', 'other', 'Chinese Hare Distribution Survey Data', '2023-10-15', '/results/data_019.zip', 'public'),
('ACH030', 'PRJ020', 'paper', 'Red Squirrel Habitat Selection Preferences', '2023-07-05', '/results/paper_020.pdf', 'public');

-- ================================================================
-- 恢复外键检查
-- ================================================================
SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- 数据插入统计
-- ================================================================
SELECT '=== Research Module Data Insertion Completed ===' AS Status;

SELECT 'Region' AS TableName, COUNT(*) AS RecordCount FROM Region
UNION ALL
SELECT 'User', COUNT(*) FROM User
UNION ALL
SELECT 'ResearchProject', COUNT(*) FROM ResearchProject
UNION ALL
SELECT 'ResearchDataRecord', COUNT(*) FROM ResearchDataRecord
UNION ALL
SELECT 'ResearchAchievement', COUNT(*) FROM ResearchAchievement;

-- ================================================================
-- 字段对照说明（旧 -> 新）:
-- 
-- ResearchProject:
--   principal_investigator_id -> leader_id
--   start_time -> approval_date  
--   end_time -> completion_date
--   InProgress/Completed/Suspended -> ongoing/completed/paused
--
-- ResearchDataCollection -> ResearchDataRecord:
--   area_id -> region_id
--   FieldCollection/SystemReference -> field/system
--   新增: sample_id, monitoring_data_id, data_file_path, remarks,
--         is_verified, verified_by, verified_at
--
-- ResearchResult -> ResearchAchievement:
--   result_id -> achievement_id
--   result_type -> achievement_type (Paper/Report/Patent/Other -> paper/report/patent/other)
--   result_name -> achievement_name
--   publish_time -> submit_time
--   access_level -> share_permission (Public/Internal/Confidential -> public/internal/confidential)
-- ================================================================