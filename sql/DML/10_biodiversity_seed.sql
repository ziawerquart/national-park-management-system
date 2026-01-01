-- =====================================================
-- Biodiversity Seed Data (MySQL 8.x)
-- 目标：
-- 1) 为生物多样性模块相关表准备测试数据（每表 ≥20 条）
-- 2) 字段名 / 枚举值与 sql/DDL/99_all_in_one.sql 保持一致
-- 3) 可重复执行：使用 ON DUPLICATE KEY UPDATE
-- =====================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

USE national_park_db;

-- -----------------------------------------------------
-- 0. Global tables required by FKs (minimal but sufficient)
-- -----------------------------------------------------

-- Region (5 rows)
INSERT INTO Region (region_id, region_name, region_type) VALUES
('R001', '核心保护区A', 'core'),
('R002', '缓冲区B', 'buffer'),
('R003', '实验区C', 'experimental'),
('R004', '核心保护区D', 'core'),
('R005', '缓冲区E', 'buffer')
ON DUPLICATE KEY UPDATE
  region_name = VALUES(region_name),
  region_type = VALUES(region_type);

-- User (10 rows)
INSERT INTO User (user_id, user_name, role) VALUES
('U001', '张晨', 'ecological_monitor'),
('U002', '李珊', 'ecological_monitor'),
('U003', '王浩', 'data_analyst'),
('U004', '赵敏', 'technician'),
('U005', '陈杰', 'researcher'),
('U006', '周颖', 'park_manager'),
('U007', '刘洋', 'admin'),
('U008', '孙悦', 'ecological_monitor'),
('U009', '何平', 'data_analyst'),
('U010', '高磊', 'researcher')
ON DUPLICATE KEY UPDATE
  user_name = VALUES(user_name),
  role = VALUES(role);

-- MonitoringDevice (10 rows)
INSERT INTO MonitoringDevice
(device_id, device_type, install_time, calibration_cycle, run_status, communication_protocol, region_id)
VALUES
('MD001', 'air_sensor', '2025-01-02 10:00:00', '45', 'fault', '4G', 'R001'),
('MD002', 'drone_station', '2025-01-03 10:00:00', '60', 'offline', 'LoRaWAN', 'R002'),
('MD003', 'water_sensor', '2025-01-04 10:00:00', '30', 'normal', '4G', 'R003'),
('MD004', 'infrared_camera', '2025-01-05 10:00:00', '45', 'fault', 'LoRaWAN', 'R001'),
('MD005', 'air_sensor', '2025-01-06 10:00:00', '60', 'offline', '4G', 'R002'),
('MD006', 'drone_station', '2025-01-07 10:00:00', '30', 'normal', 'LoRaWAN', 'R003'),
('MD007', 'water_sensor', '2025-01-08 10:00:00', '45', 'fault', '4G', 'R001'),
('MD008', 'infrared_camera', '2025-01-09 10:00:00', '60', 'offline', 'LoRaWAN', 'R002'),
('MD009', 'air_sensor', '2025-01-10 10:00:00', '30', 'normal', '4G', 'R003'),
('MD010', 'drone_station', '2025-01-11 10:00:00', '45', 'fault', 'LoRaWAN', 'R001')
ON DUPLICATE KEY UPDATE
  device_type = VALUES(device_type),
  install_time = VALUES(install_time),
  calibration_cycle = VALUES(calibration_cycle),
  run_status = VALUES(run_status),
  communication_protocol = VALUES(communication_protocol),
  region_id = VALUES(region_id);

-- -----------------------------------------------------
-- 1. Biodiversity tables (each ≥20 rows)
-- -----------------------------------------------------

-- Habitat (20 rows)
INSERT INTO Habitat
(habitat_id, area_name, ecological_type, area_size, core_protection_area, environment_suitability_score, region_id)
VALUES
('HB001', 'Habitat-01', 'forest', '53.5', 'Zone-A-01', '63.7', 'R001'),
('HB002', 'Habitat-02', 'wetland', '57.0', 'Zone-B-02', '67.4', 'R002'),
('HB003', 'Habitat-03', 'grassland', '60.5', 'Zone-C-03', '71.1', 'R003'),
('HB004', 'Habitat-04', 'alpine', '64.0', 'Zone-D-04', '74.8', 'R001'),
('HB005', 'Habitat-05', 'desert', '67.5', 'Zone-E-05', '78.5', 'R002'),
('HB006', 'Habitat-06', 'forest', '71.0', 'Zone-A-06', '82.2', 'R003'),
('HB007', 'Habitat-07', 'wetland', '74.5', 'Zone-B-07', '85.9', 'R001'),
('HB008', 'Habitat-08', 'grassland', '78.0', 'Zone-C-08', '89.6', 'R002'),
('HB009', 'Habitat-09', 'alpine', '81.5', 'Zone-D-09', '93.3', 'R003'),
('HB010', 'Habitat-10', 'desert', '85.0', 'Zone-E-10', '97.0', 'R001'),
('HB011', 'Habitat-11', 'forest', '88.5', 'Zone-A-11', '63.7', 'R002'),
('HB012', 'Habitat-12', 'wetland', '92.0', 'Zone-B-12', '67.4', 'R003'),
('HB013', 'Habitat-13', 'grassland', '95.5', 'Zone-C-13', '71.1', 'R001'),
('HB014', 'Habitat-14', 'alpine', '99.0', 'Zone-D-14', '74.8', 'R002'),
('HB015', 'Habitat-15', 'desert', '102.5', 'Zone-E-15', '78.5', 'R003'),
('HB016', 'Habitat-16', 'forest', '106.0', 'Zone-A-16', '82.2', 'R001'),
('HB017', 'Habitat-17', 'wetland', '109.5', 'Zone-B-17', '85.9', 'R002'),
('HB018', 'Habitat-18', 'grassland', '113.0', 'Zone-C-18', '89.6', 'R003'),
('HB019', 'Habitat-19', 'alpine', '116.5', 'Zone-D-19', '93.3', 'R001'),
('HB020', 'Habitat-20', 'desert', '120.0', 'Zone-E-20', '97.0', 'R002')
ON DUPLICATE KEY UPDATE
  area_name = VALUES(area_name),
  ecological_type = VALUES(ecological_type),
  area_size = VALUES(area_size),
  core_protection_area = VALUES(core_protection_area),
  environment_suitability_score = VALUES(environment_suitability_score),
  region_id = VALUES(region_id);

-- Species (20 rows)
INSERT INTO Species
(species_id, species_name_cn, species_name_latin, kingdom, phylum, tax_class, tax_order, family, genus, species,
 protection_level, living_habits, distribution_description, habitat_id)
VALUES
('SP001', '大熊猫', 'Ailuropoda melanoleuca', 'Animalia', 'Chordata', 'Mammalia', 'Carnivora', 'FamilyX', 'GenusX', 'melanoleuca', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 核心保护区A and nearby habitats.', 'HB001'),
('SP002', '金丝猴', 'Rhinopithecus roxellana', 'Animalia', 'Chordata', 'Mammalia', 'Primates', 'FamilyX', 'GenusX', 'roxellana', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 缓冲区B and nearby habitats.', 'HB002'),
('SP003', '雪豹', 'Panthera uncia', 'Animalia', 'Chordata', 'Mammalia', 'Carnivora', 'FamilyX', 'GenusX', 'uncia', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 实验区C and nearby habitats.', 'HB003'),
('SP004', '朱鹮', 'Nipponia nippon', 'Animalia', 'Chordata', 'Aves', 'Other', 'FamilyX', 'GenusX', 'nippon', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 核心保护区A and nearby habitats.', 'HB004'),
('SP005', '藏羚羊', 'Pantholops hodgsonii', 'Animalia', 'Chordata', 'Mammalia', 'Artiodactyla', 'FamilyX', 'GenusX', 'hodgsonii', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 缓冲区B and nearby habitats.', 'HB005'),
('SP006', '东北虎', 'Panthera tigris altaica', 'Animalia', 'Chordata', 'Mammalia', 'Carnivora', 'FamilyX', 'GenusX', 'altaica', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 实验区C and nearby habitats.', 'HB006'),
('SP007', '亚洲象', 'Elephas maximus', 'Animalia', 'Chordata', 'Mammalia', 'Other', 'FamilyX', 'GenusX', 'maximus', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 核心保护区A and nearby habitats.', 'HB007'),
('SP008', '丹顶鹤', 'Grus japonensis', 'Animalia', 'Chordata', 'Aves', 'Other', 'FamilyX', 'GenusX', 'japonensis', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 缓冲区B and nearby habitats.', 'HB008'),
('SP009', '黑颈鹤', 'Grus nigricollis', 'Animalia', 'Chordata', 'Aves', 'Other', 'FamilyX', 'GenusX', 'nigricollis', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 实验区C and nearby habitats.', 'HB009'),
('SP010', '华南虎', 'Panthera tigris amoyensis', 'Animalia', 'Chordata', 'Mammalia', 'Carnivora', 'FamilyX', 'GenusX', 'amoyensis', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 核心保护区A and nearby habitats.', 'HB010'),
('SP011', '猕猴', 'Macaca mulatta', 'Animalia', 'Chordata', 'Mammalia', 'Primates', 'FamilyX', 'GenusX', 'mulatta', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 缓冲区B and nearby habitats.', 'HB011'),
('SP012', '梅花鹿', 'Cervus nippon', 'Animalia', 'Chordata', 'Mammalia', 'Artiodactyla', 'FamilyX', 'GenusX', 'nippon', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 实验区C and nearby habitats.', 'HB012'),
('SP013', '麋鹿', 'Elaphurus davidianus', 'Animalia', 'Chordata', 'Mammalia', 'Artiodactyla', 'FamilyX', 'GenusX', 'davidianus', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 核心保护区A and nearby habitats.', 'HB013'),
('SP014', '棕熊', 'Ursus arctos', 'Animalia', 'Chordata', 'Mammalia', 'Carnivora', 'FamilyX', 'GenusX', 'arctos', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 缓冲区B and nearby habitats.', 'HB014'),
('SP015', '岩羊', 'Pseudois nayaur', 'Animalia', 'Chordata', 'Mammalia', 'Artiodactyla', 'FamilyX', 'GenusX', 'nayaur', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 实验区C and nearby habitats.', 'HB015'),
('SP016', '马鹿', 'Cervus canadensis', 'Animalia', 'Chordata', 'Mammalia', 'Artiodactyla', 'FamilyX', 'GenusX', 'canadensis', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 核心保护区A and nearby habitats.', 'HB016'),
('SP017', '水獭', 'Lutra lutra', 'Animalia', 'Chordata', 'Mammalia', 'Carnivora', 'FamilyX', 'GenusX', 'lutra', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 缓冲区B and nearby habitats.', 'HB017'),
('SP018', '林麝', 'Moschus berezovskii', 'Animalia', 'Chordata', 'Mammalia', 'Artiodactyla', 'FamilyX', 'GenusX', 'berezovskii', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 实验区C and nearby habitats.', 'HB018'),
('SP019', '穿山甲', 'Manis pentadactyla', 'Animalia', 'Chordata', 'Mammalia', 'Other', 'FamilyX', 'GenusX', 'pentadactyla', 'national_first', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 核心保护区A and nearby habitats.', 'HB019'),
('SP020', '金雕', 'Aquila chrysaetos', 'Animalia', 'Chordata', 'Mammalia', 'Carnivora', 'FamilyX', 'GenusX', 'chrysaetos', 'national_second', 'Active at dawn/dusk; prefers quiet areas.', 'Observed mainly in region 缓冲区B and nearby habitats.', 'HB020')
ON DUPLICATE KEY UPDATE
  species_name_cn = VALUES(species_name_cn),
  species_name_latin = VALUES(species_name_latin),
  kingdom = VALUES(kingdom),
  phylum = VALUES(phylum),
  tax_class = VALUES(tax_class),
  tax_order = VALUES(tax_order),
  family = VALUES(family),
  genus = VALUES(genus),
  species = VALUES(species),
  protection_level = VALUES(protection_level),
  living_habits = VALUES(living_habits),
  distribution_description = VALUES(distribution_description),
  habitat_id = VALUES(habitat_id);

-- HabitatPrimarySpecies (40 rows; ≥20)
INSERT INTO HabitatPrimarySpecies (habitat_id, species_id, is_primary) VALUES
('HB001', 'SP001', '1'),
('HB001', 'SP002', '0'),
('HB002', 'SP002', '1'),
('HB002', 'SP003', '0'),
('HB003', 'SP003', '1'),
('HB003', 'SP004', '0'),
('HB004', 'SP004', '1'),
('HB004', 'SP005', '0'),
('HB005', 'SP005', '1'),
('HB005', 'SP006', '0'),
('HB006', 'SP006', '1'),
('HB006', 'SP007', '0'),
('HB007', 'SP007', '1'),
('HB007', 'SP008', '0'),
('HB008', 'SP008', '1'),
('HB008', 'SP009', '0'),
('HB009', 'SP009', '1'),
('HB009', 'SP010', '0'),
('HB010', 'SP010', '1'),
('HB010', 'SP011', '0'),
('HB011', 'SP011', '1'),
('HB011', 'SP012', '0'),
('HB012', 'SP012', '1'),
('HB012', 'SP013', '0'),
('HB013', 'SP013', '1'),
('HB013', 'SP014', '0'),
('HB014', 'SP014', '1'),
('HB014', 'SP015', '0'),
('HB015', 'SP015', '1'),
('HB015', 'SP016', '0'),
('HB016', 'SP016', '1'),
('HB016', 'SP017', '0'),
('HB017', 'SP017', '1'),
('HB017', 'SP018', '0'),
('HB018', 'SP018', '1'),
('HB018', 'SP019', '0'),
('HB019', 'SP019', '1'),
('HB019', 'SP020', '0'),
('HB020', 'SP020', '1'),
('HB020', 'SP001', '0')
ON DUPLICATE KEY UPDATE
  is_primary = VALUES(is_primary);

-- MonitoringRecord (20 rows)
INSERT INTO MonitoringRecord
(record_id, species_id, device_id, monitoring_time, longitude, latitude, monitoring_method,
 image_path, count_number, behavior_description, recorder_id, status)
VALUES
('MR001', 'SP001', 'MD001', '2025-02-02 08:01:00', '116.210000', '40.005000', 'infrared_camera', '/data/media/mr/MR001.jpg', '2', 'resting', 'U001', 'valid'),
('MR002', 'SP002', 'MD002', '2025-02-03 08:02:00', '116.220000', '40.010000', 'manual_check', NULL, '3', 'moving', 'U002', 'valid'),
('MR003', 'SP003', 'MD003', '2025-02-04 08:03:00', '116.230000', '40.015000', 'drone', NULL, '4', 'calling', 'U003', 'valid'),
('MR004', 'SP004', 'MD004', '2025-02-05 08:04:00', '116.240000', '40.020000', 'infrared_camera', '/data/media/mr/MR004.jpg', '5', 'mating', 'U004', 'to_verify'),
('MR005', 'SP005', 'MD005', '2025-02-06 08:05:00', '116.250000', '40.025000', 'manual_check', NULL, '1', 'foraging', 'U005', 'valid'),
('MR006', 'SP006', 'MD006', '2025-02-07 08:06:00', '116.260000', '40.030000', 'drone', NULL, '2', 'resting', 'U006', 'valid'),
('MR007', 'SP007', 'MD007', '2025-02-08 08:07:00', '116.270000', '40.035000', 'infrared_camera', '/data/media/mr/MR007.jpg', '3', 'moving', 'U007', 'valid'),
('MR008', 'SP008', 'MD008', '2025-02-09 08:08:00', '116.280000', '40.040000', 'manual_check', NULL, '4', 'calling', 'U008', 'to_verify'),
('MR009', 'SP009', 'MD009', '2025-02-10 08:09:00', '116.290000', '40.045000', 'drone', NULL, '5', 'mating', 'U009', 'valid'),
('MR010', 'SP010', 'MD010', '2025-02-11 08:10:00', '116.300000', '40.050000', 'infrared_camera', '/data/media/mr/MR010.jpg', '1', 'foraging', 'U010', 'valid'),
('MR011', 'SP011', 'MD001', '2025-02-12 08:11:00', '116.210000', '40.005000', 'manual_check', NULL, '2', 'resting', 'U001', 'valid'),
('MR012', 'SP012', 'MD002', '2025-02-13 08:12:00', '116.220000', '40.010000', 'drone', NULL, '3', 'moving', 'U002', 'to_verify'),
('MR013', 'SP013', 'MD003', '2025-02-14 08:13:00', '116.230000', '40.015000', 'infrared_camera', '/data/media/mr/MR013.jpg', '4', 'calling', 'U003', 'valid'),
('MR014', 'SP014', 'MD004', '2025-02-15 08:14:00', '116.240000', '40.020000', 'manual_check', NULL, '5', 'mating', 'U004', 'valid'),
('MR015', 'SP015', 'MD005', '2025-02-16 08:15:00', '116.250000', '40.025000', 'drone', NULL, '1', 'foraging', 'U005', 'valid'),
('MR016', 'SP016', 'MD006', '2025-02-17 08:16:00', '116.260000', '40.030000', 'infrared_camera', '/data/media/mr/MR016.jpg', '2', 'resting', 'U006', 'to_verify'),
('MR017', 'SP017', 'MD007', '2025-02-18 08:17:00', '116.270000', '40.035000', 'manual_check', NULL, '3', 'moving', 'U007', 'valid'),
('MR018', 'SP018', 'MD008', '2025-02-19 08:18:00', '116.280000', '40.040000', 'drone', NULL, '4', 'calling', 'U008', 'valid'),
('MR019', 'SP019', 'MD009', '2025-02-20 08:19:00', '116.290000', '40.045000', 'infrared_camera', '/data/media/mr/MR019.jpg', '5', 'mating', 'U009', 'valid'),
('MR020', 'SP020', 'MD010', '2025-02-21 08:20:00', '116.300000', '40.050000', 'manual_check', NULL, '1', 'foraging', 'U010', 'to_verify')
ON DUPLICATE KEY UPDATE
  species_id = VALUES(species_id),
  device_id = VALUES(device_id),
  monitoring_time = VALUES(monitoring_time),
  longitude = VALUES(longitude),
  latitude = VALUES(latitude),
  monitoring_method = VALUES(monitoring_method),
  image_path = VALUES(image_path),
  count_number = VALUES(count_number),
  behavior_description = VALUES(behavior_description),
  recorder_id = VALUES(recorder_id),
  status = VALUES(status);

-- -----------------------------------------------------
-- 2. Quick sanity check (optional)
-- -----------------------------------------------------
-- SELECT 'Region' AS tbl, COUNT(*) AS cnt FROM Region
-- UNION ALL SELECT 'User', COUNT(*) FROM User
-- UNION ALL SELECT 'MonitoringDevice', COUNT(*) FROM MonitoringDevice
-- UNION ALL SELECT 'Habitat', COUNT(*) FROM Habitat
-- UNION ALL SELECT 'Species', COUNT(*) FROM Species
-- UNION ALL SELECT 'HabitatPrimarySpecies', COUNT(*) FROM HabitatPrimarySpecies
-- UNION ALL SELECT 'MonitoringRecord', COUNT(*) FROM MonitoringRecord;
