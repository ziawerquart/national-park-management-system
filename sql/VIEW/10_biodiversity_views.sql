-- Stage4 VIEWs for Biodiversity line (MySQL 8.0)
-- Depends on tables: MonitoringRecord, Species, Habitat, HabitatPrimarySpecies, MonitoringDevice, Region, User

DROP VIEW IF EXISTS v_bio_records_to_verify;
CREATE VIEW v_bio_records_to_verify AS
SELECT
    mr.record_id,
    mr.monitoring_time,
    mr.status,
    mr.monitoring_method,
    mr.count_number,
    mr.longitude,
    mr.latitude,
    mr.image_path,
    mr.behavior_description,
    s.species_id,
    s.species_name_cn,
    s.species_name_latin,
    s.protection_level,
    mr.device_id,
    d.device_type,
    d.run_status,
    mr.recorder_id,
    u.user_name AS recorder_name,
    u.role AS recorder_role,
    COALESCE(d.region_id, h.region_id) AS region_id,
    r.region_name,
    r.region_type
FROM MonitoringRecord mr
LEFT JOIN Species s ON s.species_id = mr.species_id
LEFT JOIN Habitat h ON h.habitat_id = s.habitat_id
LEFT JOIN MonitoringDevice d ON d.device_id = mr.device_id
LEFT JOIN Region r ON r.region_id = COALESCE(d.region_id, h.region_id)
LEFT JOIN User u ON u.user_id = mr.recorder_id
WHERE mr.status = 'to_verify';

DROP VIEW IF EXISTS v_bio_species_protection_stats;
CREATE VIEW v_bio_species_protection_stats AS
SELECT
    protection_level,
    COUNT(*) AS species_count
FROM Species
GROUP BY protection_level;

DROP VIEW IF EXISTS v_bio_habitat_primary_species_summary;
CREATE VIEW v_bio_habitat_primary_species_summary AS
SELECT
    h.habitat_id,
    h.area_name,
    h.ecological_type,
    h.area_size,
    h.core_protection_area,
    h.environment_suitability_score,
    h.region_id,
    r.region_name,
    COUNT(CASE WHEN hps.is_primary = 1 THEN 1 END) AS primary_species_count,
    GROUP_CONCAT(CASE WHEN hps.is_primary = 1 THEN s.species_name_cn END ORDER BY s.species_name_cn SEPARATOR '、') AS primary_species_list_cn
FROM Habitat h
LEFT JOIN Region r ON r.region_id = h.region_id
LEFT JOIN HabitatPrimarySpecies hps ON hps.habitat_id = h.habitat_id
LEFT JOIN Species s ON s.species_id = hps.species_id
GROUP BY
    h.habitat_id, h.area_name, h.ecological_type, h.area_size, h.core_protection_area, h.environment_suitability_score, h.region_id, r.region_name;

DROP VIEW IF EXISTS v_bio_region_last30d_monitoring_stats;
CREATE VIEW v_bio_region_last30d_monitoring_stats AS
SELECT
    COALESCE(d.region_id, h.region_id) AS region_id,
    r.region_name,
    DATE(mr.monitoring_time) AS stat_date,
    COUNT(*) AS record_count,
    COUNT(DISTINCT mr.species_id) AS distinct_species_count,
    COUNT(DISTINCT mr.device_id) AS distinct_device_count,
    SUM(CASE WHEN mr.status = 'to_verify' THEN 1 ELSE 0 END) AS to_verify_count,
    SUM(CASE WHEN mr.status = 'valid' THEN 1 ELSE 0 END) AS valid_count
FROM MonitoringRecord mr
LEFT JOIN Species s ON s.species_id = mr.species_id
LEFT JOIN Habitat h ON h.habitat_id = s.habitat_id
LEFT JOIN MonitoringDevice d ON d.device_id = mr.device_id
LEFT JOIN Region r ON r.region_id = COALESCE(d.region_id, h.region_id)
WHERE mr.monitoring_time >= (NOW() - INTERVAL 30 DAY)
GROUP BY
    COALESCE(d.region_id, h.region_id),
    r.region_name,
    DATE(mr.monitoring_time);
