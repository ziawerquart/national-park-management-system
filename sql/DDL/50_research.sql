-- ================================================================
-- national_park_db - Research Module
-- MERGED & CORRECTED DDL (Fully Compatible with UML)
-- ================================================================

CREATE DATABASE IF NOT EXISTS national_park_db
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_general_ci;

USE national_park_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ================================================================
-- 1. Region
-- ================================================================
DROP TABLE IF EXISTS Region;
CREATE TABLE Region (
region_id   VARCHAR(10) PRIMARY KEY,
region_name VARCHAR(100) NOT NULL,
region_type VARCHAR(50)  NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- 2. User (reserved keyword, quoted)
-- ================================================================
DROP TABLE IF EXISTS `User`;
CREATE TABLE `User` (
user_id   VARCHAR(10) PRIMARY KEY,
user_name VARCHAR(100) NOT NULL,
role      VARCHAR(50)  NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- 3. ResearchProject
-- ================================================================
DROP TABLE IF EXISTS ResearchProject;
CREATE TABLE ResearchProject (
project_id          VARCHAR(10) PRIMARY KEY,
project_name        VARCHAR(200) NOT NULL,
leader_id           VARCHAR(10)  NOT NULL,
apply_organization  VARCHAR(200),
approval_date       DATE NOT NULL,
completion_date     DATE,
project_status      ENUM('ongoing','completed','paused') NOT NULL,
research_field      VARCHAR(100),
description         TEXT,

```
CONSTRAINT fk_project_leader
    FOREIGN KEY (leader_id) REFERENCES `User`(user_id)
```

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- 4. ResearchDataRecord
-- ================================================================
DROP TABLE IF EXISTS ResearchDataRecord;
CREATE TABLE ResearchDataRecord (
collection_id        VARCHAR(10) PRIMARY KEY,
project_id           VARCHAR(10) NOT NULL,
collector_id         VARCHAR(10) NOT NULL,
collection_time      DATETIME NOT NULL,
region_id            VARCHAR(10) NOT NULL,
collection_content   TEXT,
data_source          ENUM('field','system') NOT NULL,
sample_id            VARCHAR(20),
monitoring_data_id   VARCHAR(20),
data_file_path       VARCHAR(255),
remarks              VARCHAR(255),
is_verified           BOOLEAN NOT NULL DEFAULT FALSE,
verified_by          VARCHAR(10),
verified_at          DATETIME,

```
CONSTRAINT fk_record_project
    FOREIGN KEY (project_id) REFERENCES ResearchProject(project_id),

CONSTRAINT fk_record_collector
    FOREIGN KEY (collector_id) REFERENCES `User`(user_id),

CONSTRAINT fk_record_region
    FOREIGN KEY (region_id) REFERENCES Region(region_id),

CONSTRAINT fk_record_verified_by
    FOREIGN KEY (verified_by) REFERENCES `User`(user_id)
```

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- 5. ResearchAchievement
-- ================================================================
DROP TABLE IF EXISTS ResearchAchievement;
CREATE TABLE ResearchAchievement (
achievement_id     VARCHAR(10) PRIMARY KEY,
project_id         VARCHAR(10) NOT NULL,
achievement_type   ENUM('paper','report','patent','other') NOT NULL,
achievement_name   VARCHAR(255) NOT NULL,
submit_time        DATE NOT NULL,
file_path          VARCHAR(255),
share_permission   ENUM('public','internal','confidential') NOT NULL,

```
CONSTRAINT fk_achievement_project
    FOREIGN KEY (project_id) REFERENCES ResearchProject(project_id)
```

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- END OF MERGED DDL
-- ================================================================
