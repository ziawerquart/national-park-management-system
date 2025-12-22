-- 10_biodiversity.sql
-- MySQL 8.0.43 (or compatible)
-- Biodiversity module DDL: Habitat, Species, HabitatPrimarySpecies, MonitoringRecord
-- Note: Cross-file foreign keys (to global tables like Region/User/MonitoringDevice) are intentionally NOT created here.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =========================
-- Table: Habitat
-- =========================
CREATE TABLE IF NOT EXISTS Habitat (
  habitat_id VARCHAR(64) NOT NULL COMMENT '栖息地基站ID',
  area_name VARCHAR(128) NULL COMMENT '区域名称',
  ecological_type VARCHAR(32) NULL COMMENT '生态类型(森林/湿地/草原等)',
  area_size DECIMAL(10,2) NULL COMMENT '面积(平方公里)',
  core_protection_area VARCHAR(255) NULL COMMENT '核心保护区描述',
  environment_suitability_score DECIMAL(5,2) NULL COMMENT '环境适宜度评分',
  region_id VARCHAR(64) NULL COMMENT '所属区域ID(跨文件: Region.region_id)',
  PRIMARY KEY (habitat_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='栖息地表';

-- Optional index for later FK join (no FK here by requirement)
CREATE INDEX idx_habitat_region_id ON Habitat(region_id);

-- =========================
-- Table: Species
-- =========================
CREATE TABLE IF NOT EXISTS Species (
  species_id VARCHAR(64) NOT NULL COMMENT '物种ID',
  species_name_cn VARCHAR(128) NULL COMMENT '物种中文名',
  species_name_latin VARCHAR(128) NULL COMMENT '物种拉丁名',
  kingdom VARCHAR(32) NULL COMMENT '界',
  phylum VARCHAR(32) NULL COMMENT '门',
  tax_class VARCHAR(32) NULL COMMENT '纲',
  tax_order VARCHAR(32) NULL COMMENT '目',
  family VARCHAR(32) NULL COMMENT '科',
  genus VARCHAR(32) NULL COMMENT '属',
  species VARCHAR(32) NULL COMMENT '种(分类学)',
  protection_level VARCHAR(32) NULL COMMENT '保护级别(first_class/second_class/none)',
  living_habits TEXT NULL COMMENT '生活习性',
  distribution_description VARCHAR(255) NULL COMMENT '分布描述',
  habitat_id VARCHAR(64) NULL COMMENT '栖息地基站ID',
  PRIMARY KEY (species_id),
  CONSTRAINT fk_species_habitat
    FOREIGN KEY (habitat_id) REFERENCES Habitat(habitat_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_species_protection_level
    CHECK (protection_level IS NULL OR protection_level IN ('first_class','second_class','none'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='物种表';

CREATE INDEX idx_species_habitat_id ON Species(habitat_id);

-- =========================
-- Table: HabitatPrimarySpecies (N:M bridge)
-- =========================
CREATE TABLE IF NOT EXISTS HabitatPrimarySpecies (
  habitat_id VARCHAR(64) NOT NULL COMMENT '栖息地基站ID',
  species_id VARCHAR(64) NOT NULL COMMENT '物种ID',
  is_primary BOOLEAN NULL COMMENT '是否主要物种(0/1)',
  PRIMARY KEY (habitat_id, species_id),
  CONSTRAINT fk_hps_habitat
    FOREIGN KEY (habitat_id) REFERENCES Habitat(habitat_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_hps_species
    FOREIGN KEY (species_id) REFERENCES Species(species_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='栖息地-主要物种关联表';

CREATE INDEX idx_hps_species_id ON HabitatPrimarySpecies(species_id);

-- =========================
-- Table: MonitoringRecord
-- =========================
CREATE TABLE IF NOT EXISTS MonitoringRecord (
  record_id VARCHAR(64) NOT NULL COMMENT '监测记录ID',
  species_id VARCHAR(64) NULL COMMENT '物种ID',
  device_id VARCHAR(64) NULL COMMENT '监测设备ID(跨文件: MonitoringDevice.device_id)',
  monitoring_time DATETIME NULL COMMENT '监测时间',
  longitude DECIMAL(10,6) NULL COMMENT '经度',
  latitude DECIMAL(10,6) NULL COMMENT '纬度',
  monitoring_method VARCHAR(32) NULL COMMENT '监测方式(camera/manual/drone)',
  image_path VARCHAR(512) NULL COMMENT '图片/影像路径',
  count_number INT NULL COMMENT '数量统计',
  behavior_description VARCHAR(255) NULL COMMENT '行为描述',
  recorder_id VARCHAR(64) NULL COMMENT '记录人ID(跨文件: User.user_id)',
  status VARCHAR(32) NULL COMMENT '记录状态(pending/rechecked/valid)',
  PRIMARY KEY (record_id),
  CONSTRAINT fk_mr_species
    FOREIGN KEY (species_id) REFERENCES Species(species_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_mr_method
    CHECK (monitoring_method IS NULL OR monitoring_method IN ('camera','manual','drone')),
  CONSTRAINT chk_mr_status
    CHECK (status IS NULL OR status IN ('pending','rechecked','valid'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='生物监测记录表';

CREATE INDEX idx_mr_species_id ON MonitoringRecord(species_id);
CREATE INDEX idx_mr_device_id ON MonitoringRecord(device_id);
CREATE INDEX idx_mr_recorder_id ON MonitoringRecord(recorder_id);
CREATE INDEX idx_mr_time ON MonitoringRecord(monitoring_time);

SET FOREIGN_KEY_CHECKS = 1;
