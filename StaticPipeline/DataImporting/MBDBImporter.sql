\! echo '...Creating trip_stops'
DROP TABLE IF EXISTS trip_stops;
CREATE TABLE trip_stops
(
  trip_id text,
  stop_sequence integer,
  no_stops integer,
  route_id text,
  service_id text,
  shape_id text,
  stop_id text,
  arrival_time interval,
  perc float
);
\! echo '...Inserting trip_stops'

INSERT INTO trip_stops (trip_id, stop_sequence, no_stops, route_id, service_id,
	shape_id, stop_id, arrival_time) (
SELECT t.trip_id, stop_sequence,
	MAX(stop_sequence) OVER (PARTITION BY t.trip_id),
	route_id, service_id, t.shape_id, st.stop_id, arrival_time
FROM trips t JOIN stop_times st ON t.trip_id = st.trip_id
);


\! echo '...Updating trip_stops'
UPDATE trip_stops t
SET perc = CASE
	WHEN stop_sequence =  1 then 0::float
	WHEN stop_sequence =  no_stops then 1.0::float
	ELSE ST_LineLocatePoint(shape_geom, stop_geom)
END
FROM shape_geoms g, stops s
WHERE t.shape_id = g.shape_id
AND t.stop_id = s.stop_id;


\! echo '...Creating trip_segs'
DROP TABLE IF EXISTS trip_segs;
CREATE TABLE trip_segs (
	trip_id text,
	route_id text,
	service_id text,
	stop1_sequence integer,
	stop2_sequence integer,
	no_stops integer,
	shape_id text,
	stop1_arrival_time interval,
	stop2_arrival_time interval,
	perc1 float,
	perc2 float,
	seg_geom geometry,
	seg_length float,
	no_points integer,
	PRIMARY KEY (trip_id, stop1_sequence)
);

\! echo '...Inserting trip_segs'
INSERT INTO trip_segs (trip_id, route_id, service_id, stop1_sequence, stop2_sequence,
	no_stops, shape_id, stop1_arrival_time, stop2_arrival_time, perc1, perc2)
WITH temp AS (
	SELECT t.trip_id, t.route_id, t.service_id, t.stop_sequence,
		LEAD(stop_sequence) OVER w AS stop_sequence2,
		MAX(stop_sequence) OVER (PARTITION BY trip_id),
		t.shape_id, t.arrival_time, LEAD(arrival_time) OVER w,
		t.perc, LEAD(perc) OVER w
	FROM trip_stops t WINDOW w AS (PARTITION BY trip_id ORDER BY stop_sequence)
)
SELECT * FROM temp WHERE stop_sequence2 IS NOT null;

\! echo '...Updating trip_segs'
UPDATE trip_segs t
SET seg_geom =
   (CASE WHEN perc1 > perc2 THEN seg_geom
    ELSE ST_LineSubstring(shape_geom, perc1, perc2)
    END)
FROM shape_geoms g
WHERE t.shape_id = g.shape_id;

\! echo '...Updating trip_segs 2'
UPDATE trip_segs t
SET seg_length = ST_Length(seg_geom), no_points = ST_NumPoints(seg_geom);


\! echo '...Creating trip_points'
DROP TABLE IF EXISTS trip_points;
CREATE TABLE trip_points (
	trip_id text,
	route_id text,
	service_id text,
	stop1_sequence integer,
	point_sequence integer,
	point_geom geometry,
	point_arrival_time interval,
	PRIMARY KEY (trip_id, stop1_sequence, point_sequence)
);

\! echo '...Inserting trip_points'
INSERT INTO trip_points (trip_id, route_id, service_id, stop1_sequence,
	point_sequence, point_geom, point_arrival_time)
WITH temp1 AS (
	SELECT trip_id, route_id, service_id, stop1_sequence,
		stop2_sequence, no_stops, stop1_arrival_time, stop2_arrival_time, seg_length,
		(dp).path[1] AS point_sequence, no_points, (dp).geom as point_geom
	FROM trip_segs, ST_DumpPoints(seg_geom) AS dp
),
temp2 AS (
	SELECT trip_id, route_id, service_id, stop1_sequence,
		stop1_arrival_time, stop2_arrival_time, seg_length,  point_sequence,
		no_points, point_geom
	FROM temp1
	WHERE point_sequence <> no_points OR stop2_sequence = no_stops
),
temp3 AS (
	SELECT trip_id, route_id, service_id, stop1_sequence,
		stop1_arrival_time, stop2_arrival_time, point_sequence, no_points, point_geom,
		ST_Length(ST_Makeline(array_agg(point_geom) OVER w)) / seg_length AS perc
	FROM temp2 WINDOW w AS (PARTITION BY trip_id, service_id, stop1_sequence
		ORDER BY point_sequence)
)
SELECT trip_id, route_id, service_id, stop1_sequence,
	point_sequence, point_geom,,
	CASE
	WHEN point_sequence = 1 then stop1_arrival_time
	WHEN point_sequence = no_points then stop2_arrival_time
	ELSE stop1_arrival_time + ((stop2_arrival_time - stop1_arrival_time) * perc)
	END AS point_arrival_time
FROM temp3;

WITH temp AS (
	SELECT t.*, LEAD(point_arrival_time) OVER
		(PARTITION BY trip_id, service_id, stop1_sequence
		ORDER BY point_arrival_time) AS next_arrival_time
	FROM trip_points t )
SELECT DISTINCT trip_id FROM temp WHERE point_arrival_time >= next_arrival_time;

\! echo '...Creating trip_input'
DROP TABLE IF EXISTS trips_input;
CREATE TABLE trips_input (
	trip_id text,
	route_id text,
	service_id text,
	date date,
	point_geom geometry,
	t timestamptz
);

\! echo '...Inserting trip_input'
INSERT INTO trips_input
SELECT trip_id, route_id, t.service_id,
	date, point_geom, date + point_arrival_time AS t
FROM trip_points t JOIN service_dates s ON t.service_id = s.service_id;

WITH temp AS (
	SELECT trip_id, t, LEAD(t) OVER (PARTITION BY trip_id ORDER BY t) AS t1
	FROM trips_input )
SELECT DISTINCT trip_id FROM temp WHERE t >= t1;

\! echo '...Creating trip_mdb'
DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
	trip_id text NOT NULL,
	route_id text NOT NULL,
	date date NOT NULL,
	trip tgeompoint,
	PRIMARY KEY (trip_id, date)
);

\! echo '...Inserting trip_mdb'
INSERT INTO trips_mdb(trip_id, route_id, date, trip)
SELECT trip_id, route_id, date, tgeompointseq(array_agg(tgeompointinst(point_geom, t) ORDER BY T))
FROM trips_input
GROUP BY trip_id, route_id, date;

\! echo '...Updating trip_mdb'
ALTER TABLE trips_mdb ADD COLUMN traj geometry;
UPDATE trips_mdb
SET Traj = trajectory(Trip);

ALTER TABLE trips_mdb ADD COLUMN starttime timestamp;
UPDATE trips_mdb SET starttime = startTimestamp(trip);