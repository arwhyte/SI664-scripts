--
-- Setup. Delete tables after every build iteration.
--

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS aircraft, airline, airport, city, country, state, temp_flight;
SET FOREIGN_KEY_CHECKS=1;

--
-- aircraft table
--
CREATE TABLE IF NOT EXISTS aircraft (
  aircraft_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  tail_number VARCHAR(10) NOT NULL,
  PRIMARY KEY (aircraft_id)
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

LOAD DATA LOCAL INFILE './output/flight_delays/aircraft.csv'
INTO TABLE aircraft
  CHARACTER SET ascii
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (tail_number);

--
-- airline table
--
CREATE TABLE IF NOT EXISTS airline (
  airline_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  iata_code CHAR(3) NOT NULL,
  airline_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (airline_id)
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

LOAD DATA LOCAL INFILE './output/flight_delays/airlines-trimmed.csv'
INTO TABLE airline
  CHARACTER SET ascii
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (iata_code, airline_name);

--
-- temp location table
--
CREATE TEMPORARY TABLE temp_location (
  location_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  iata_code CHAR(3) NOT NULL,
  city_name VARCHAR(50) NOT NULL,
  state_name CHAR(50) NOT NULL,
  country_name CHAR(3) NOT NULL,
  PRIMARY KEY (location_id)
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

LOAD DATA LOCAL INFILE './output/flight_delays/airport_locations.csv'
INTO TABLE temp_location
  CHARACTER SET ascii
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (iata_code, city_name, state_name, country_name);

--
-- country table
--
CREATE TABLE IF NOT EXISTS country (
  country_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  country_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (country_id)
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

INSERT IGNORE INTO country (
country_name
)
SELECT DISTINCT country_name
FROM temp_location
ORDER BY country_name;

--
-- state table
--
CREATE TABLE IF NOT EXISTS state (
  state_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  state_name VARCHAR(50) NOT NULL,
  country_id INTEGER NOT NULL,
  PRIMARY KEY (state_id)
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

INSERT IGNORE INTO state (
state_name,
country_id
)
SELECT DISTINCT state_name, country_id
FROM temp_location
     INNER JOIN country c
             ON TRIM(temp_location.country_name) = TRIM(c.country_name)
ORDER BY state_name, country_id;

--
-- city table
--
CREATE TABLE IF NOT EXISTS city (
  city_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  city_name VARCHAR(50) NOT NULL,
  state_id INTEGER NOT NULL,
  PRIMARY KEY (city_id)
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

INSERT IGNORE INTO city (
city_name,
state_id
)
SELECT DISTINCT city_name, state_id
  FROM temp_location
       INNER JOIN state s
               ON TRIM(temp_location.state_name) = TRIM(s.state_name)
 ORDER BY city_name, state_id;

-- Drop temp_location table
DROP TEMPORARY TABLE temp_location;

--
-- temp airport table
--
CREATE TEMPORARY TABLE temp_airport (
  airport_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  iata_code CHAR(3) NOT NULL,
  airport_name VARCHAR(255) NOT NULL,
  city_name VARCHAR(50) NOT NULL,
  state_name VARCHAR(50) NOT NULL,
  country_name VARCHAR(50) NOT NULL,
  latitude VARCHAR(50) NOT NULL,
  longitude VARCHAR(50) NOT NULL,
  PRIMARY KEY (airport_id)
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

LOAD DATA LOCAL INFILE './output/flight_delays/airports-trimmed.csv'
INTO TABLE temp_airport
  CHARACTER SET ascii
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (iata_code, airport_name, city_name, state_name, country_name, latitude, longitude);

--
-- airport table
--
CREATE TABLE IF NOT EXISTS airport (
  airport_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  iata_code CHAR(3) NOT NULL,
  airport_name VARCHAR(255) NOT NULL,
  city_id INTEGER NOT NULL,
  state_id INTEGER NOT NULL,
  country_id INTEGER NOT NULL,
  latitude DECIMAL(10, 8) NULL,
  longitude DECIMAL(11, 8) NULL,
  PRIMARY KEY (airport_id),
  FOREIGN KEY (city_id) REFERENCES city(city_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (state_id) REFERENCES state(state_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (country_id) REFERENCES country(country_id)
  ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

INSERT IGNORE INTO airport (
iata_code,
airport_name,
city_id,
state_id,
country_id,
latitude,
longitude
)
SELECT ta.iata_code, ta.airport_name, c.city_id, s.state_id,
       cou.country_id, ta.latitude, ta.longitude
  FROM temp_airport ta
       INNER JOIN country cou
               ON TRIM(ta.country_name) = TRIM(cou.country_name)
       INNER JOIN state s
               ON TRIM(ta.state_name) = TRIM(s.state_name)
       INNER JOIN city c
               ON TRIM(ta.city_name) = TRIM(c.city_name)
               AND c.state_id = s.state_id
 ORDER BY ta.iata_code;

-- Drop temp_airport table
DROP TEMPORARY TABLE temp_airport;

--
-- temp flight table
--
-- CREATE TEMPORARY TABLE temp_flight (
CREATE TABLE IF NOT EXISTS temp_flight (
  flight_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  time_year INTEGER NOT NULL,
  time_month INTEGER NOT NULL,
  time_day INTEGER NOT NULL,
  day_of_week INTEGER NOT NULL,
  airline_iata_code CHAR(2) NOT NULL,
  flight_number INTEGER NOT NULL,
  tail_number VARCHAR(10) NOT NULL,
  origin_airport_iata_code CHAR(3) NOT NULL,
  destination_airport_iata_code CHAR(3) NOT NULL,
  scheduled_departure INTEGER NOT NULL,
  departure_time INTEGER NULL,
  departure_delay INTEGER NULL,
  taxi_out INTEGER NULL,
  wheels_off INTEGER NULL,
  scheduled_time INTEGER NULL,
  elapsed_time INTEGER NULL,
  air_time INTEGER NULL,
  distance INTEGER NULL,
  wheels_on INTEGER NULL,
  taxi_in INTEGER NULL,
  scheduled_arrival INTEGER NULL,
  arrival_time INTEGER NULL,
  arrival_delay INTEGER NOT NULL,
  diverted TINYINT(1) NULL,
  cancelled TINYINT(1) NULL,
  PRIMARY KEY (flight_id)
)

ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

LOAD DATA LOCAL INFILE './output/flight_delays/flights_20151125_to_27-trimmed.csv'
INTO TABLE temp_flight
  CHARACTER SET ascii
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES
  (time_year, time_month, time_day, day_of_week, airline_iata_code, flight_number, tail_number,
      origin_airport_iata_code, destination_airport_iata_code, scheduled_departure, departure_time,
      departure_delay, taxi_out, wheels_off, scheduled_time, elapsed_time, air_time,
      distance, wheels_on, taxi_in, scheduled_arrival, arrival_time, arrival_delay,
      diverted, cancelled, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)

SET departure_time = IF(TRIM(departure_time) = '', NULL, TRIM(departure_time)),
    departure_delay = IF(TRIM(departure_delay) = '', NULL, TRIM(departure_delay)),
    taxi_out = IF(TRIM(taxi_out) = '', NULL, TRIM(taxi_out)),
    wheels_off = IF(TRIM(wheels_off) = '', NULL, TRIM(wheels_off)),
    scheduled_time = IF(TRIM(scheduled_time) = '', NULL, TRIM(scheduled_time)),
    elapsed_time = IF(TRIM(elapsed_time) = '', NULL, TRIM(elapsed_time)),
    air_time = IF(TRIM(air_time) = '', NULL, TRIM(air_time)),
    distance = IF(TRIM(distance) = '', NULL, TRIM(distance)),
    wheels_on = IF(TRIM(wheels_on) = '', NULL, TRIM(wheels_on)),
    taxi_in = IF(TRIM(taxi_in) = '', NULL, TRIM(taxi_in)),
    scheduled_arrival = IF(TRIM(scheduled_arrival) = '', NULL, TRIM(scheduled_arrival)),
    arrival_time = IF(TRIM(arrival_time) = '', NULL, TRIM(arrival_time)),
    arrival_delay = IF(TRIM(arrival_delay) = '', NULL, TRIM(arrival_delay)),
    diverted = IF(TRIM(diverted) = '', NULL, TRIM(diverted)),
    cancelled = IF(TRIM(cancelled) = '', NULL, TRIM(cancelled));
