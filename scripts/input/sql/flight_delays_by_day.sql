--
-- Flight table
--
CREATE TABLE IF NOT EXISTS flight (
  flight_id INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
  time_year INTEGER NOT NULL,
  time_month INTEGER NOT NULL,
  time_day INTEGER NOT NULL,
  day_of_week INTEGER NOT NULL,
  airline_id INTEGER NOT NULL,
  aircraft_id INTEGER NOT NULL,
  flight_number INTEGER NOT NULL,
  origin_airport_id INTEGER NOT NULL,
  destination_airport_id INTEGER NOT NULL,
  scheduled_departure INTEGER NULL,
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
  arrival_delay INTEGER NULL,
  diverted TINYINT(1) NULL,
  cancelled TINYINT(1) NULL,
  PRIMARY KEY (flight_id),
  FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (origin_airport_id) REFERENCES airport(airport_id)
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (destination_airport_id) REFERENCES airport(airport_id)
  ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET ascii
COLLATE ascii_general_ci;

--
-- Insert
--
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
INSERT INTO flight(
time_year,
time_month,
time_day,
day_of_week,
airline_id,
aircraft_id,
flight_number,
origin_airport_id,
destination_airport_id,
scheduled_departure,
departure_time,
departure_delay,
taxi_out,
wheels_off,
scheduled_time,
elapsed_time,
air_time,
distance,
wheels_on,
taxi_in,
scheduled_arrival,
arrival_time,
arrival_delay,
diverted,
cancelled
)
SELECT fl.time_year, fl.time_month, fl.time_day, fl.day_of_week,
       al.airline_id, ac.aircraft_id, fl.flight_number,
       origin.airport_id, dest.airport_id,
       fl.scheduled_departure, fl.departure_time, fl.departure_delay,
       fl.taxi_out, fl.wheels_off,
       fl.scheduled_time, fl.elapsed_time, fl.air_time, fl.distance,
       fl.wheels_on, fl.taxi_in,
       fl.scheduled_arrival, fl.arrival_time, fl.arrival_delay,
       fl.diverted, fl.cancelled
  FROM temp_flight fl
       INNER JOIN airline al
               ON fl.airline_iata_code = al.iata_code
       INNER JOIN aircraft ac
               ON fl.tail_number = ac.tail_number
       INNER JOIN airport origin
               ON fl.origin_airport_iata_code = origin.iata_code
       INNER JOIN airport dest
               ON fl.destination_airport_iata_code = dest.iata_code
WHERE fl.time_day = 27;
