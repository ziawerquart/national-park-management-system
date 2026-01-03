USE national_park_db;

-- =====================================================
-- Base data (FK support)
-- =====================================================

INSERT INTO Region (region_id, region_name, region_type) VALUES
('R01','Core Area','core'),
('R02','Buffer Area','buffer'),
('R03','Experimental Area','experimental');

INSERT INTO User (user_id, user_name, role) VALUES
('U01','Alice','technician'),
('U02','Bob','technician'),
('U03','Charlie','admin');

INSERT INTO MonitoringDevice
(device_id, device_type, install_time, calibration_cycle, run_status, communication_protocol, region_id)
VALUES
('D01','air_sensor','2024-01-01',180,'normal','MQTT','R01'),
('D02','water_sensor','2024-01-05',180,'normal','MQTT','R02'),
('D03','soil_sensor','2024-01-10',365,'offline','HTTP','R03');

-- =====================================================
-- MonitoringIndicator (20)
-- =====================================================

INSERT INTO MonitoringIndicator VALUES
('I01','PM2.5','ug/m3',75,0,'hour'),
('I02','PM10','ug/m3',150,0,'hour'),
('I03','SO2','mg/m3',0.5,0,'hour'),
('I04','NO2','mg/m3',0.2,0,'hour'),
('I05','O3','mg/m3',0.3,0,'hour'),
('I06','CO','mg/m3',10,0,'hour'),
('I07','Temperature','C',50,-20,'hour'),
('I08','Humidity','%',100,0,'hour'),
('I09','WindSpeed','m/s',30,0,'hour'),
('I10','Noise','dB',120,0,'hour'),
('I11','WaterPH','pH',9,6,'day'),
('I12','WaterTurbidity','NTU',50,0,'day'),
('I13','DissolvedOxygen','mg/L',14,0,'day'),
('I14','SoilMoisture','%',60,0,'day'),
('I15','SoilPH','pH',9,5,'day'),
('I16','Radiation','uSv/h',0.3,0,'hour'),
('I17','Rainfall','mm',200,0,'day'),
('I18','Visibility','km',50,0,'hour'),
('I19','UVIndex','index',11,0,'hour'),
('I20','AtmosphericPressure','hPa',1100,900,'hour');

-- =====================================================
-- EnvironmentalData (24)
-- =====================================================

INSERT INTO EnvironmentalData VALUES
('ED01','I01','D01','R01','2024-03-01 08:00',82.5,'poor',TRUE),
('ED02','I01','D01','R01','2024-03-01 09:00',60.0,'good',FALSE),
('ED03','I02','D01','R01','2024-03-01 08:00',160,'poor',TRUE),
('ED04','I03','D01','R01','2024-03-01 08:00',0.3,'good',FALSE),
('ED05','I04','D01','R01','2024-03-01 08:00',0.25,'poor',TRUE),
('ED06','I05','D01','R01','2024-03-01 08:00',0.15,'good',FALSE),

('ED07','I11','D02','R02','2024-03-01 08:00',9.2,'poor',TRUE),
('ED08','I12','D02','R02','2024-03-01 08:00',20,'good',FALSE),
('ED09','I13','D02','R02','2024-03-01 08:00',3.5,'poor',TRUE),
('ED10','I14','D03','R03','2024-03-01 08:00',55,'good',FALSE),
('ED11','I15','D03','R03','2024-03-01 08:00',4.8,'poor',TRUE),
('ED12','I16','D01','R01','2024-03-01 08:00',0.12,'good',FALSE),

('ED13','I07','D01','R01','2024-03-01 10:00',42,'good',FALSE),
('ED14','I08','D01','R01','2024-03-01 10:00',90,'good',FALSE),
('ED15','I09','D01','R01','2024-03-01 10:00',35,'poor',TRUE),
('ED16','I10','D01','R01','2024-03-01 10:00',110,'good',FALSE),
('ED17','I17','D02','R02','2024-03-01 10:00',180,'good',FALSE),
('ED18','I18','D01','R01','2024-03-01 10:00',2,'poor',TRUE),

('ED19','I19','D01','R01','2024-03-01 12:00',9,'good',FALSE),
('ED20','I20','D01','R01','2024-03-01 12:00',880,'poor',TRUE),
('ED21','I06','D01','R01','2024-03-01 12:00',12,'poor',TRUE),
('ED22','I03','D01','R01','2024-03-01 12:00',0.1,'good',FALSE),
('ED23','I04','D01','R01','2024-03-01 12:00',0.18,'good',FALSE),
('ED24','I05','D01','R01','2024-03-01 12:00',0.32,'poor',TRUE);

-- =====================================================
-- CalibrationRecord (20)
-- =====================================================

INSERT INTO CalibrationRecord VALUES
('CR01','D01','2024-01-01','U01','Quarter calibration'),
('CR02','D01','2024-04-01','U01','Quarter calibration'),
('CR03','D01','2024-07-01','U02','Quarter calibration'),
('CR04','D01','2024-10-01','U02','Quarter calibration'),
('CR05','D02','2024-01-05','U01','Quarter calibration'),
('CR06','D02','2024-04-05','U01','Quarter calibration'),
('CR07','D02','2024-07-05','U02','Quarter calibration'),
('CR08','D02','2024-10-05','U02','Quarter calibration'),
('CR09','D03','2024-01-10','U01','Annual calibration'),
('CR10','D03','2024-01-11','U02','Annual calibration'),
('CR11','D01','2023-01-01','U01','History'),
('CR12','D01','2023-04-01','U01','History'),
('CR13','D01','2023-07-01','U02','History'),
('CR14','D01','2023-10-01','U02','History'),
('CR15','D02','2023-01-05','U01','History'),
('CR16','D02','2023-04-05','U01','History'),
('CR17','D02','2023-07-05','U02','History'),
('CR18','D02','2023-10-05','U02','History'),
('CR19','D03','2023-01-10','U01','History'),
('CR20','D03','2023-01-11','U02','History');

-- =====================================================
-- Alert (20)
-- =====================================================

INSERT INTO Alert VALUES
('A01','ED01','2024-03-01 08:05','high','open'),
('A02','ED03','2024-03-01 08:06','high','open'),
('A03','ED05','2024-03-01 08:07','medium','closed'),
('A04','ED07','2024-03-01 08:08','high','open'),
('A05','ED09','2024-03-01 08:09','high','open'),
('A06','ED11','2024-03-01 08:10','medium','closed'),
('A07','ED15','2024-03-01 10:05','medium','open'),
('A08','ED18','2024-03-01 10:06','high','open'),
('A09','ED20','2024-03-01 12:05','high','open'),
('A10','ED21','2024-03-01 12:06','high','open'),
('A11','ED24','2024-03-01 12:07','medium','open'),
('A12','ED01','2024-03-01 13:00','low','closed'),
('A13','ED03','2024-03-01 13:01','medium','closed'),
('A14','ED05','2024-03-01 13:02','medium','closed'),
('A15','ED07','2024-03-01 13:03','high','closed'),
('A16','ED09','2024-03-01 13:04','high','closed'),
('A17','ED11','2024-03-01 13:05','medium','closed'),
('A18','ED15','2024-03-01 13:06','medium','closed'),
('A19','ED18','2024-03-01 13:07','high','closed'),
('A20','ED20','2024-03-01 13:08','high','closed');
