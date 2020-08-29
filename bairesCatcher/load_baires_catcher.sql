CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS mobilitydb;

DROP TABLE IF EXISTS positions CASCADE;

CREATE TABLE IF NOT EXISTS positions (
  trip_id text,
  vehicle_id text NOT NULL,
  instant bigint NOT NULL,
  latitude float NOT NULL,
  longitude float NOT NULL,
  startdate text,
  starttime text,
  directionId int,
  PRIMARY KEY (trip_id, vehicle_id, instant)
);

COPY positions(
  trip_id,
  vehicle_id,
  instant,
  latitude,
  longitude,
  startdate,
  starttime,
  directionId) from :positions DELIMITER ',' CSV HEADER;

\! echo '...Altering positions'
ALTER TABLE positions ADD COLUMN point geometry;
UPDATE positions
SET point = ST_SetSRID(ST_MakePoint(longitude, latitude),4326);


\! echo '...Creating trip_mdb'
DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
    trip_id text NOT NULL,
    vehicle_id text NOT NULL,
	startdate text,
    starttime text,
	trip tgeompoint,
	PRIMARY KEY (trip_id, vehicle_id, startdate, starttime)
);

\! echo '...Inserting trip_mdb'
INSERT INTO trips_mdb(
    trip_id,
    vehicle_id,
	startdate,
    starttime,
	trip)
SELECT trip_id, vehicle_id, startdate, starttime,
 tgeompointseq(array_agg(tgeompointinst(point, to_timestamp(instant)) ORDER BY instant))
FROM positions
GROUP BY trip_id, vehicle_id, starttime, startdate;

\! echo '...Updating trip_mdb'
ALTER TABLE trips_mdb ADD COLUMN traj geometry;
UPDATE trips_mdb
SET Traj = trajectory(Trip);