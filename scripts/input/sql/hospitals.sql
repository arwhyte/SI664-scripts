-- Data set: https://www.kaggle.com/rush4ratio/video-game-sales-with-ratings (22 Dec 2016)

--
-- 1.0 Setup. Delete tables after every build iteration.
--
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS city, hospital, temp_hospital;
SET FOREIGN_KEY_CHECKS=1;

--
-- 2.0 ENTITIES
-- Serve as lookup tables
--

-- Provider ID,Hospital Name,Address,City,State,ZIP Code,Hospital Type,Hospital Ownership,
-- Hospital overall rating,Mortality national comparison,Safety of care national comparison,
-- Readmission national comparison,Effectiveness of care national comparison

--
-- 2.1 temp_hospital table
--
CREATE TABLE IF NOT EXISTS temp_hospital (
  hospital_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  hospital_provider_identifier CHAR(6) NOT NULL UNIQUE,
  hospital_name VARCHAR(255) NOT NULL,
  address VARCHAR(255) NULL,
  city_name VARCHAR(255) NULL,
  zip_code CHAR(10) NULL,
  PRIMARY KEY (hospital_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/hospitals/hospital_info_trimmed.csv'
INTO TABLE temp_hospital
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (hospital_provider_identifier, hospital_name,
  address, city_name, zip_code, @dummy, @dummy,
  @dummy, @dummy, @dummy, @dummy, @dummy, @dummy
  );

CREATE TABLE IF NOT EXISTS city (
  city_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  city_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (city_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/hospitals/hosp_city.csv'
INTO TABLE city
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (city_name);

CREATE TABLE IF NOT EXISTS hospital (
  hospital_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  hospital_provider_identifier CHAR(6) NOT NULL UNIQUE,
  hospital_name VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL,
  city_id INTEGER NOT NULL,
  zip_code CHAR(10) NOT NULL,
  PRIMARY KEY (hospital_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO hospital (
      hospital_provider_identifier,
      hospital_name,
      address,
      city_id,
      zip_code
)
SELECT th.hospital_provider_identifier,
       th.hospital_name, th.address, cit.city_id, th.zip_code
  FROM temp_hospital th
       LEFT JOIN city cit
              ON TRIM(th.city_name) = TRIM(cit.city_name)
ORDER BY th.hospital_provider_identifier;
