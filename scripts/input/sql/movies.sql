-- Data set: https://www.kaggle.com/rush4ratio/video-game-sales-with-ratings (22 Dec 2016)

--
-- 1.0 Setup. Delete tables after every build iteration.
--
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS actor, country, director, genre, keyword, movie, movie_actor,
movie_genre,
                     movie_keywords, movie_language, rating,
                     temp_actor_one, temp_actor_two, temp_actor_three, temp_country, temp_director,
                     temp_genre,
                     temp_keyword,
                     temp_language,
                     temp_movie,
                     temp_rating;
SET FOREIGN_KEY_CHECKS=1;

--
-- 2.0 ENTITIES
-- Serve as lookup tables
--

--
-- 2.1 country table
--
CREATE TABLE IF NOT EXISTS country (
  country_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  country_name VARCHAR(25) NOT NULL UNIQUE,
  PRIMARY KEY (country_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/country.csv'
INTO TABLE country
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (country_name);

--
-- 2.2 director table
--
CREATE TABLE IF NOT EXISTS director (
  director_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  director_name VARCHAR(100) NOT NULL UNIQUE,
  director_facebook_likes INTEGER NULL,
  PRIMARY KEY (director_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/directors.csv'
INTO TABLE director
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (director_name, director_facebook_likes);

--
-- 2.3 genre table
--
CREATE TABLE IF NOT EXISTS genre (
  genre_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  genre_name VARCHAR(25) NOT NULL UNIQUE,
  PRIMARY KEY (genre_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/genres_unique.csv'
INTO TABLE genre
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n' 
  IGNORE 1 LINES
  (genre_name);

--
-- 2.4 keyword table
--
CREATE TABLE IF NOT EXISTS keyword (
  keyword_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  keyword_name VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (keyword_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/keywords_unique.csv'
INTO TABLE keyword
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (keyword_name); 

--
-- 2.5 movie language (language=reserved word) table
--
CREATE TABLE IF NOT EXISTS movie_language (
  language_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  language_name VARCHAR(25) NOT NULL UNIQUE,
  PRIMARY KEY (language_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/language.csv'
INTO TABLE movie_language
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (language_name); 

--
-- 2.6 rating table
--
CREATE TABLE IF NOT EXISTS rating (
  rating_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  rating_name VARCHAR(25) NOT NULL UNIQUE,
  PRIMARY KEY (rating_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/rating.csv'
INTO TABLE rating
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (rating_name);

--
-- 3.0 Temp tables
-- Serve as lookup tables
--

--
-- 3.1 temp movie country table
--
CREATE TABLE IF NOT EXISTS temp_country (
  temp_country_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  country_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (temp_country_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/movie_country.csv'
INTO TABLE temp_country
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, country_name);

--
-- 3.2 temp movie director table
--
CREATE TABLE IF NOT EXISTS temp_director (
  temp_director_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  director_name VARCHAR(250) NOT NULL,
  PRIMARY KEY (temp_director_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/movie_directors.csv'
INTO TABLE temp_director
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, director_name);

--
-- 3.3 temp movie genres table
--
CREATE TABLE IF NOT EXISTS temp_genre (
  temp_genre_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  genre_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (temp_genre_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/movie_genres-split.csv'
INTO TABLE temp_genre
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, genre_name);

--
-- 3.4 temp movie genres table
--
CREATE TABLE IF NOT EXISTS temp_keyword (
  temp_keyword_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  keyword_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (temp_keyword_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/movie_keywords-split.csv'
INTO TABLE temp_keyword
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, keyword_name);

--
-- 3.5 temp movie language table
--
CREATE TABLE IF NOT EXISTS temp_language (
  temp_language_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  language_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (temp_language_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/movie_language.csv'
INTO TABLE temp_language
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, language_name);

--
-- 3.5 temp movie rating table
--
CREATE TABLE IF NOT EXISTS temp_rating (
  temp_rating_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  rating_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (temp_rating_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/movie_rating.csv'
INTO TABLE temp_rating
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, rating_name);

--
-- 4.0 Populate actor table (three temp tables)
--

--
-- 4.1 temp actor 1 table
--
CREATE TABLE IF NOT EXISTS temp_actor_one (
  temp_actor_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  actor_name VARCHAR(255) NOT NULL,
  actor_facebook_likes INTEGER NULL,
  PRIMARY KEY (temp_actor_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/actor_1.csv'
INTO TABLE temp_actor_one
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, actor_name, actor_facebook_likes);

--
-- 4.2 temp actor 2 table
--
CREATE TABLE IF NOT EXISTS temp_actor_two (
  temp_actor_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  actor_name VARCHAR(255) NOT NULL,
  actor_facebook_likes INTEGER NULL,
  PRIMARY KEY (temp_actor_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/actor_2.csv'
INTO TABLE temp_actor_two
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, actor_name, actor_facebook_likes);

--
-- 4.3 temp actor 3 table
--
CREATE TABLE IF NOT EXISTS temp_actor_three (
  temp_actor_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_title VARCHAR(500) NOT NULL,
  actor_name VARCHAR(255) NOT NULL,
  actor_facebook_likes INTEGER NULL,
  PRIMARY KEY (temp_actor_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/actor_3.csv'
INTO TABLE temp_actor_three
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (movie_title, actor_name, actor_facebook_likes);

--
-- 4.4 actor table
--
CREATE TABLE IF NOT EXISTS actor (
  actor_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  actor_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (actor_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

-- Populate actor table with Actor 1 group
INSERT IGNORE INTO actor
(
  actor_name
)
SELECT DISTINCT actor_name
  FROM temp_actor_one
 ORDER BY actor_name;

-- Populate actor table with Actor 2 group, filtering out dups
INSERT IGNORE INTO actor
(
  actor_name
)
SELECT DISTINCT ta2.actor_name
FROM  temp_actor_two ta2
WHERE TRIM(ta2.actor_name) NOT IN
    (SELECT TRIM(a.actor_name) AS actor_name
    FROM actor a
    ORDER BY a.actor_name);

-- Populate actor table with Actor 3 group, filtering out dups
INSERT IGNORE INTO actor
(
  actor_name
)
SELECT DISTINCT ta3.actor_name
FROM  temp_actor_three ta3
WHERE TRIM(ta3.actor_name) NOT IN
    (SELECT TRIM(a.actor_name) AS actor_name
    FROM actor a
    ORDER BY a.actor_name);

--
-- 5.0 temp movie table
--
CREATE TABLE IF NOT EXISTS temp_movie (
  movie_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  title VARCHAR(500) NOT NULL,
  release_year CHAR(6) NULL,
  imdb_score CHAR(4) NULL,
  duration_minutes VARCHAR(20) NULL,
  num_critics VARCHAR(20) NULL,
  gross VARCHAR(20) NULL,
  budget VARCHAR(20) NULL,
  facebook_likes VARCHAR(20) NULL,
  imdb_link VARCHAR(255) NULL,
  PRIMARY KEY (movie_id)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE './output/movies/movies.csv'
INTO TABLE temp_movie
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (title, release_year, imdb_score, duration_minutes, num_critics, gross,
    budget, facebook_likes, imdb_link)

  SET title = IF(TRIM(title) = '', NULL, TRIM(title)),
  release_year = IF(TRIM(release_year) = '', NULL, TRIM(release_year)),
  imdb_score = IF(TRIM(imdb_score) = '', NULL, TRIM(imdb_score)),
  duration_minutes = IF(TRIM(duration_minutes) = '', NULL, TRIM(duration_minutes)),
  num_critics = IF(TRIM(num_critics) = '', NULL, TRIM(num_critics)),
  gross = IF(TRIM(gross) = '', NULL, TRIM(gross)),
  budget = IF(TRIM(budget) = '', NULL, TRIM(budget)),
  facebook_likes = IF(TRIM(facebook_likes) = '', NULL, TRIM(facebook_likes)),
  imdb_link = IF(TRIM(imdb_link) = '', NULL, TRIM(imdb_link));


--
-- 5.0 movie table
--
CREATE TABLE IF NOT EXISTS movie (
  movie_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  title VARCHAR(500) NOT NULL,
  release_year INTEGER NULL,
  director_id INTEGER NULL,
  country_id INTEGER NULL,
  language_id INTEGER NULL,
  rating_id INTEGER NULL,
  imdb_score DECIMAL(3,1) NULL,
  duration_minutes INTEGER NULL,
  num_critics INTEGER NULL,
  gross INTEGER NULL,
  budget BIGINT(20) NULL,
  facebook_likes INTEGER NULL,
  imdb_link VARCHAR(255) NULL,
  PRIMARY KEY (movie_id),
  FOREIGN KEY (country_id) REFERENCES country(country_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (director_id) REFERENCES director(director_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (language_id) REFERENCES movie_language(language_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (rating_id) REFERENCES rating(rating_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO movie
(
  title,
  release_year,
  director_id,
  country_id,
  language_id,
  rating_id,
  imdb_score,
  duration_minutes,
  num_critics,
  gross,
  budget,
  facebook_likes,
  imdb_link
)
SELECT tm.title, tm.release_year, d.director_id, c.country_id, ml.language_id,
       r.rating_id, tm.imdb_score, tm.duration_minutes, tm.num_critics, tm.gross,
       tm.budget, tm.facebook_likes, tm.imdb_link
  FROM temp_movie tm
       LEFT JOIN temp_director td
              ON TRIM(tm.title) = TRIM(td.movie_title)
       LEFT JOIN director d
              ON TRIM(td.director_name) = TRIM(d.director_name)
       LEFT JOIN temp_country tc
              ON TRIM(tm.title) = TRIM(tc.movie_title)
       LEFT JOIN country c
              ON TRIM(tc.country_name) = TRIM(c.country_name)
       LEFT JOIN temp_language tl
              ON TRIM(tm.title) = TRIM(tl.movie_title)
       LEFT JOIN movie_language ml
              ON TRIM(tl.language_name) = TRIM(ml.language_name)
       LEFT JOIN temp_rating tr
              ON TRIM(tm.title) = TRIM(tr.movie_title)
       LEFT JOIN rating r
              ON TRIM(tr.rating_name) = TRIM(r.rating_name)
 ORDER BY tm.movie_id;

--
-- 5.1 movie genres table
--
CREATE TABLE IF NOT EXISTS movie_genre (
  movie_genre_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_id INTEGER NOT NULL,
  genre_id INTEGER NOT NULL,
  PRIMARY KEY (movie_genre_id),
  FOREIGN KEY (movie_id) REFERENCES movie(movie_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO movie_genre
(
  movie_id,
  genre_id
)
SELECT m.movie_id, g.genre_id
FROM movie m
     LEFT JOIN temp_genre tg
            ON TRIM(m.title) = TRIM(tg.movie_title)
     LEFT JOIN genre g
            ON TRIM(tg.genre_name) = TRIM(g.genre_name)
WHERE g.genre_id IS NOT NULL
ORDER BY m.movie_id, g.genre_id;

--
-- 5.2 movie keyword table
--

CREATE TABLE IF NOT EXISTS movie_keyword (
  movie_keyword_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  movie_id INTEGER NOT NULL,
  keyword_id INTEGER NOT NULL,
  PRIMARY KEY (movie_genre_id),
  FOREIGN KEY (movie_id) REFERENCES movie(movie_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (keyword_id) REFERENCES keyword(keyword_id)
    ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

INSERT IGNORE INTO movie_genre
(
  movie_id,
  keyword_id
)
SELECT m.movie_id, g.keyword_id
  FROM movie m
       LEFT JOIN temp_keyword tk
              ON TRIM(m.title) = TRIM(tk.movie_title)
       LEFT JOIN keyword k
              ON TRIM(tk.keyword_name) = TRIM(k.keyword_name)
 WHERE k.keyword_id IS NOT NULL
 ORDER BY m.movie_id, k.keyword_id;
