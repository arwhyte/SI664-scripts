--
-- 1.0 Setup. Delete tables after every build iteration.
--
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS artwork, artwork_type, classification, city, country, department,
                     region, repository, temp_artwork, temp_city, temp_classification, temp_region;
SET FOREIGN_KEY_CHECKS=1;

--
-- 2.0 ENTITIES
-- Serve as lookup tables
--

--
-- 2.1 artwork type table
--
CREATE TABLE IF NOT EXISTS artwork_type (
  artwork_type_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  artwork_type_name VARCHAR(255) NOT NULL UNIQUE,
  PRIMARY KEY (artwork_type_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_artwork_types.csv'
INTO TABLE artwork_type
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (artwork_type_name);

--
-- 2.2 country table
-- Note: this data is not clean.
--
CREATE TABLE IF NOT EXISTS country (
  country_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  country_name VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (country_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_countries.csv'
INTO TABLE country
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (country_name);

--
-- 2.3 temp city table
-- Temp table includes lookup country_name.
--
CREATE TABLE IF NOT EXISTS temp_city (
  temp_city_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  city_name VARCHAR(255) NOT NULL UNIQUE,
  country_name VARCHAR(255) NULL,
  PRIMARY KEY (temp_city_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_cities.csv'
INTO TABLE temp_city
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (city_name, country_name);

--
-- 2.4 city table
--
CREATE TABLE IF NOT EXISTS city (
  city_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  city_name VARCHAR(255) NOT NULL UNIQUE,
  country_id INTEGER NULL,
  PRIMARY KEY (city_id),
  FOREIGN KEY (country_id) REFERENCES country(country_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

INSERT IGNORE INTO city (
  city_name,
  country_id
)
SELECT tc.city_name, c.country_id
  FROM temp_city tc
       LEFT JOIN country c
              ON TRIM(tc.country_name) = TRIM(c.country_name)
WHERE TRIM(tc.city_name) IS NOT NULL AND TRIM(tc.city_name) != ''
ORDER BY tc.city_name;

--
-- 2.5 temp region table
-- Temp table includes lookup country_name.
--
CREATE TABLE IF NOT EXISTS temp_region (
  temp_region_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  region_name VARCHAR(255) NOT NULL UNIQUE,
  country_name VARCHAR(255) NULL,
  PRIMARY KEY (temp_region_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_regions.csv'
INTO TABLE temp_region
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (region_name, country_name);

--
-- 2.5 region table
--
CREATE TABLE IF NOT EXISTS region (
  region_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  region_name VARCHAR(255) NOT NULL UNIQUE,
  country_id INTEGER NULL,
  PRIMARY KEY (region_id),
  FOREIGN KEY (country_id) REFERENCES country(country_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

INSERT IGNORE INTO region (
  region_name,
  country_id
)
SELECT tr.region_name, c.country_id
  FROM temp_region tr
       LEFT JOIN country c
              ON TRIM(tr.country_name) = TRIM(c.country_name)
WHERE TRIM(tr.region_name) IS NOT NULL AND TRIM(tr.region_name) != ''
ORDER BY tr.region_name;

--
-- 2.6 temp classification table
-- Temp table required because source data is messy.
--
CREATE TABLE IF NOT EXISTS temp_classification (
  temp_classification_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  classification_name VARCHAR(255) NOT NULL UNIQUE,
  PRIMARY KEY (temp_classification_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_classifications.csv'
INTO TABLE temp_classification
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (classification_name);

--
-- 2.7 classification table
--
CREATE TABLE IF NOT EXISTS classification (
  classification_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  classification_name VARCHAR(255) NOT NULL UNIQUE,
  PRIMARY KEY (classification_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

INSERT IGNORE INTO classification
(
  classification_name
)
SELECT classification_name
FROM temp_classification tc
WHERE TRIM(tc.classification_name) NOT like ',%'
ORDER BY tc.temp_classification_id;

--
-- 2.8 department table
--
CREATE TABLE IF NOT EXISTS department (
  department_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  department_name VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (department_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_departments.csv'
INTO TABLE department
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (department_name);

--
-- 2.8 repository table
--
CREATE TABLE IF NOT EXISTS repository (
  repository_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  repository_name VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (repository_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_repositories.csv'
INTO TABLE repository
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (repository_name);

--
-- 3.0 CORE ENTITIES AND M2M TABLES (developer, game, game_developer, sale)
--

--
-- 3.1 Temporary artwork table
--

-- https://dev.mysql.com/doc/refman/8.0/en/charset-we-sets.html
-- Character set = Windows-1252 = cp1252 = latin1
-- Collation = latin1_swedish_ci (default)

-- Object Number
-- Is Public Domain
-- Department
-- Object Name
-- Title
-- Culture
-- Artist Role
-- Artist Prefix
-- Artist Display Name
-- Artist Suffix
-- Artist Alpha Sort
-- Artist Nationality
-- Artist Begin Date
-- Artist End Date
-- Object Date
-- Object Begin Date
-- Object End Date
-- Medium
-- Dimensions
-- Credit Line (acquired_from)
-- Acquisition Date
-- City
-- State
-- County
-- Country
-- Region
-- Classification
-- Rights and Reproduction
-- Link Resource
-- Repository

CREATE TABLE IF NOT EXISTS temp_artwork (
  temp_artwork_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  accession_number VARCHAR(50) NULL,
  is_public_domain CHAR(5) NULL,
  department_name VARCHAR(75) NULL,
  artwork_type_name VARCHAR(255) NULL,
  title VARCHAR(500) NULL,
  culture VARCHAR(255) NULL,
  year_begin_end VARCHAR(255) NULL,
  year_begin VARCHAR(10) NULL,
  year_end VARCHAR(10) NULL,
  medium VARCHAR(500) NULL,
  dimensions VARCHAR(750) NULL,
  acquired_from VARCHAR(1000) NULL,
  -- year_acquired VARCHAR(10) NULL,
  city_name VARCHAR(255) NULL,
  state_name VARCHAR(255) NULL,
  county_name VARCHAR(255) NULL,
  country_name VARCHAR(255) NULL,
  region_name VARCHAR(255) NULL,
  classification_name VARCHAR(100) NULL,
  rights_and_reproduction VARCHAR(255) NULL,
  resource_link VARCHAR(255) NULL,
  repository_name VARCHAR(100) NULL,
  PRIMARY KEY (temp_artwork_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_artwork-trimmed.csv'
INTO TABLE temp_artwork
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  -- FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (accession_number, is_public_domain, department_name, artwork_type_name, title, culture,
    @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy,
    year_begin_end, year_begin, year_end, medium, dimensions, acquired_from, @dummy,
    city_name, state_name, county_name, country_name, region_name, classification_name,
    rights_and_reproduction, resource_link, repository_name
  )

  --
  -- WARNING: year_begin, year_end can contain negative values as well as at least one word 'pain'.
  -- Use CONCAT carefully
  --
  SET accession_number = IF(LENGTH(TRIM(accession_number)) > 0, TRIM(accession_number), NULL),
  is_public_domain = IF(LENGTH(TRIM(is_public_domain)) > 0, TRIM(is_public_domain), NULL),
  department_name = IF(LENGTH(TRIM(department_name)) > 0, TRIM(department_name), NULL),
  artwork_type_name = IF(LENGTH(TRIM(artwork_type_name)) > 0, TRIM(artwork_type_name), NULL),
  title = IF(LENGTH(TRIM(title)) > 0, TRIM(title), NULL),
  culture = IF(LENGTH(TRIM(culture)) > 0, TRIM(culture), NULL),
  year_begin_end = IF(LENGTH(TRIM(year_begin_end)) > 0, TRIM(year_begin_end), NULL),
  year_begin = IF(year_begin IS NULL OR TRIM(year_begin) = ''
        OR LENGTH(CONCAT('', TRIM(year_begin)) * 1) = 0, NULL, TRIM(year_begin)),
  year_end = IF(year_end IS NULL OR TRIM(year_end) = ''
        OR LENGTH(CONCAT('', TRIM(year_end) * 1)) = 0, NULL, TRIM(year_end)),
  medium = IF(LENGTH(TRIM(medium)) > 0, TRIM(medium), NULL),
  dimensions = IF(LENGTH(TRIM(dimensions)) > 0, TRIM(dimensions), NULL),
  acquired_from = IF(LENGTH(TRIM(acquired_from)) > 0, TRIM(acquired_from), NULL),
  -- year_acquired = IF(year_acquired IS NULL OR TRIM(year_acquired) = ''
  -- OR LENGTH(CONCAT('', TRIM(year_acquired) * 1)) = 0, NULL, TRIM(year_acquired)),
  city_name = IF(LENGTH(TRIM(city_name)) > 0, TRIM(city_name), NULL),
  state_name = IF(LENGTH(TRIM(state_name)) > 0, TRIM(state_name), NULL),
  county_name = IF(LENGTH(TRIM(county_name)) > 0, TRIM(county_name), NULL),
  country_name = IF(LENGTH(TRIM(country_name)) > 0, TRIM(country_name), NULL),
  region_name = IF(LENGTH(TRIM(region_name)) > 0, TRIM(region_name), NULL),
  classification_name = IF(LENGTH(TRIM(classification_name)) > 0, TRIM(classification_name), NULL),
  resource_link = IF(LENGTH(TRIM(resource_link)) > 0, TRIM(resource_link), NULL),
  rights_and_reproduction = IF(LENGTH(TRIM(rights_and_reproduction)) > 0, TRIM(rights_and_reproduction), NULL),
  repository_name = IF(LENGTH(TRIM(repository_name)) > 0, TRIM(repository_name), NULL);

--
-- 3.2 artwork table
-- Note artwork_type_id, classification_id can be NULL.
-- WARNING: cast year_begin, year_end as SIGNED. Negative values exist for ancient artwork
-- that represent years Before the Common Era (BCE) dates.
--
CREATE TABLE IF NOT EXISTS artwork (
  artwork_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  accession_number VARCHAR(75) NOT NULL,
  is_public_domain CHAR(5) NOT NULL,
  department_id INTEGER NOT NULL,
  classification_id INTEGER NULL,
  artwork_type_id INTEGER NULL,
  title VARCHAR(500) NOT NULL,
  year_begin_end VARCHAR(255) NULL,
  year_begin INTEGER NULL,
  year_end INTEGER NULL,
  medium VARCHAR(500) NULL,
  dimensions VARCHAR(750) NULL,
  acquired_from VARCHAR(1000) NULL,
  -- year_acquired INTEGER NULL,
  city_id INTEGER NULL,
  country_id INTEGER NULL,
  region_id INTEGER NULL,
  resource_link VARCHAR(255) NULL,
  rights_and_reproduction VARCHAR(255) NULL,
  repository_id INTEGER NULL,
  PRIMARY KEY (artwork_id),
  FOREIGN KEY (classification_id) REFERENCES classification(classification_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (artwork_type_id) REFERENCES artwork_type(artwork_type_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (department_id) REFERENCES department(department_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (city_id) REFERENCES city(city_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (country_id) REFERENCES country(country_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (region_id) REFERENCES region(region_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (repository_id) REFERENCES repository(repository_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

INSERT IGNORE INTO artwork
(
  accession_number,
  is_public_domain,
  department_id,
  classification_id,
  artwork_type_id,
  title,
  year_begin_end,
  year_begin,
  year_end,
  medium,
  dimensions,
  acquired_from,
  -- year_acquired,
  city_id,
  country_id,
  region_id,
  resource_link,
  rights_and_reproduction,
  repository_id
)
SELECT ta.accession_number,
       ta.is_public_domain,
       dpt.department_id,
       cls.classification_id,
       awt.artwork_type_id,
       ta.title,
       ta.year_begin_end,
       CAST(ta.year_begin AS SIGNED) AS year_begin,
       CAST(ta.year_end AS SIGNED) AS year_end,
       ta.medium,
       ta.dimensions,
       ta.acquired_from,
       -- CAST(ta.year_acquired AS UNSIGNED) AS year_acquired,
       cit.city_id,
       cou.country_id,
       reg.region_id,
       ta.resource_link,
       ta.rights_and_reproduction,
       repo.repository_id
  FROM temp_artwork ta
       LEFT JOIN artwork_type awt
              ON TRIM(ta.artwork_type_name) = TRIM(awt.artwork_type_name)
       LEFT JOIN department dpt
              ON TRIM(ta.department_name) = TRIM(dpt.department_name)
       LEFT JOIN classification cls
              ON TRIM(ta.classification_name) = TRIM(cls.classification_name)
       LEFT JOIN city cit
              ON TRIM(ta.city_name) = TRIM(cit.city_name)
       LEFT JOIN country cou
              ON TRIM(ta.country_name) = TRIM(cou.country_name)
       LEFT JOIN region reg
              ON TRIM(ta.region_name) = TRIM(reg.region_name)
       LEFT JOIN repository repo
              ON TRIM(ta.repository_name) = TRIM(repo.repository_name)
 ORDER BY ta.temp_artwork_id;