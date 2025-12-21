
CREATE TABLE Region (
    region_id   VARCHAR(64)  NOT NULL,
    region_name VARCHAR(128) NULL,
    region_type VARCHAR(32)  NULL,
    CONSTRAINT pk_region PRIMARY KEY (region_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;

CREATE TABLE User (
    user_id   VARCHAR(64)  NOT NULL,
    user_name VARCHAR(128) NULL,
    role      VARCHAR(32)  NULL,
    CONSTRAINT pk_user PRIMARY KEY (user_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;

CREATE TABLE MonitoringDevice (
    device_id              VARCHAR(64)  NOT NULL,
    device_type            VARCHAR(32)  NULL,
    install_time           DATETIME     NULL,
    calibration_cycle      INT           NULL,
    run_status             VARCHAR(32)  NULL,
    communication_protocol VARCHAR(64)  NULL,
    region_id              VARCHAR(64)  NULL,

    CONSTRAINT pk_monitoring_device PRIMARY KEY (device_id),
    CONSTRAINT fk_device_region
        FOREIGN KEY (region_id)
        REFERENCES Region(region_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4;
