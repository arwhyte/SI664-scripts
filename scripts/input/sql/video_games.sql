--
-- 0.0 Delete tables after every build iteration.
--
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS developer, game, game_developer, genre, platform,
                     publisher, rating, sale, region;
SET FOREIGN_KEY_CHECKS=1;

--
-- 1.0 ENTITIES
-- Serve as lookup tables
--

--
-- 1.1 genre table
--
CREATE TABLE IF NOT EXISTS genre (
  genre_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  genre_name VARCHAR(25) NOT NULL UNIQUE,
  PRIMARY KEY (genre_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/video_games/video_game_genres.csv'
INTO TABLE genre
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  (genre_name);

--
-- 1.2 platform table
--
CREATE TABLE IF NOT EXISTS platform (
  platform_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  platform_name VARCHAR(10) NOT NULL UNIQUE,
  PRIMARY KEY (platform_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/video_games/video_game_platforms.csv'
INTO TABLE platform
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  (platform_name);

--
-- 1.3 publisher table
--
CREATE TABLE IF NOT EXISTS publisher (
  publisher_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  publisher_name VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (publisher_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/video_games/video_game_publishers.csv'
INTO TABLE publisher
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  (publisher_name);

--
-- 1.4 rating table
--
CREATE TABLE IF NOT EXISTS rating (
  rating_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  rating_name CHAR(4) NOT NULL UNIQUE,
  PRIMARY KEY (rating_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/video_games/video_game_ratings.csv'
INTO TABLE rating
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY '\t'
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  (rating_name);

--
-- 1.5 region table
--
CREATE TABLE IF NOT EXISTS region (
  region_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  region_name CHAR(25) NOT NULL UNIQUE,
  PRIMARY KEY (region_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO region (region_name) VALUES
  ('Global'), ('North America'), ('Europe'), ('Japan'), ('Other');

--
-- 2.0 CORE ENTITIES AND M2M TABLES (developer, game, game_developer, sale)
--

--
-- 2.1 Temporary game table
-- Note: 16719 rows data set.
--
CREATE TEMPORARY TABLE temp_game (
  game_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  game_name VARCHAR(255) NOT NULL,
  platform_name VARCHAR(50),
  year_released CHAR(4) NULL,
  genre_name VARCHAR(25) NULL,
  publisher_name VARCHAR(100) NULL,
  north_america_sales DECIMAL(5,2) NULL,
  europe_sales DECIMAL(5,2) NULL,
  japan_sales DECIMAL(5,2) NULL,
  other_sales DECIMAL(5,2) NULL,
  global_sales DECIMAL(5,2) NULL,
  critic_score CHAR(3) NULL,
  critic_count VARCHAR(10) NULL,
  user_score CHAR(3) NULL,
  user_count VARCHAR(10) NULL,
  developer_name VARCHAR(100) NULL,
  rating_name CHAR(4) NULL,
  PRIMARY KEY (game_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/video_games/video_game_sales_trimmed.csv'
INTO TABLE temp_game
  CHARACTER SET utf8mb4
  -- FIELDS TERMINATED BY '\t'
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (game_name, platform_name, year_released, genre_name,
  publisher_name, north_america_sales, europe_sales, japan_sales, other_sales,
  global_sales, critic_score, critic_count, user_score, user_count, developer_name,
  rating_name)

  SET game_name = IF(game_name = '', NULL, TRIM(game_name)),
  platform_name = IF(platform_name = '', NULL, TRIM(platform_name)),
  year_released = IF(year_released = '', NULL, year_released),
  genre_name = IF(genre_name = '', NULL, genre_name),
  publisher_name = IF(publisher_name = '', NULL, TRIM(publisher_name)),
  critic_score = IF(critic_score = '', NULL, critic_score),
  critic_count = IF(critic_count = '', NULL, critic_count),
  user_score = IF(user_score = '', NULL, user_score),
  user_count = IF(user_count = '', NULL, user_count),
  developer_name = IF(developer_name = '', NULL, TRIM(developer_name)),
  rating_name = IF(rating_name = '', NULL, TRIM(rating_name));

--
-- 2.2 game table
-- Note: 16717 rows data set (two records with blank game_name values excluded)
-- Several columns will be dropped after junction tables are populated.
--
CREATE TABLE IF NOT EXISTS game (
    game_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
    game_name VARCHAR(255) NULL,
    platform_id INTEGER NULL,
    year_released INTEGER NULL,
    genre_id INTEGER NULL,
    publisher_id INTEGER NULL,
    north_america_sales DECIMAL(5, 2) NULL,
    europe_sales DECIMAL(5,2) NULL,
    japan_sales DECIMAL(5,2) NULL,
    other_sales DECIMAL(5,2) NULL,
    global_sales DECIMAL(5,2) NULL,
    critic_score INTEGER NULL,
    critic_count INTEGER NULL,
    user_score INTEGER NULL,
    user_count INTEGER NULL,
    developer_name VARCHAR(100) NULL,
    rating_id INTEGER NULL,
    PRIMARY KEY (game_id),
    FOREIGN KEY (platform_id) REFERENCES platform(platform_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (rating_id) REFERENCES rating(rating_id)
    ON DELETE CASCADE ON UPDATE CASCADE
  )
  ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO game
(
  game_name,
  platform_id,
  year_released,
  genre_id,
  publisher_id,
  north_america_sales,
  europe_sales,
  japan_sales,
  other_sales,
  global_sales,
  critic_score,
  critic_count,
  user_score,
  user_count,
  developer_name,
  rating_id
)
SELECT tg.game_name, plat.platform_id, CAST(tg.year_released AS UNSIGNED) AS year_released,
       g.genre_id, pub.publisher_id,
       tg.north_america_sales, tg.europe_sales, tg.japan_sales, tg.other_sales, tg.global_sales,
       CAST(tg.critic_score AS UNSIGNED) AS critic_score,
       CAST(tg.critic_count AS UNSIGNED) AS critic_count,
       CAST(tg.user_score AS UNSIGNED) AS user_score,
       CAST(tg.user_count AS UNSIGNED) AS user_count,
       tG.developer_name, r.rating_id
 FROM temp_game tg
      LEFT JOIN genre g
             ON TRIM(tg.genre_name) = TRIM(g.genre_name)
      LEFT JOIN platform plat
             ON TRIM(tg.platform_name) = TRIM(plat.platform_name)
      LEFT JOIN publisher pub
             ON TRIM(tg.publisher_name) = TRIM(pub.publisher_name)
      LEFT JOIN rating r
             ON TRIM(tg.rating_name) = TRIM(r.rating_name)
WHERE tg.game_name IS NOT NULL AND tg.game_name != ''
ORDER BY tg.global_sales DESC, tg.game_name, tg.year_released;

--
-- 2.3 sale table (M2M)
-- Note: joins on temporary table via name matches resulted in duplicates.
-- Join on game instead and then drop sales columns with ALTER TABLE statement
-- Without WHERE clauses: 83585 rows in sales (16717 games * 5)
-- Excluding 0.00 sales entries:
-- Total inserts: 56085 rows
--
CREATE TABLE IF NOT EXISTS sale (
  sales_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  game_id INTEGER NOT NULL,
  region_id INTEGER NOT NULL,
  total_sales DECIMAL(5,2),
  PRIMARY KEY (sales_id),
  FOREIGN KEY (game_id) REFERENCES game(game_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (region_id) REFERENCES region(region_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO sale
(
game_id,
region_id,
total_sales
)
SELECT g.game_id, 1 as region_id, g.global_sales AS total_sales
  FROM game g
 WHERE g.global_sales > 0.00
 UNION
SELECT g.game_id, 2 as region_id, g.north_america_sales AS total_sales
  FROM game g
 WHERE g.north_america_sales > 0.00
 UNION
SELECT g.game_id, 3 as region_id, g.europe_sales AS total_sales
  FROM game g
 WHERE g.europe_sales > 0.00
 UNION
SELECT g.game_id, 4 as region_id, g.japan_sales AS total_sales
  FROM game g
 WHERE g.japan_sales > 0.00
 UNION
SELECT g.game_id, 5 as region_id, g.other_sales AS total_sales
  FROM game g
 WHERE g.other_sales > 0.00;

--
-- 2.4 temporary numbers table
-- Split comma-delimited developer values in order to populate a developer table
-- and a M2M game_developer associative table
-- Create temporary numbers table that will be used to split out comma-delimited lists of states.
--
CREATE TEMPORARY TABLE numbers
  (
    num INTEGER NOT NULL UNIQUE,
    PRIMARY KEY (num)
  )
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO numbers (num) VALUES
  (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15);

--
-- 2.4.1 temp_game_developer
-- Temporary table that stores split out developer companies.
--
CREATE TEMPORARY TABLE temp_game_developer
  (
    id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
    game_id INTEGER NOT NULL,
    developer_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
  )
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

-- 2.4.2 This query splits the game developers and inserts them into the target temp table.
-- Note use of DISTINCT.
-- USE TRIM to eliminate white space around developer_name value.
--
INSERT IGNORE INTO temp_game_developer (game_id, developer_name)
SELECT DISTINCT g.game_id,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(g.developer_name, ',', n.num), ',', -1))
       AS developer_name
  FROM numbers n
       INNER JOIN game g
               ON CHAR_LENGTH(g.developer_name) - CHAR_LENGTH(REPLACE(g.developer_name, ',', ''))
                  >= n.num - 1
 ORDER BY g.game_id, developer_name;

--
-- 2.5 developer table
-- Populate with DISTINCT developer_name values from temp_game_developer table
--
CREATE TABLE IF NOT EXISTS developer (
  developer_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  developer_name VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (developer_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO developer (developer_name)
SELECT DISTINCT TRIM(tgd.developer_name) AS developer_name
  FROM temp_game_developer tgd
 ORDER BY developer_name;

--
-- 2.6 game_developer table (M2M)
-- Insert records from temp_game_developer joined with developer
--
CREATE TABLE IF NOT EXISTS game_developer (
  game_developer_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  game_id INTEGER NOT NULL,
  developer_id INTEGER NOT NULL,
  PRIMARY KEY (game_developer_id),
  FOREIGN KEY (game_id) REFERENCES game(game_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (developer_id) REFERENCES developer(developer_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO game_developer (game_id, developer_id)
SELECT tgd.game_id, d.developer_id
  FROM temp_game_developer tgd
       INNER JOIN developer d
               ON TRIM(tgd.developer_name) = TRIM(d.developer_name)
 ORDER BY tgd.game_id, d.developer_id;

--
-- 3.0 Clean up
--

--
-- 3.1 Drop redundant columns from game table.
--
ALTER TABLE game
      DROP COLUMN north_america_sales,
      DROP COLUMN europe_sales,
      DROP COLUMN japan_sales,
      DROP COLUMN other_sales,
      DROP COLUMN global_sales,
      DROP COLUMN developer_name;

--
-- 3.2 DROP temporary tables
--
DROP TEMPORARY TABLE numbers;
DROP TEMPORARY TABLE temp_game;
DROP TEMPORARY TABLE temp_game_developer;

-- FINIS