CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS mobilitydb;

-- Tables for CSV input
DROP TABLE IF EXISTS agency CASCADE;
DROP TABLE IF EXISTS calendar CASCADE;
DROP TABLE IF EXISTS calendar_dates CASCADE;
DROP TABLE IF EXISTS routes CASCADE;
DROP TABLE IF EXISTS shapes CASCADE;
DROP TABLE IF EXISTS stops CASCADE;
DROP TABLE IF EXISTS stop_times CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
-- Auxiliary tables
DROP TABLE IF EXISTS shape_geoms CASCADE;
DROP TABLE IF EXISTS exception_types CASCADE;
DROP TABLE IF EXISTS location_types CASCADE;
DROP TABLE IF EXISTS pickup_dropoff_types CASCADE;
DROP TABLE IF EXISTS route_types CASCADE;

CREATE TABLE agency (
  agency_id text DEFAULT '',
  agency_name text DEFAULT NULL,
  agency_url text DEFAULT NULL,
  agency_timezone text DEFAULT NULL,
  agency_lang text DEFAULT NULL,
  agency_phone text DEFAULT NULL,
  CONSTRAINT agency_pkey PRIMARY KEY (agency_id)
);

CREATE TABLE calendar (
  service_id text,
  monday int NOT NULL,
  tuesday int NOT NULL,
  wednesday int NOT NULL,
  thursday int NOT NULL,
  friday int NOT NULL,
  saturday int NOT NULL,
  sunday int NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  CONSTRAINT calendar_pkey PRIMARY KEY (service_id)
);
CREATE INDEX calendar_service_id ON calendar (service_id);

--related to calendar_dates(exception_type)
CREATE TABLE exception_types (
  exception_type int PRIMARY KEY,
  description text
);

CREATE TABLE calendar_dates (
  service_id text,
  date date NOT NULL,
  exception_type int REFERENCES exception_types(exception_type)
);

CREATE INDEX calendar_dates_dateidx ON calendar_dates (date);

--related to routes(route_type)
CREATE TABLE route_types (
  route_type int PRIMARY KEY,
  description text
);

CREATE TABLE routes (
  route_id text,
  route_short_name text DEFAULT '',
  route_long_name text DEFAULT '',
  route_desc text DEFAULT '',
  route_type int REFERENCES route_types(route_type),
  route_url text,
  route_color text,
  route_text_color text,
  CONSTRAINT routes_pkey PRIMARY KEY (route_id)
);

CREATE TABLE shapes (
  shape_id text NOT NULL,
  shape_pt_lat double precision NOT NULL,
  shape_pt_lon double precision NOT NULL,
  shape_pt_sequence int NOT NULL
);

CREATE INDEX shapes_shape_key ON shapes (shape_id);

-- Create new table to store the shape geometries
CREATE TABLE shape_geoms (
  shape_id text NOT NULL,
  shape_geom geometry('LINESTRING', 4326),
  CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);

CREATE INDEX shape_geoms_key ON shapes (shape_id);

--related to stops(location_type)
CREATE TABLE location_types (
  location_type int PRIMARY KEY,
  description text
);

CREATE TABLE stops (
  stop_id text,
  stop_code text,
  stop_name text DEFAULT NULL,
  stop_desc text DEFAULT NULL,
  stop_lat double precision,
  stop_lon double precision,
  zone_id text,
  stop_url text,
  location_type integer  REFERENCES location_types(location_type),
  parent_station integer,
  stop_geom geometry('POINT', 4326),
  platform_code text DEFAULT NULL,
  CONSTRAINT stops_pkey PRIMARY KEY (stop_id)
);

--related to stop_times(pickup_type) and stop_times(drop_off_type)
CREATE TABLE pickup_dropoff_types (
  type_id int PRIMARY KEY,
  description text
);

CREATE TABLE stop_times (
  trip_id text NOT NULL,
  -- Check that casting to time interval works.
  arrival_time interval CHECK (arrival_time::interval = arrival_time::interval),
  departure_time interval CHECK (departure_time::interval = departure_time::interval),
  stop_id text,
  stop_sequence int NOT NULL,
  pickup_type int REFERENCES pickup_dropoff_types(type_id),
  drop_off_type int REFERENCES pickup_dropoff_types(type_id),
  CONSTRAINT stop_times_pkey PRIMARY KEY (trip_id, stop_sequence)
);

CREATE INDEX stop_times_key ON stop_times (trip_id, stop_id);
CREATE INDEX arr_time_index ON stop_times (arrival_time);
CREATE INDEX dep_time_index ON stop_times (departure_time);

CREATE TABLE trips (
  route_id text NOT NULL,
  service_id text NOT NULL,
  trip_id text NOT NULL,
  trip_headsign text,
  direction_id int,
  block_id text,
  shape_id text,
  CONSTRAINT trips_pkey PRIMARY KEY (trip_id)
);
CREATE INDEX trips_trip_id ON trips (trip_id);

INSERT INTO exception_types (exception_type, description) VALUES 
  (1, 'service has been added'),
  (2, 'service has been removed');

INSERT INTO location_types(location_type, description) VALUES 
  (0,'stop'),
  (1,'station'),
  (2,'station entrance');

INSERT INTO pickup_dropoff_types (type_id, description) VALUES
  (0,'Regularly Scheduled'),
  (1,'Not available'),
  (2,'Phone arrangement only'),
  (3,'Driver arrangement only');

COPY calendar(service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date) 
FROM '/usr/local/src/calendar.txt' DELIMITER ',' CSV HEADER;

COPY calendar_dates(service_id,date,exception_type) 
FROM '/usr/local/src/calendar_dates.txt' DELIMITER ',' CSV HEADER;

COPY stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type) 
FROM '/usr/local/src/stop_times.txt' DELIMITER ',' CSV HEADER;

COPY trips(route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id) 
FROM '/usr/local/src/trips.txt' DELIMITER ',' CSV HEADER;

COPY agency(agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone)
FROM '/usr/local/src/agency.txt' DELIMITER ',' CSV HEADER;

COPY route_types(route_type,description)
FROM '/usr/local/src/route_types.txt' DELIMITER ',' CSV HEADER;

COPY routes(route_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color)
FROM '/usr/local/src/routes.txt' DELIMITER ',' CSV HEADER;

COPY shapes(shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence)
FROM '/usr/local/src/shapes.txt' DELIMITER ',' CSV HEADER;

COPY stops(stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station)
FROM '/usr/local/src/stops.txt' DELIMITER ',' CSV HEADER;

-- Add geometry to tables
INSERT INTO shape_geoms 
SELECT  shape_id, ST_MakeLine(array_agg(
	ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))
FROM shapes
GROUP BY shape_id;

UPDATE stops
SET stop_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat),4326);
