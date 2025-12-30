-- ================================================================
-- 科研支撑模块 - 测试数据种子文件
-- 数据库: wildlife_conservation  
-- 基于: 50_research.sql DDL
-- 表名: 首字母大写 (User, Species, Habitat, etc.)
-- 枚举值: 英文 (InProgress, FieldCollection, etc.)
-- ================================================================

USE wildlife_conservation;

SET FOREIGN_KEY_CHECKS = 0;

-- ================================================================
-- 清空表数据（逆序删除，遵循外键依赖关系）
-- ================================================================
DELETE FROM MonitoringRecord;
DELETE FROM HabitatPrimarySpecies;
DELETE FROM ResearchResult;
DELETE FROM ResearchDataCollection;
DELETE FROM ResearchProject;
DELETE FROM Species;
DELETE FROM Habitat;
DELETE FROM User;

-- ================================================================
-- 1. User表 - 用户数据（25条）
-- ================================================================
INSERT INTO User (user_id, name, role) VALUES
('U001', 'Dr. Zhang Wei', 'Principal Investigator'),
('U002', 'Dr. Li Na', 'Researcher'),
('U003', 'Wang Qiang', 'Admin'),
('U004', 'Dr. Liu Min', 'Researcher'),
('U005', 'Chen Jie', 'Data Collector'),
('U006', 'Dr. Zhao Li', 'Researcher'),
('U007', 'Prof. Sun Hao', 'Principal Investigator'),
('U008', 'Zhou Ping', 'Admin'),
('U009', 'Dr. Wu Tao', 'Researcher'),
('U010', 'Zheng Hong', 'Data Collector'),
('U011', 'Dr. Feng Chao', 'Researcher'),
('U012', 'Prof. Yu Jing', 'Principal Investigator'),
('U013', 'Ma Jun', 'Data Collector'),
('U014', 'Dr. Zhu Xue', 'Researcher'),
('U015', 'Hu Ming', 'Admin'),
('U016', 'Prof. Lin Fang', 'Principal Investigator'),
('U017', 'Dr. Luo Gang', 'Researcher'),
('U018', 'Liang Yan', 'Data Collector'),
('U019', 'Prof. Song Lei', 'Principal Investigator'),
('U020', 'Dr. Tang Hui', 'Researcher'),
('U021', 'Prof. Xu Jian', 'Principal Investigator'),
('U022', 'Fu Dan', 'Data Collector'),
('U023', 'Dr. Cao Yong', 'Researcher'),
('U024', 'Dong Juan', 'Admin'),
('U025', 'Dr. Yuan Feng', 'Researcher');

-- ================================================================
-- 2. Species表 - 物种数据（25条）
-- ================================================================
INSERT INTO Species (species_id, scientific_name, common_name, protection_level) VALUES
('SP001', 'Ailuropoda melanoleuca', 'Giant Panda', 'Vulnerable'),
('SP002', 'Panthera tigris', 'Tiger', 'Endangered'),
('SP003', 'Rhinopithecus roxellana', 'Golden Snub-nosed Monkey', 'Endangered'),
('SP004', 'Elaphurus davidianus', 'Pere Davids Deer', 'Extinct in Wild'),
('SP005', 'Grus japonensis', 'Red-crowned Crane', 'Endangered'),
('SP006', 'Nipponia nippon', 'Crested Ibis', 'Endangered'),
('SP007', 'Moschus berezovskii', 'Forest Musk Deer', 'Endangered'),
('SP008', 'Selenarctos thibetanus', 'Asiatic Black Bear', 'Vulnerable'),
('SP009', 'Cervus elaphus', 'Red Deer', 'Least Concern'),
('SP010', 'Capricornis sumatraensis', 'Serow', 'Vulnerable'),
('SP011', 'Canis lupus', 'Gray Wolf', 'Least Concern'),
('SP012', 'Lynx lynx', 'Eurasian Lynx', 'Least Concern'),
('SP013', 'Grus vipio', 'White-naped Crane', 'Vulnerable'),
('SP014', 'Ciconia nigra', 'Black Stork', 'Least Concern'),
('SP015', 'Aquila chrysaetos', 'Golden Eagle', 'Least Concern'),
('SP016', 'Falco peregrinus', 'Peregrine Falcon', 'Least Concern'),
('SP017', 'Bubo bubo', 'Eurasian Eagle-Owl', 'Least Concern'),
('SP018', 'Phasianus colchicus', 'Ring-necked Pheasant', 'Least Concern'),
('SP019', 'Lepus sinensis', 'Chinese Hare', 'Least Concern'),
('SP020', 'Sciurus vulgaris', 'Red Squirrel', 'Least Concern'),
('SP021', 'Muntiacus reevesi', 'Reeves Muntjac', 'Least Concern'),
('SP022', 'Sus scrofa', 'Wild Boar', 'Least Concern'),
('SP023', 'Cervus nippon', 'Sika Deer', 'Least Concern'),
('SP024', 'Moschus chrysogaster', 'Alpine Musk Deer', 'Endangered'),
('SP025', 'Budorcas taxicolor', 'Takin', 'Vulnerable');

-- ================================================================
-- 3. Habitat表 - 栖息地数据（25条）
-- ================================================================
INSERT INTO Habitat (habitat_id, habitat_name, region_code) VALUES
('HB001', 'Wolong Nature Reserve', 'CN-SC-001'),
('HB002', 'Jiuzhaigou National Park', 'CN-SC-002'),
('HB003', 'Shennongjia Forestry District', 'CN-HB-001'),
('HB004', 'Changbai Mountain Reserve', 'CN-JL-001'),
('HB005', 'Xishuangbanna Tropical Rainforest', 'CN-YN-001'),
('HB006', 'Poyang Lake Wetland', 'CN-JX-001'),
('HB007', 'Qinghai Lake Reserve', 'CN-QH-001'),
('HB008', 'Kekexili Nature Reserve', 'CN-QH-002'),
('HB009', 'Qinling Mountains', 'CN-SN-001'),
('HB010', 'Greater Khingan Range', 'CN-NM-001'),
('HB011', 'Wuyi Mountains National Park', 'CN-FJ-001'),
('HB012', 'Zhangjiajie Forest Park', 'CN-HN-001'),
('HB013', 'Fanjingshan Reserve', 'CN-GZ-001'),
('HB014', 'Sanjiangyuan Reserve', 'CN-QH-003'),
('HB015', 'Altai Mountains', 'CN-XJ-001'),
('HB016', 'Tianshan Mountains', 'CN-XJ-002'),
('HB017', 'Hengduan Mountains', 'CN-SC-003'),
('HB018', 'Qilian Mountains Reserve', 'CN-GS-001'),
('HB019', 'Taihang Mountains', 'CN-HE-001'),
('HB020', 'Helan Mountains Reserve', 'CN-NX-001'),
('HB021', 'Gaoligong Mountains Yunnan', 'CN-YN-002'),
('HB022', 'Mount Emei Sichuan', 'CN-SC-004'),
('HB023', 'Zhalong Wetland Heilongjiang', 'CN-HL-001'),
('HB024', 'Yancheng Wetland Jiangsu', 'CN-JS-001'),
('HB025', 'Bawangling Hainan', 'CN-HI-001');

-- ================================================================
-- 4. HabitatPrimarySpecies表 - 栖息地主要物种关联（44条）
-- ================================================================
INSERT INTO HabitatPrimarySpecies (id, habitat_id, species_id) VALUES
('HPS001', 'HB001', 'SP001'), ('HPS002', 'HB001', 'SP003'), ('HPS003', 'HB001', 'SP007'),
('HPS004', 'HB002', 'SP001'), ('HPS005', 'HB002', 'SP008'), ('HPS006', 'HB002', 'SP020'),
('HPS007', 'HB003', 'SP003'), ('HPS008', 'HB003', 'SP008'), ('HPS009', 'HB003', 'SP021'),
('HPS010', 'HB004', 'SP002'), ('HPS011', 'HB004', 'SP011'), ('HPS012', 'HB004', 'SP012'),
('HPS013', 'HB005', 'SP013'), ('HPS014', 'HB005', 'SP014'), ('HPS015', 'HB005', 'SP018'),
('HPS016', 'HB006', 'SP005'), ('HPS017', 'HB006', 'SP014'), ('HPS018', 'HB006', 'SP016'),
('HPS019', 'HB007', 'SP006'), ('HPS020', 'HB007', 'SP013'), ('HPS021', 'HB007', 'SP015'),
('HPS022', 'HB008', 'SP009'), ('HPS023', 'HB008', 'SP011'), ('HPS024', 'HB008', 'SP015'),
('HPS025', 'HB009', 'SP001'), ('HPS026', 'HB009', 'SP003'), 
('HPS027', 'HB009', 'SP008'), ('HPS028', 'HB009', 'SP023'),
('HPS029', 'HB010', 'SP009'), ('HPS030', 'HB010', 'SP011'), 
('HPS031', 'HB010', 'SP012'), ('HPS032', 'HB010', 'SP017'),
('HPS033', 'HB011', 'SP008'), ('HPS034', 'HB011', 'SP019'), ('HPS035', 'HB011', 'SP020'),
('HPS036', 'HB012', 'SP003'), ('HPS037', 'HB012', 'SP008'), ('HPS038', 'HB012', 'SP021'),
('HPS039', 'HB013', 'SP003'), ('HPS040', 'HB013', 'SP007'), ('HPS041', 'HB013', 'SP024'),
('HPS042', 'HB014', 'SP009'), ('HPS043', 'HB014', 'SP015'), ('HPS044', 'HB014', 'SP025');

-- ================================================================
-- 5. ResearchProject表 - 研究项目数据（25条）
-- 枚举值: InProgress, Completed, Suspended
-- ================================================================
INSERT INTO ResearchProject (project_id, project_name, principal_investigator_id, 
                             applicant_organization, start_time, end_time, 
                             project_status, research_field, leader_user_id) VALUES
('PRJ001', 'Giant Panda Habitat Monitoring', 'U001', 'Chinese Academy of Sciences', '2022-01-01', '2024-12-31', 'InProgress', 'Conservation Biology', 'U001'),
('PRJ002', 'Tiger Population Recovery Study', 'U002', 'Peking University', '2021-06-01', '2023-12-31', 'Completed', 'Species Conservation', 'U002'),
('PRJ003', 'Golden Monkey Behavioral Research', 'U004', 'China Forestry University', '2023-03-01', '2025-03-01', 'InProgress', 'Animal Behavior', 'U004'),
('PRJ004', 'Pere Davids Deer Rewilding Project', 'U006', 'Nanjing University', '2022-09-01', '2024-09-01', 'InProgress', 'Species Restoration', 'U006'),
('PRJ005', 'Red-crowned Crane Migration Study', 'U007', 'Northeast Forestry University', '2021-01-01', '2023-06-30', 'Completed', 'Migration Ecology', 'U007'),
('PRJ006', 'Crested Ibis Breeding Ecology', 'U009', 'Shaanxi Normal University', '2023-01-01', '2025-12-31', 'InProgress', 'Breeding Biology', 'U009'),
('PRJ007', 'Musk Deer Captive Breeding Technology', 'U011', 'Sichuan Agricultural University', '2022-05-01', '2024-05-01', 'InProgress', 'Captive Breeding', 'U011'),
('PRJ008', 'Black Bear Hibernation Mechanism', 'U014', 'Chinese Academy of Sciences', '2021-10-01', '2023-10-01', 'Completed', 'Physiology', 'U014'),
('PRJ009', 'Red Deer Population Dynamics', 'U016', 'Inner Mongolia University', '2023-06-01', '2025-06-01', 'InProgress', 'Population Ecology', 'U016'),
('PRJ010', 'Serow Habitat Assessment', 'U019', 'Yunnan University', '2022-03-01', '2024-03-01', 'InProgress', 'Habitat Management', 'U019'),
('PRJ011', 'Wolf Pack Social Structure', 'U020', 'Lanzhou University', '2021-08-01', '2023-08-01', 'Completed', 'Social Behavior', 'U020'),
('PRJ012', 'Lynx Predation Strategy Analysis', 'U021', 'Jilin University', '2023-04-01', '2025-04-01', 'InProgress', 'Predation Ecology', 'U021'),
('PRJ013', 'White-naped Crane Wintering Protection', 'U023', 'Jiangxi Normal University', '2022-11-01', '2024-11-01', 'InProgress', 'Wintering Ecology', 'U023'),
('PRJ014', 'Black Stork Breeding Site Survey', 'U002', 'Hebei University', '2021-05-01', '2023-05-01', 'Completed', 'Breeding Ecology', 'U002'),
('PRJ015', 'Golden Eagle Territory Behavior', 'U025', 'Xinjiang University', '2023-02-01', '2025-02-01', 'InProgress', 'Territory Ecology', 'U025'),
('PRJ016', 'Peregrine Falcon Hunting Techniques', 'U004', 'Qinghai University', '2022-07-01', '2024-07-01', 'InProgress', 'Predation Behavior', 'U004'),
('PRJ017', 'Eagle-Owl Breeding Success Rate', 'U006', 'Gansu Agricultural University', '2021-09-01', '2023-09-01', 'Completed', 'Breeding Strategy', 'U006'),
('PRJ018', 'Ring-necked Pheasant Recovery', 'U007', 'Anhui University', '2023-05-01', '2025-05-01', 'InProgress', 'Population Recovery', 'U007'),
('PRJ019', 'Chinese Hare Distribution Survey', 'U009', 'South China Normal University', '2022-02-01', '2024-02-01', 'InProgress', 'Distribution Survey', 'U009'),
('PRJ020', 'Red Squirrel Habitat Selection', 'U011', 'Fujian Agriculture Forestry Univ', '2021-11-01', '2023-11-01', 'Completed', 'Habitat Selection', 'U011'),
('PRJ021', 'Muntjac Activity Pattern Research', 'U014', 'Zhejiang University', '2023-07-01', '2025-07-01', 'InProgress', 'Activity Pattern', 'U014'),
('PRJ022', 'Wild Boar Population Control', 'U016', 'Shandong Agricultural University', '2022-04-01', '2024-04-01', 'InProgress', 'Population Management', 'U016'),
('PRJ023', 'Sika Deer Migration Routes', 'U019', 'Liaoning University', '2021-12-01', '2023-12-01', 'Completed', 'Migration Ecology', 'U019'),
('PRJ024', 'Alpine Musk Deer Conservation', 'U020', 'Tibet University', '2023-08-01', '2025-08-01', 'InProgress', 'Species Conservation', 'U020'),
('PRJ025', 'Takin Genetic Diversity', 'U021', 'Sichuan University', '2022-10-01', '2024-10-01', 'InProgress', 'Genetics', 'U021');

-- ================================================================
-- 6. ResearchDataCollection表 - 数据采集记录（30条）
-- 枚举值: FieldCollection, SystemReference
-- ================================================================
INSERT INTO ResearchDataCollection (collection_id, collection_time, collector_id, 
                                   area_id, collection_content, data_source, project_id) VALUES
('DC001', '2022-03-15 09:00:00', 'U003', 'HB001', 'Camera trap deployment for panda activity', 'FieldCollection', 'PRJ001'),
('DC002', '2022-06-20 14:30:00', 'U003', 'HB001', 'Vegetation survey recording bamboo distribution', 'FieldCollection', 'PRJ001'),
('DC003', '2023-01-10 10:00:00', 'U003', 'HB001', 'Snow tracking for population estimation', 'FieldCollection', 'PRJ001'),
('DC004', '2021-08-15 08:00:00', 'U005', 'HB004', 'Drone aerial survey for habitat mapping', 'SystemReference', 'PRJ002'),
('DC005', '2022-05-20 11:00:00', 'U005', 'HB004', 'Tiger scat collection for DNA analysis', 'FieldCollection', 'PRJ002'),
('DC006', '2023-04-10 09:30:00', 'U010', 'HB003', 'Golden monkey social behavior observation', 'FieldCollection', 'PRJ003'),
('DC007', '2023-07-15 15:00:00', 'U010', 'HB003', 'Vocalization recording for individual ID', 'FieldCollection', 'PRJ003'),
('DC008', '2022-11-05 10:00:00', 'U013', 'HB006', 'GPS collar data download from deer', 'SystemReference', 'PRJ004'),
('DC009', '2023-02-20 08:30:00', 'U013', 'HB006', 'Health assessment of deer population', 'FieldCollection', 'PRJ004'),
('DC010', '2021-03-25 07:00:00', 'U018', 'HB006', 'Satellite tracking of crane migration', 'SystemReference', 'PRJ005'),
('DC011', '2022-10-10 16:00:00', 'U018', 'HB006', 'Wintering site environmental measurements', 'FieldCollection', 'PRJ005'),
('DC012', '2023-05-15 09:00:00', 'U022', 'HB009', 'Ibis nest monitoring video collection', 'FieldCollection', 'PRJ006'),
('DC013', '2023-08-20 14:00:00', 'U022', 'HB009', 'Chick growth data recording', 'FieldCollection', 'PRJ006'),
('DC014', '2022-07-10 11:00:00', 'U005', 'HB001', 'Captive musk deer health records', 'SystemReference', 'PRJ007'),
('DC015', '2023-03-05 10:30:00', 'U005', 'HB001', 'Musk secretion measurement', 'FieldCollection', 'PRJ007'),
('DC016', '2021-12-15 09:00:00', 'U010', 'HB004', 'Bear hibernation den temperature monitoring', 'FieldCollection', 'PRJ008'),
('DC017', '2022-03-01 08:00:00', 'U010', 'HB004', 'Metabolic rate measurement during hibernation', 'FieldCollection', 'PRJ008'),
('DC018', '2023-09-10 10:00:00', 'U013', 'HB010', 'Aerial census of red deer population', 'SystemReference', 'PRJ009'),
('DC019', '2023-11-20 15:00:00', 'U013', 'HB010', 'Rutting behavior observation', 'FieldCollection', 'PRJ009'),
('DC020', '2022-05-25 09:30:00', 'U018', 'HB005', 'Serow habitat vegetation coverage', 'SystemReference', 'PRJ010'),
('DC021', '2023-01-15 11:00:00', 'U018', 'HB005', 'Diet analysis sample collection', 'FieldCollection', 'PRJ010'),
('DC022', '2021-10-20 08:00:00', 'U022', 'HB008', 'Wolf pack individual identification', 'FieldCollection', 'PRJ011'),
('DC023', '2022-04-15 14:00:00', 'U022', 'HB008', 'Predation behavior video recording', 'FieldCollection', 'PRJ011'),
('DC024', '2023-06-05 09:00:00', 'U003', 'HB004', 'Lynx camera trap data', 'FieldCollection', 'PRJ012'),
('DC025', '2023-09-20 16:00:00', 'U003', 'HB004', 'Prey composition analysis', 'FieldCollection', 'PRJ012'),
('DC026', '2022-12-10 10:00:00', 'U005', 'HB006', 'Crane wintering site water quality', 'FieldCollection', 'PRJ013'),
('DC027', '2023-03-25 08:30:00', 'U005', 'HB006', 'Population census of wintering cranes', 'FieldCollection', 'PRJ013'),
('DC028', '2021-06-15 09:00:00', 'U010', 'HB001', 'Black stork breeding site survey', 'SystemReference', 'PRJ014'),
('DC029', '2023-04-20 10:30:00', 'U013', 'HB008', 'Golden eagle territory GPS mapping', 'SystemReference', 'PRJ015'),
('DC030', '2022-09-10 11:00:00', 'U018', 'HB007', 'Falcon hunting success rate observation', 'FieldCollection', 'PRJ016');

-- ================================================================
-- 7. MonitoringRecord表 - 监测记录（45条）
-- ================================================================
INSERT INTO MonitoringRecord (record_id, monitor_time, data_type, data_value, 
                              habitat_id, species_id, collection_id) VALUES
('MR001', '2022-03-15 09:30:00', 'Population Count', '3 adult individuals', 'HB001', 'SP001', 'DC001'),
('MR002', '2022-03-15 10:00:00', 'Behavior Observation', 'Feeding on bamboo shoots', 'HB001', 'SP001', 'DC001'),
('MR003', '2022-06-20 15:00:00', 'Habitat Assessment', 'Bamboo coverage 85%', 'HB001', 'SP001', 'DC002'),
('MR004', '2023-01-10 10:30:00', 'Population Count', 'Found 5 sets of tracks', 'HB001', 'SP001', 'DC003'),
('MR005', '2021-08-15 08:30:00', 'Habitat Assessment', 'Forest coverage 92%', 'HB004', 'SP002', 'DC004'),
('MR006', '2022-05-20 11:30:00', 'DNA Analysis', 'Genotype A1', 'HB004', 'SP002', 'DC005'),
('MR007', '2022-05-20 12:00:00', 'Health Status', 'Scat sample normal', 'HB004', 'SP002', 'DC005'),
('MR008', '2023-04-10 10:00:00', 'Population Count', 'Group size 25 individuals', 'HB003', 'SP003', 'DC006'),
('MR009', '2023-04-10 11:00:00', 'Behavior Observation', 'Frequent grooming behavior', 'HB003', 'SP003', 'DC006'),
('MR010', '2023-07-15 15:30:00', 'Vocal Recognition', 'Individual ID-M001', 'HB003', 'SP003', 'DC007'),
('MR011', '2023-07-15 16:00:00', 'Vocal Recognition', 'Individual ID-F002', 'HB003', 'SP003', 'DC007'),
('MR012', '2022-11-05 10:30:00', 'GPS Location', 'N31.2° E120.5°', 'HB006', 'SP004', 'DC008'),
('MR013', '2022-11-05 11:00:00', 'Movement Pattern', 'Daily movement 3.2km', 'HB006', 'SP004', 'DC008'),
('MR014', '2023-02-20 09:00:00', 'Health Check', 'Body weight 180kg', 'HB006', 'SP004', 'DC009'),
('MR015', '2023-02-20 09:30:00', 'Health Check', 'Body condition good', 'HB006', 'SP004', 'DC009'),
('MR016', '2021-03-25 07:30:00', 'Satellite Tracking', 'Located at Poyang Lake core', 'HB006', 'SP005', 'DC010'),
('MR017', '2021-03-25 08:00:00', 'Population Count', 'Wintering population ~200', 'HB006', 'SP005', 'DC010'),
('MR018', '2022-10-10 16:30:00', 'Environmental Monitor', 'Water depth 0.8m', 'HB006', 'SP005', 'DC011'),
('MR019', '2022-10-10 17:00:00', 'Environmental Monitor', 'Water temperature 12°C', 'HB006', 'SP005', 'DC011'),
('MR020', '2023-05-15 09:30:00', 'Breeding Monitor', '3 eggs in nest', 'HB009', 'SP006', 'DC012'),
('MR021', '2023-05-15 10:00:00', 'Behavior Observation', 'Parent incubating', 'HB009', 'SP006', 'DC012'),
('MR022', '2023-08-20 14:30:00', 'Chick Monitor', 'Chick weight 120g', 'HB009', 'SP006', 'DC013'),
('MR023', '2023-08-20 15:00:00', 'Chick Monitor', 'Wingspan 25cm', 'HB009', 'SP006', 'DC013'),
('MR024', '2022-07-10 11:30:00', 'Health Record', 'Individual ID LM-001', 'HB001', 'SP007', 'DC014'),
('MR025', '2023-03-05 11:00:00', 'Musk Production', 'Annual yield 5g', 'HB001', 'SP007', 'DC015'),
('MR026', '2021-12-15 09:30:00', 'Hibernation Monitor', 'Den temperature 5°C', 'HB004', 'SP008', 'DC016'),
('MR027', '2022-03-01 08:30:00', 'Metabolic Monitor', 'Heart rate 30 bpm', 'HB004', 'SP008', 'DC017'),
('MR028', '2022-03-01 09:00:00', 'Metabolic Monitor', 'Body temp reduced to 32°C', 'HB004', 'SP008', 'DC017'),
('MR029', '2023-09-10 10:30:00', 'Population Count', 'Population ~150 individuals', 'HB010', 'SP009', 'DC018'),
('MR030', '2023-11-20 15:30:00', 'Behavior Observation', 'Male sparring behavior', 'HB010', 'SP009', 'DC019'),
('MR031', '2023-11-20 16:00:00', 'Behavior Observation', 'Rutting calls', 'HB010', 'SP009', 'DC019'),
('MR032', '2022-05-25 10:00:00', 'Habitat Assessment', 'Vegetation coverage 78%', 'HB005', 'SP010', 'DC020'),
('MR033', '2023-01-15 11:30:00', 'Diet Analysis', 'Main food broadleaf saplings', 'HB005', 'SP010', 'DC021'),
('MR034', '2023-01-15 12:00:00', 'Diet Analysis', 'Foraging on herbs', 'HB005', 'SP010', 'DC021'),
('MR035', '2021-10-20 08:30:00', 'Individual ID', 'Pack size 8 individuals', 'HB008', 'SP011', 'DC022'),
('MR036', '2022-04-15 14:30:00', 'Predation Behavior', 'Prey species hare', 'HB008', 'SP011', 'DC023'),
('MR037', '2022-04-15 15:00:00', 'Predation Behavior', 'Hunt success rate 60%', 'HB008', 'SP011', 'DC023'),
('MR038', '2023-06-05 09:30:00', 'Camera Trap', 'Frequent nocturnal activity', 'HB004', 'SP012', 'DC024'),
('MR039', '2023-09-20 16:30:00', 'Diet Analysis', 'Prey mainly rodents', 'HB004', 'SP012', 'DC025'),
('MR040', '2023-09-20 17:00:00', 'Diet Analysis', 'Occasional hare predation', 'HB004', 'SP012', 'DC025'),
('MR041', '2022-12-10 10:30:00', 'Environmental Monitor', 'pH value 7.2', 'HB006', 'SP013', 'DC026'),
('MR042', '2023-03-25 09:00:00', 'Population Count', 'Wintering group 80 birds', 'HB006', 'SP013', 'DC027'),
('MR043', '2023-04-20 11:00:00', 'Territory Monitor', 'Territory area ~50km²', 'HB008', 'SP015', 'DC029'),
('MR044', '2023-04-20 11:30:00', 'Territory Monitor', 'Nest on cliff face', 'HB008', 'SP015', 'DC029'),
('MR045', '2022-09-10 11:30:00', 'Hunting Monitor', 'Hunt success rate 75%', 'HB007', 'SP016', 'DC030');

-- ================================================================
-- 8. ResearchResult表 - 研究成果（30条）
-- 枚举值: Paper, Report, Patent, Other
-- 枚举值: Public, Internal, Confidential
-- ================================================================
INSERT INTO ResearchResult (result_id, result_type, result_name, publish_time, 
                           access_level, file_path, project_id) VALUES
('RES001', 'Paper', 'Giant Panda Habitat Selection and Bamboo Distribution', '2023-06-15', 'Public', '/results/paper_001.pdf', 'PRJ001'),
('RES002', 'Report', 'Wolong Reserve Panda Population Monitoring Annual Report', '2023-12-20', 'Internal', '/results/report_001.pdf', 'PRJ001'),
('RES003', 'Other', 'Giant Panda Activity Image Database 2022-2023', '2023-08-10', 'Confidential', '/results/data_001.zip', 'PRJ001'),
('RES004', 'Paper', 'Genetic Diversity Assessment of South China Tigers', '2023-05-20', 'Public', '/results/paper_002.pdf', 'PRJ002'),
('RES005', 'Report', 'Tiger Population Recovery Feasibility Study', '2023-11-30', 'Internal', '/results/report_002.pdf', 'PRJ002'),
('RES006', 'Paper', 'Golden Monkey Social Structure and Behavior Patterns', '2024-01-15', 'Public', '/results/paper_003.pdf', 'PRJ003'),
('RES007', 'Other', 'Golden Monkey Vocalization Database', '2023-09-25', 'Internal', '/results/data_003.zip', 'PRJ003'),
('RES008', 'Report', 'Pere Davids Deer Rewilding Effectiveness Assessment', '2023-07-10', 'Internal', '/results/report_004.pdf', 'PRJ004'),
('RES009', 'Paper', 'Migration Routes and Habitat Use of Pere Davids Deer', '2023-10-05', 'Public', '/results/paper_004.pdf', 'PRJ004'),
('RES010', 'Paper', 'East Asian Flyway of Red-crowned Cranes', '2023-04-20', 'Public', '/results/paper_005.pdf', 'PRJ005'),
('RES011', 'Other', 'Crane Satellite Tracking Data 2021-2023', '2023-08-15', 'Public', '/results/data_005.zip', 'PRJ005'),
('RES012', 'Paper', 'Factors Affecting Crested Ibis Breeding Success', '2024-02-10', 'Public', '/results/paper_006.pdf', 'PRJ006'),
('RES013', 'Report', 'Crested Ibis Population Recovery Progress Report', '2023-12-05', 'Internal', '/results/report_006.pdf', 'PRJ006'),
('RES014', 'Paper', 'Optimization of Musk Deer Captive Breeding Technology', '2023-09-15', 'Public', '/results/paper_007.pdf', 'PRJ007'),
('RES015', 'Patent', 'Efficient Musk Collection Device for Musk Deer', '2023-11-20', 'Confidential', '/results/patent_007.pdf', 'PRJ007'),
('RES016', 'Paper', 'Physiological Adaptations During Black Bear Hibernation', '2023-06-30', 'Public', '/results/paper_008.pdf', 'PRJ008'),
('RES017', 'Other', 'Black Bear Hibernation Monitoring Data 2021-2023', '2023-10-25', 'Internal', '/results/data_008.zip', 'PRJ008'),
('RES018', 'Report', 'Red Deer Population Dynamics Monitoring Report', '2024-01-20', 'Internal', '/results/report_009.pdf', 'PRJ009'),
('RES019', 'Paper', 'Serow Habitat Quality Evaluation Index System', '2023-08-05', 'Public', '/results/paper_010.pdf', 'PRJ010'),
('RES020', 'Paper', 'Cooperative Hunting Strategies in Gray Wolf Packs', '2023-03-15', 'Public', '/results/paper_011.pdf', 'PRJ011'),
('RES021', 'Other', 'Wolf Predation Behavior Video Library', '2023-07-20', 'Internal', '/results/data_011.zip', 'PRJ011'),
('RES022', 'Paper', 'Spatiotemporal Patterns of Lynx Predation Behavior', '2024-02-25', 'Public', '/results/paper_012.pdf', 'PRJ012'),
('RES023', 'Report', 'White-naped Crane Wintering Site Protection Recommendations', '2023-12-15', 'Internal', '/results/report_013.pdf', 'PRJ013'),
('RES024', 'Paper', 'Breeding Habitat Characteristics of Black Storks', '2023-09-10', 'Public', '/results/paper_014.pdf', 'PRJ014'),
('RES025', 'Paper', 'Territory Defense Behavior in Golden Eagles', '2024-03-05', 'Public', '/results/paper_015.pdf', 'PRJ015'),
('RES026', 'Report', 'Peregrine Falcon Hunting Technique Analysis', '2023-11-10', 'Internal', '/results/report_016.pdf', 'PRJ016'),
('RES027', 'Paper', 'Eagle-Owl Breeding Success and Environmental Factors', '2023-08-25', 'Public', '/results/paper_017.pdf', 'PRJ017'),
('RES028', 'Report', 'Ring-necked Pheasant Recovery Project Progress', '2024-01-30', 'Internal', '/results/report_018.pdf', 'PRJ018'),
('RES029', 'Other', 'Chinese Hare Distribution Survey Data', '2023-10-15', 'Public', '/results/data_019.zip', 'PRJ019'),
('RES030', 'Paper', 'Red Squirrel Habitat Selection Preferences', '2023-07-05', 'Public', '/results/paper_020.pdf', 'PRJ020');

-- ================================================================
-- 恢复外键检查
-- ================================================================
SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- 数据插入统计
-- ================================================================
SELECT '=== Data Insertion Completed ===' AS Status;

SELECT 'User' AS TableName, COUNT(*) AS RecordCount FROM User
UNION ALL
SELECT 'Species', COUNT(*) FROM Species
UNION ALL
SELECT 'Habitat', COUNT(*) FROM Habitat
UNION ALL
SELECT 'HabitatPrimarySpecies', COUNT(*) FROM HabitatPrimarySpecies
UNION ALL
SELECT 'ResearchProject', COUNT(*) FROM ResearchProject
UNION ALL
SELECT 'ResearchDataCollection', COUNT(*) FROM ResearchDataCollection
UNION ALL
SELECT 'MonitoringRecord', COUNT(*) FROM MonitoringRecord
UNION ALL
SELECT 'ResearchResult', COUNT(*) FROM ResearchResult;

-- ================================================================
-- Notes: 
-- 1. All tables have >= 20 records (总计225条记录)
-- 2. Foreign key checks disabled for repeatable execution
-- 3. Table names: CamelCase (User, Species, ResearchProject, etc.)
-- 4. Enum values: English (InProgress/Completed/Suspended, 
--    FieldCollection/SystemReference, Paper/Report/Patent/Other,
--    Public/Internal/Confidential)
-- 5. Time span 2021-2024 for temporal query testing
-- 6. Can be executed multiple times without error
-- ================================================================