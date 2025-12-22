/* =========================
   Habitat
   ========================= */
ALTER TABLE Habitat
ADD CONSTRAINT fk_habitat_region
FOREIGN KEY (region_id)
REFERENCES Region(region_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   MonitoringRecord
   ========================= */
ALTER TABLE MonitoringRecord
ADD CONSTRAINT fk_monitoring_record_device
FOREIGN KEY (device_id)
REFERENCES MonitoringDevice(device_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

ALTER TABLE MonitoringRecord
ADD CONSTRAINT fk_monitoring_record_user
FOREIGN KEY (recorder_id)
REFERENCES User(user_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   EnvironmentalData
   ========================= */
ALTER TABLE EnvironmentalData
ADD CONSTRAINT fk_environmental_data_device
FOREIGN KEY (device_id)
REFERENCES MonitoringDevice(device_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

ALTER TABLE EnvironmentalData
ADD CONSTRAINT fk_environmental_data_region
FOREIGN KEY (region_id)
REFERENCES Region(region_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   CalibrationRecord
   ========================= */
ALTER TABLE CalibrationRecord
ADD CONSTRAINT fk_calibration_record_device
FOREIGN KEY (device_id)
REFERENCES MonitoringDevice(device_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

ALTER TABLE CalibrationRecord
ADD CONSTRAINT fk_calibration_record_technician
FOREIGN KEY (technician_id)
REFERENCES User(user_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   VisitorTrajectory
   ========================= */
ALTER TABLE VisitorTrajectory
ADD CONSTRAINT fk_visitor_trajectory_region
FOREIGN KEY (region_id)
REFERENCES Region(region_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   LawEnforcementOfficer
   ========================= */
ALTER TABLE LawEnforcementOfficer
ADD CONSTRAINT fk_law_enforcement_user
FOREIGN KEY (user_id)
REFERENCES User(user_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

ALTER TABLE LawEnforcementOfficer
ADD CONSTRAINT fk_law_enforcement_device
FOREIGN KEY (device_id)
REFERENCES MonitoringDevice(device_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   VideoMonitorPoint
   ========================= */
ALTER TABLE VideoMonitorPoint
ADD CONSTRAINT fk_video_monitor_point_region
FOREIGN KEY (region_id)
REFERENCES Region(region_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   IllegalBehaviorRecord
   ========================= */
ALTER TABLE IllegalBehaviorRecord
ADD CONSTRAINT fk_illegal_behavior_region
FOREIGN KEY (region_id)
REFERENCES Region(region_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   ResearchProject
   ========================= */
ALTER TABLE ResearchProject
ADD CONSTRAINT fk_research_project_leader
FOREIGN KEY (leader_id)
REFERENCES User(user_id)
ON UPDATE CASCADE
ON DELETE SET NULL;


/* =========================
   ResearchDataRecord
   ========================= */
ALTER TABLE ResearchDataRecord
ADD CONSTRAINT fk_research_data_collector
FOREIGN KEY (collector_id)
REFERENCES User(user_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

ALTER TABLE ResearchDataRecord
ADD CONSTRAINT fk_research_data_region
FOREIGN KEY (region_id)
REFERENCES Region(region_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

ALTER TABLE ResearchDataRecord
ADD CONSTRAINT fk_research_data_verifier
FOREIGN KEY (verified_by)
REFERENCES User(user_id)
ON UPDATE CASCADE
ON DELETE SET NULL;
