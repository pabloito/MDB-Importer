CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS mobilitydb;

DROP TABLE IF EXISTS metadata CASCADE;
DROP TABLE IF EXISTS positions CASCADE;

CREATE TABLE IF NOT EXISTS metadata (
  id bigint,
  route_id text,
  agency_id int,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS positions (
  id bigint,
  instant bigint NOT NULL,
  stop_geom geometry('POINT', 4326),
  latitude float NOT NULL,
  longitude float NOT NULL,
  PRIMARY KEY (id, instant),
  CONSTRAINT fk_metadata
    FOREIGN KEY(id)
    REFERENCES metadata(id)
);

COPY metadata(id, route_id, agency_id) from :metadata DELIMITER ',' CSV HEADER;
COPY positions(id, instant, latitude, longitude) from :positions DELIMITER ',' CSV HEADER;

\! echo '...Creating trip_input'
DROP TABLE IF EXISTS trips_input;
CREATE TABLE trips_input (
    trip_id text,
	route_id text,
	agency_id text,
	date timestamp,
	point_geom geometry
);

\! echo '...Inserting trip_input'
INSERT INTO trips_input
SELECT p.id, route_id, agency_id,
	to_timestamp(instant) as timestamp, ST_GeomFromText('POINT('|| p.longitude ||' '|| p.latitude ||')') as point_geom
FROM positions p JOIN metadata m ON m.id = p.id;

\! echo '...Creating trip_mdb'
DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
	trip_id text NOT NULL,
	agency_id text NOT NULL,
	route_id text NOT NULL,
	date timestamp NOT NULL,
	trip tgeompoint,
	PRIMARY KEY (trip_id, date)
);

\! echo '...Inserting trip_mdb'
INSERT INTO trips_mdb(trip_id, agency_id, route_id, date, trip)
SELECT trip_id, agency_id, route_id, date, tgeompointseq(array_agg(tgeompointinst(point_geom, date) ORDER BY date))
FROM trips_input
GROUP BY trip_id, agency_id, route_id, date;

\! echo '...Updating trip_mdb'
ALTER TABLE trips_mdb ADD COLUMN traj geometry;
UPDATE trips_mdb
SET Traj = trajectory(Trip);
