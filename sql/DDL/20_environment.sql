CREATE TABLE MonitoringIndicator (
    indicator_id       VARCHAR(64)  NOT NULL,
    indicator_name     VARCHAR(128) NULL,
    unit               VARCHAR(32)  NULL,
    upper_limit        DECIMAL(10,2) NULL,
    lower_limit        DECIMAL(10,2) NULL,
    monitor_frequency  VARCHAR(32)  NULL,
    CONSTRAINT pk_monitoring_indicator
        PRIMARY KEY (indicator_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;

CREATE TABLE EnvironmentalData (
    data_id        VARCHAR(64)  NOT NULL,
    indicator_id   VARCHAR(64)  NULL,
    device_id      VARCHAR(64)  NULL,
    region_id      VARCHAR(64)  NULL,
    collect_time   DATETIME     NULL,
    monitor_value  DECIMAL(10,2) NULL,
    data_quality   VARCHAR(32)  NULL,
    is_abnormal    BOOLEAN      NULL,
    CONSTRAINT pk_environmental_data
        PRIMARY KEY (data_id),
    CONSTRAINT fk_env_indicator
        FOREIGN KEY (indicator_id)
        REFERENCES MonitoringIndicator(indicator_id),
    CONSTRAINT fk_env_device
        FOREIGN KEY (device_id)
        REFERENCES MonitoringDevice(device_id),
    CONSTRAINT fk_env_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id),
    CONSTRAINT chk_data_quality
        CHECK (data_quality IN ('优', '良', '中', '差'))
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;

CREATE TABLE CalibrationRecord (
    record_id         VARCHAR(64)  NOT NULL,
    device_id         VARCHAR(64)  NULL,
    calibration_time  DATETIME     NULL,
    technician_id     VARCHAR(64)  NULL,
    remark            VARCHAR(255) NULL,
    CONSTRAINT pk_calibration_record
        PRIMARY KEY (record_id),
    CONSTRAINT fk_calibration_device
        FOREIGN KEY (device_id)
        REFERENCES MonitoringDevice(device_id),
    CONSTRAINT fk_calibration_user
        FOREIGN KEY (technician_id)
        REFERENCES User(user_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;

CREATE TABLE Alert (
    alert_id     VARCHAR(64)  NOT NULL,
    data_id      VARCHAR(64)  NULL,
    alert_time   DATETIME     NULL,
    alert_level  VARCHAR(32)  NULL,
    alert_status VARCHAR(32)  NULL,
    CONSTRAINT pk_alert
        PRIMARY KEY (alert_id),
    CONSTRAINT fk_alert_data
        FOREIGN KEY (data_id)
        REFERENCES EnvironmentalData(data_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;
