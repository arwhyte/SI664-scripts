SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS actor, movie_actor;
SET FOREIGN_KEY_CHECKS=1;

--
-- 1.0 Populate actor table (three temp tables)
--

--
-- 1.1 temp actor 1 table
--
CREATE TEMPORARY TABLE temp_actor (
  temp_actor_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  title_year CHAR(6) NULL,
  imdb_link VARCHAR(100) NOT NULL,
  actor_name VARCHAR(255) NOT NULL,
  actor_facebook_likes INTEGER NULL,
  movie_actor_index INTEGER NOT NULL,
  PRIMARY KEY (temp_actor_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/actor_1.csv'
INTO TABLE temp_actor
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, title_year, imdb_link, actor_name, actor_facebook_likes, movie_actor_index)

  SET title_year = IF(TRIM(title_year) != '', TRIM(title_year), NULL);

LOAD DATA LOCAL INFILE './output/movies/actor_2.csv'
INTO TABLE temp_actor
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, title_year, imdb_link, actor_name, actor_facebook_likes, movie_actor_index)

  SET title_year = IF(TRIM(title_year) != '', TRIM(title_year), NULL);

LOAD DATA LOCAL INFILE './output/movies/actor_3.csv'
INTO TABLE temp_actor
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, title_year, imdb_link, actor_name, actor_facebook_likes, movie_actor_index)

  SET title_year = IF(TRIM(title_year) != '', TRIM(title_year), NULL);

--
-- 1.2 actor table
--
CREATE TABLE IF NOT EXISTS actor (
  actor_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  actor_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (actor_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Populate actor table with Actor 1 group
INSERT IGNORE INTO actor
(
  actor_name
)
SELECT DISTINCT actor_name
  FROM temp_actor
 ORDER BY actor_name;

--
-- 1.3 movie actors table
--
CREATE TABLE IF NOT EXISTS movie_actor (
  movie_actor_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_id INTEGER NOT NULL,
  movie_actor_index INTEGER NOT NULL,
  actor_id INTEGER NOT NULL,
  actor_facebook_likes INTEGER NULL,
  PRIMARY KEY (movie_actor_id),
  FOREIGN KEY (movie_id) REFERENCES movie(movie_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES actor(actor_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT INTO movie_actor
(
  movie_id,
  movie_actor_index,
  actor_id,
  actor_facebook_likes
)
SELECT m.movie_id, ta.movie_actor_index, a.actor_id, ta.actor_facebook_likes
FROM movie m
INNER JOIN  temp_actor ta
ON m.imdb_link = ta.imdb_link
INNER JOIN actor a
ON ta.actor_name = a.actor_name;

-- Drop temporary tables
DROP TEMPORARY TABLE temp_actor;