-- ============================================================================
-- Research Database DDL Script
-- File: 50_Research.sql
-- Description: Database schema for research project management system
-- Author: Even
-- Date: 2024-12-22
-- ============================================================================

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS MonitoringRecord;
DROP TABLE IF EXISTS HabitatPrimarySpecies;
DROP TABLE IF EXISTS ResearchResult;
DROP TABLE IF EXISTS ResearchDataCollection;
DROP TABLE IF EXISTS ResearchProject;
DROP TABLE IF EXISTS Habitat;
DROP TABLE IF EXISTS Species;
DROP TABLE IF EXISTS User;

-- ============================================================================
-- Core Entity Tables
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: User
-- Description: Stores user information including researchers and administrators
-- Primary Key: user_id
-- ----------------------------------------------------------------------------
CREATE TABLE User (
    user_id VARCHAR(50) PRIMARY KEY COMMENT 'User unique identifier',
    name VARCHAR(100) NOT NULL COMMENT 'User full name',
    role VARCHAR(50) NOT NULL COMMENT 'User role (e.g., Researcher, Admin, PI)'
) COMMENT='User information table';

-- ----------------------------------------------------------------------------
-- Table: Species
-- Description: Stores species information for biodiversity research
-- Primary Key: species_id
-- ----------------------------------------------------------------------------
CREATE TABLE Species (
    species_id VARCHAR(50) PRIMARY KEY COMMENT 'Species unique identifier',
    scientific_name VARCHAR(200) NOT NULL COMMENT 'Scientific name (Latin name)',
    common_name VARCHAR(200) COMMENT 'Common name',
    protection_level VARCHAR(50) COMMENT 'Protection level (e.g., Endangered, Vulnerable)'
) COMMENT='Species information table';

-- ----------------------------------------------------------------------------
-- Table: Habitat
-- Description: Stores habitat information where species are observed
-- Primary Key: habitat_id
-- ----------------------------------------------------------------------------
CREATE TABLE Habitat (
    habitat_id VARCHAR(50) PRIMARY KEY COMMENT 'Habitat unique identifier',
    habitat_name VARCHAR(200) NOT NULL COMMENT 'Habitat name',
    region_code VARCHAR(50) COMMENT 'Geographic region code'
) COMMENT='Habitat information table';

-- ----------------------------------------------------------------------------
-- Table: ResearchProject
-- Description: Stores research project information
-- Primary Key: project_id
-- Foreign Keys: principal_investigator_id -> User(user_id)
--               leader_user_id -> User(user_id)
-- ----------------------------------------------------------------------------
CREATE TABLE ResearchProject (
    project_id VARCHAR(50) PRIMARY KEY COMMENT 'Project unique identifier',
    project_name VARCHAR(200) NOT NULL COMMENT 'Project name',
    principal_investigator_id VARCHAR(50) NOT NULL COMMENT 'Principal investigator ID',
    applicant_organization VARCHAR(200) COMMENT 'Organization applying for the project',
    start_time DATE COMMENT 'Project start date',
    end_time DATE COMMENT 'Project end date',
    project_status ENUM('InProgress', 'Completed', 'Suspended') NOT NULL DEFAULT 'InProgress' COMMENT 'Project status',
    research_field VARCHAR(200) COMMENT 'Research field or domain',
    leader_user_id VARCHAR(50) COMMENT 'Project leader user ID',
    
    -- Foreign key constraints
    CONSTRAINT fk_project_pi FOREIGN KEY (principal_investigator_id) 
        REFERENCES User(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_project_leader FOREIGN KEY (leader_user_id) 
        REFERENCES User(user_id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Check constraints
    CONSTRAINT chk_project_dates CHECK (end_time IS NULL OR end_time >= start_time)
) COMMENT='Research project information table';

-- ----------------------------------------------------------------------------
-- Table: ResearchDataCollection
-- Description: Stores data collection records for research projects
-- Primary Key: collection_id
-- Foreign Keys: project_id -> ResearchProject(project_id)
-- ----------------------------------------------------------------------------
CREATE TABLE ResearchDataCollection (
    collection_id VARCHAR(50) PRIMARY KEY COMMENT 'Collection unique identifier',
    collection_time DATETIME NOT NULL COMMENT 'Data collection timestamp',
    collector_id VARCHAR(50) COMMENT 'Collector user ID',
    area_id VARCHAR(50) COMMENT 'Collection area identifier',
    collection_content TEXT COMMENT 'Description of collected data',
    data_source ENUM('FieldCollection', 'SystemReference') NOT NULL COMMENT 'Source of the data',
    project_id VARCHAR(50) NOT NULL COMMENT 'Associated project ID',
    
    -- Foreign key constraints
    CONSTRAINT fk_collection_project FOREIGN KEY (project_id) 
        REFERENCES ResearchProject(project_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT='Research data collection records table';

-- ----------------------------------------------------------------------------
-- Table: ResearchResult
-- Description: Stores research output results (papers, reports, patents, etc.)
-- Primary Key: result_id
-- Foreign Keys: project_id -> ResearchProject(project_id)
-- ----------------------------------------------------------------------------
CREATE TABLE ResearchResult (
    result_id VARCHAR(50) PRIMARY KEY COMMENT 'Result unique identifier',
    result_type ENUM('Paper', 'Report', 'Patent', 'Other') NOT NULL COMMENT 'Type of research result',
    result_name VARCHAR(300) NOT NULL COMMENT 'Name or title of the result',
    publish_time DATE COMMENT 'Publication or submission date',
    access_level ENUM('Public', 'Internal', 'Confidential') NOT NULL DEFAULT 'Internal' COMMENT 'Access control level',
    file_path VARCHAR(500) COMMENT 'File path or URL to the result document',
    project_id VARCHAR(50) NOT NULL COMMENT 'Associated project ID',
    
    -- Foreign key constraints
    CONSTRAINT fk_result_project FOREIGN KEY (project_id) 
        REFERENCES ResearchProject(project_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT='Research results table';

-- ----------------------------------------------------------------------------
-- Table: HabitatPrimarySpecies
-- Description: Many-to-many relationship between Habitat and Species
-- Primary Key: id
-- Foreign Keys: habitat_id -> Habitat(habitat_id)
--               species_id -> Species(species_id)
-- ----------------------------------------------------------------------------
CREATE TABLE HabitatPrimarySpecies (
    id VARCHAR(50) PRIMARY KEY COMMENT 'Relationship unique identifier',
    habitat_id VARCHAR(50) NOT NULL COMMENT 'Habitat ID',
    species_id VARCHAR(50) NOT NULL COMMENT 'Species ID',
    
    -- Foreign key constraints
    CONSTRAINT fk_hps_habitat FOREIGN KEY (habitat_id) 
        REFERENCES Habitat(habitat_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_hps_species FOREIGN KEY (species_id) 
        REFERENCES Species(species_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Unique constraint to prevent duplicate relationships
    CONSTRAINT uk_habitat_species UNIQUE (habitat_id, species_id)
) COMMENT='Habitat primary species relationship table';

-- ----------------------------------------------------------------------------
-- Table: MonitoringRecord
-- Description: Stores monitoring data records with references to habitat and species
-- Primary Key: record_id
-- Foreign Keys: habitat_id -> Habitat(habitat_id)
--               species_id -> Species(species_id)
--               collection_id -> ResearchDataCollection(collection_id)
-- ----------------------------------------------------------------------------
CREATE TABLE MonitoringRecord (
    record_id VARCHAR(50) PRIMARY KEY COMMENT 'Record unique identifier',
    monitor_time DATETIME NOT NULL COMMENT 'Monitoring timestamp',
    data_type VARCHAR(100) NOT NULL COMMENT 'Type of data being monitored',
    data_value VARCHAR(500) COMMENT 'Monitored data value',
    habitat_id VARCHAR(50) COMMENT 'Associated habitat ID',
    species_id VARCHAR(50) COMMENT 'Associated species ID',
    collection_id VARCHAR(50) COMMENT 'Associated collection ID',
    
    -- Foreign key constraints
    CONSTRAINT fk_monitor_habitat FOREIGN KEY (habitat_id) 
        REFERENCES Habitat(habitat_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_monitor_species FOREIGN KEY (species_id) 
        REFERENCES Species(species_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_monitor_collection FOREIGN KEY (collection_id) 
        REFERENCES ResearchDataCollection(collection_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT='Monitoring records table';

-- ============================================================================
-- Indexes for Performance Optimization
-- ============================================================================

-- User table indexes
CREATE INDEX idx_user_role ON User(role);

-- Species table indexes
CREATE INDEX idx_species_scientific_name ON Species(scientific_name);
CREATE INDEX idx_species_protection_level ON Species(protection_level);

-- Habitat table indexes
CREATE INDEX idx_habitat_region ON Habitat(region_code);

-- ResearchProject table indexes
CREATE INDEX idx_project_status ON ResearchProject(project_status);
CREATE INDEX idx_project_dates ON ResearchProject(start_time, end_time);
CREATE INDEX idx_project_field ON ResearchProject(research_field);

-- ResearchDataCollection table indexes
CREATE INDEX idx_collection_time ON ResearchDataCollection(collection_time);
CREATE INDEX idx_collection_project ON ResearchDataCollection(project_id);
CREATE INDEX idx_collection_source ON ResearchDataCollection(data_source);

-- ResearchResult table indexes
CREATE INDEX idx_result_type ON ResearchResult(result_type);
CREATE INDEX idx_result_access ON ResearchResult(access_level);
CREATE INDEX idx_result_publish_time ON ResearchResult(publish_time);
CREATE INDEX idx_result_project ON ResearchResult(project_id);

-- MonitoringRecord table indexes
CREATE INDEX idx_monitor_time ON MonitoringRecord(monitor_time);
CREATE INDEX idx_monitor_data_type ON MonitoringRecord(data_type);
CREATE INDEX idx_monitor_habitat ON MonitoringRecord(habitat_id);
CREATE INDEX idx_monitor_species ON MonitoringRecord(species_id);
CREATE INDEX idx_monitor_collection ON MonitoringRecord(collection_id);

-- HabitatPrimarySpecies table indexes
CREATE INDEX idx_hps_habitat ON HabitatPrimarySpecies(habitat_id);
CREATE INDEX idx_hps_species ON HabitatPrimarySpecies(species_id);

-- ============================================================================
-- Sample Data Insertion (Optional - for testing)
-- ============================================================================

-- Insert sample users
INSERT INTO User (user_id, name, role) VALUES
('U001', 'Dr. Zhang Wei', 'Principal Investigator'),
('U002', 'Dr. Li Ming', 'Researcher'),
('U003', 'Wang Fang', 'Data Collector'),
('U004', 'Prof. Chen Jun', 'Project Leader');

-- Insert sample species
INSERT INTO Species (species_id, scientific_name, common_name, protection_level) VALUES
('SP001', 'Panthera tigris', 'Tiger', 'Endangered'),
('SP002', 'Ailuropoda melanoleuca', 'Giant Panda', 'Vulnerable'),
('SP003', 'Grus japonensis', 'Red-crowned Crane', 'Endangered');

-- Insert sample habitats
INSERT INTO Habitat (habitat_id, habitat_name, region_code) VALUES
('HB001', 'Changbai Mountain Forest', 'CN-JL-001'),
('HB002', 'Sichuan Bamboo Forest', 'CN-SC-002'),
('HB003', 'Zhalong Wetland', 'CN-HL-003');

-- Insert sample research project
INSERT INTO ResearchProject (project_id, project_name, principal_investigator_id, 
                              applicant_organization, start_time, end_time, 
                              project_status, research_field, leader_user_id) VALUES
('PRJ001', 'Biodiversity Conservation in Northeast China', 'U001', 
 'Beijing University', '2024-01-01', '2026-12-31', 
 'InProgress', 'Conservation Biology', 'U004');

-- Insert sample data collection
INSERT INTO ResearchDataCollection (collection_id, collection_time, collector_id, 
                                     area_id, collection_content, data_source, project_id) VALUES
('DC001', '2024-06-15 10:30:00', 'U003', 'HB001', 
 'Field survey of tiger population', 'FieldCollection', 'PRJ001');

-- Insert sample research result
INSERT INTO ResearchResult (result_id, result_type, result_name, publish_time, 
                             access_level, file_path, project_id) VALUES
('RES001', 'Paper', 'Population Dynamics of Siberian Tigers in Changbai Mountain', 
 '2024-11-01', 'Public', '/results/2024/tiger_dynamics.pdf', 'PRJ001');

-- Insert sample habitat-species relationships
INSERT INTO HabitatPrimarySpecies (id, habitat_id, species_id) VALUES
('HPS001', 'HB001', 'SP001'),
('HPS002', 'HB002', 'SP002'),
('HPS003', 'HB003', 'SP003');

-- Insert sample monitoring record
INSERT INTO MonitoringRecord (record_id, monitor_time, data_type, data_value, 
                               habitat_id, species_id, collection_id) VALUES
('MR001', '2024-06-15 10:30:00', 'Population Count', '15', 
 'HB001', 'SP001', 'DC001');

-- ============================================================================
-- End of Script
-- ============================================================================