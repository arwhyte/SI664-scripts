--
-- 1.0 Setup. Delete tables after every build iteration.
--
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS classification, country, department, artwork, artwork_type,
                     temp_artwork, temp_classification;
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
  (artwork_type_name);

--
-- 2.2 classification table
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
  (classification_name);

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
-- 2.3 country table
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
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_countries.csv'
INTO TABLE country
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  (country_name);

--
-- 2.4 department table
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
  (department_name);

--
-- 3.0 CORE ENTITIES AND M2M TABLES (developer, game, game_developer, sale)
--

--
-- 3.1 Temporary artwork table
--

-- https://dev.mysql.com/doc/refman/8.0/en/charset-we-sets.html
-- Character set = Windows-1252 = cp1252 = latin1
-- Collation = latin1_swedish_ci (default)

CREATE TABLE IF NOT EXISTS temp_artwork (
  temp_artwork_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  accession_number VARCHAR(50) NULL,
  is_public_domain CHAR(5) NULL,
  department_name VARCHAR(75) NULL,
  artwork_type_name VARCHAR(255) NULL,
  title VARCHAR(500) NULL,
  year_begin_end VARCHAR(255) NULL,
  year_begin VARCHAR(10) NULL,
  year_end VARCHAR(10) NULL,
  dimensions VARCHAR(500) NULL,
  donor VARCHAR(1000) NULL,
  year_acquired VARCHAR(10) NULL,
  country_name VARCHAR(100) NULL,
  classification_name VARCHAR(100) NULL,
  resource_link VARCHAR(255) NULL,
  PRIMARY KEY (temp_artwork_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
-- CHARACTER SET latin1
-- COLLATE latin1_swedish_ci;

LOAD DATA LOCAL INFILE './output/met_artwork/met_artwork-trimmed_manual_fixes.csv'
INTO TABLE temp_artwork
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  -- FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (accession_number, is_public_domain, department_name, artwork_type_name, title,
    @dummy, @dummy, @dummy, @dummy, @dummy, @dummy,
    @dummy, @dummy, year_begin_end, year_begin, year_end, @dummy,
    dimensions, donor, year_acquired, @dummy, country_name, @dummy,
    classification_name, @dummy, resource_link, @dummy
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
  year_begin_end = IF(LENGTH(TRIM(year_begin_end)) > 0, TRIM(year_begin_end), NULL),
  year_begin = IF(year_begin IS NULL
                  OR TRIM(year_begin) = ''
                  OR LENGTH(CONCAT('', TRIM(year_begin)) * 1) = 0,
                  NULL, TRIM(year_begin)),
  year_end = IF(year_end IS NULL
                OR TRIM(year_end) = ''
                OR LENGTH(CONCAT('', TRIM(year_end) * 1)) = 0,
                NULL, TRIM(year_end)),
  classification_name = IF(LENGTH(TRIM(classification_name)) > 0, TRIM(classification_name), NULL),
  resource_link = IF(LENGTH(TRIM(resource_link)) > 0, TRIM(resource_link), NULL),
  donor = IF(LENGTH(TRIM(donor)) > 0, TRIM(donor), NULL),
  year_acquired = IF(year_acquired IS NULL
                     OR TRIM(year_acquired) = ''
                     OR LENGTH(CONCAT('', TRIM(year_acquired) * 1)) = 0,
                     NULL, TRIM(year_acquired));

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
  dimensions VARCHAR(500) NULL,
  donor VARCHAR(1000) NULL,
  year_acquired INTEGER NULL,
  country_id INTEGER NULL,
  resource_link VARCHAR(255) NULL,
  PRIMARY KEY (artwork_id),
  FOREIGN KEY (artwork_type_id) REFERENCES artwork_type(artwork_type_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (department_id) REFERENCES department(department_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (classification_id) REFERENCES classification(classification_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (country_id) REFERENCES country(country_id)
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
  dimensions,
  donor,
  year_acquired,
  country_id,
  resource_link
)
SELECT ta.accession_number,
       ta.is_public_domain,
       d.department_id,
       cls.classification_id,
       arttype.artwork_type_id,
       ta.title,
       ta.year_begin_end,
       CAST(ta.year_begin AS SIGNED) AS year_begin,
       CAST(ta.year_end AS SIGNED) AS year_end,
       ta.dimensions,
       ta.donor,
       CAST(ta.year_acquired AS UNSIGNED) AS year_acquired,
       cou.country_id,
       ta.resource_link
  FROM temp_artwork ta
       LEFT JOIN artwork_type arttype
              ON TRIM(ta.artwork_type_name) = TRIM(arttype.artwork_type_name)
       LEFT JOIN department d
              ON TRIM(ta.department_name) = TRIM(d.department_name)
       LEFT JOIN classification cls
              ON TRIM(ta.classification_name) = TRIM(cls.classification_name)
       LEFT JOIN country cou
              ON TRIM(ta.country_name) = TRIM(cou.country_name)
 ORDER BY ta.temp_artwork_id;