------------------------------
-- TABLE routes, PK: route_id

SELECT COUNT(*) FROM routes 
90

SELECT * FROM routes LIMIT 3

SELECT route_id, route_long_name FROM routes LIMIT 3

------------------------------
-- TABLE shape_geoms, PK: shape_id

SELECT COUNT(*) FROM shape_geoms 
832

SELECT * FROM shape_geoms LIMIT 3

-- This query can be visualize IN PgAdmin4
SELECT * FROM shape_geoms LIMIT 50

-- The are self-intersecting shape_geoms
SELECT COUNT(*) FROM shape_geoms WHERE NOT ST_IsSimple(the_geom)
91

------------------------------
-- TABLE stops, PK: stop_id

SELECT COUNT(*) FROM stops 
2808

SELECT * FROM stops LIMIT 3

SELECT stop_id, stop_name, the_geom FROM stops LIMIT 3

------------------------------
-- TABLE calendar, PK: service_id

SELECT * FROM calendar LIMIT 3

SELECT service_id, start_date, end_date FROM calendar LIMIT 3

SELECT MIN(start_date), MAX(end_date) FROM calendar;
2019-10-28, 2019-11-03

SELECT COUNT(*) FROM calendar
71

SELECT COUNT(*) FROM calendar WHERE start_date < end_date
60

SELECT COUNT(*) FROM calendar WHERE start_date = end_date
11

SELECT COUNT(*) FROM calendar WHERE start_date <= '2019-11-01'
AND end_date <= '2019-11-01'
29

SELECT COUNT(*) FROM calendar WHERE start_date = '2019-11-01'
AND end_date = '2019-11-01'
5

SELECT COUNT(*) FROM calendar WHERE start_date <= '2019-10-31' 
AND '2019-10-31' <= end_date
59

------------------------------
-- TABLE exception_types, PK: exception_type

SELECT * FROM exception_types;

1	"service has been added"
2	"service has been removed"

------------------------------
-- TABLE calendar_dates, PK: service_id, date (NOT defined)

SELECT * FROM calendar_dates LIMIT 3

SELECT service_id, date, exception_type FROM calendar_dates LIMIT 3

SELECT DISTINCT exception_type FROM calendar_dates 
1
2

SELECT COUNT(*) FROM calendar_dates
59

SELECT exception_type, COUNT(*) FROM calendar_dates  GROUP BY exception_type
1	"21"
2	"174"

SELECT DISTINCT d1.service_id
FROM calendar_dates d1, calendar_dates d2 WHERE d1.service_id = d2.service_id 
AND d1.exception_type = 1 AND d2.exception_type = 2
"199594602"

SELECT COUNT(DISTINCT service_id) FROM calendar_dates
52

SELECT service_id, COUNT(*) FROM calendar_dates GROUP BY service_id
"201032603"	"1"
"201225606"	"1"
"191808070"	"9"
"191027600"	"1"
... 
-- 52 rows

------------------------------
-- Join of tables calendar AND calendar_dates
-- Useful resource http://transitdata.net/ON-calendars-AND-calendar_dates/

SELECT COUNT(*) FROM calendar c JOIN calendar_dates d ON c.service_id = d.service_id
195

SELECT 'no exception', COUNT(*) FROM calendar 
WHERE service_id NOT IN
(SELECT DISTINCT service_id FROM calendar_dates)
UNION
SELECT 'exception 1', COUNT(*) FROM calendar 
WHERE service_id IN
(SELECT DISTINCT service_id FROM calendar_dates WHERE exception_type = 1)
AND service_id NOT IN
(SELECT DISTINCT service_id FROM calendar_dates WHERE exception_type = 2)
UNION
SELECT 'exception 2', COUNT(*) FROM calendar 
WHERE service_id NOT IN
(SELECT DISTINCT service_id FROM calendar_dates WHERE exception_type = 1)
AND service_id IN
(SELECT DISTINCT service_id FROM calendar_dates WHERE exception_type = 2)
UNION
SELECT 'exception 1 AND 2', COUNT(*) FROM calendar 
WHERE service_id IN
(SELECT DISTINCT service_id FROM calendar_dates WHERE exception_type = 1)
AND service_id IN
(SELECT DISTINCT service_id FROM calendar_dates WHERE exception_type = 2)

"exception 2"	"31"
"exception 1"	"20"
"exception 1 AND 2"	"1"
"no exception"	"123"

SELECT DISTINCT d1.service_id
FROM calendar_dates d1, calendar_dates d2 WHERE d1.service_id = d2.service_id 
AND d1.exception_type = 1 AND d2.exception_type = 2
"199594602"

SELECT c.service_id, start_date, end_date, date, exception_type 
FROM calendar c JOIN calendar_dates d ON c.service_id = d.service_id
WHERE c.service_id = '193315001'
ORDER BY date

"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-09"	2
"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-11"	2
"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-14"	2
"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-15"	2
"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-16"	2
"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-17"	2
"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-18"	2
"193315001"	"2019-10-07"	"2019-10-24"	"2019-10-23"	2

SELECT * FROM calendar WHERE service_id IN 
(SELECT service_id FROM calendar_dates WHERE exception_type = 1)
-- 21 rows

SELECT MAX(end_date - start_date + 1) AS duration FROM calendar
22

SELECT * FROM calendar WHERE end_date - start_date + 1 = 
(SELECT MAX(end_date - start_date + 1) AS duration FROM calendar)
-- 17 rows

SELECT service_id, date_trunc('day', d)::date AS date 
FROM calendar c, generate_series(start_date, end_date, '1 day'::interval) AS d
WHERE (
(monday = 1 AND extract(isodow FROM d) = 1) OR
(tuesday = 1 AND extract(isodow FROM d) = 2) OR
(wednesday = 1 AND extract(isodow FROM d) = 3) OR
(thursday = 1 AND extract(isodow FROM d) = 4) OR
(friday = 1 AND extract(isodow FROM d) = 5) OR
(saturday = 1 AND extract(isodow FROM d) = 6) OR
(sunday = 1 AND extract(isodow FROM d) = 7) 
)
AND service_id = '199723002'

SELECT c.service_id, date
FROM calendar c JOIN calendar_dates d ON c.service_id = d.service_id 
WHERE exception_type = 1 AND start_date = date AND end_date =  date

SELECT COUNT(*) FROM calendar_dates WHERE exception_type = 2
174

SELECT * 
FROM calendar c JOIN calendar_dates d ON c.service_id = d.service_id 
WHERE exception_type = 1 AND start_date <= date AND date <= end_date
1	"199594602"	0	0	0	0	0	0	1	"2019-10-13"	"2019-11-03"	1	"199594602"	"2019-11-01"	1
....
-- 21 rows

------------------------------
-- TABLE trips, PK: trip_id

SELECT * FROM trips LIMIT 3;

SELECT trip_id, route_id, service_id, direction_id, shape_id FROM trips LIMIT 3

SELECT COUNT(*) FROM trips 
3937

SELECT DISTINCT(direction_id) FROM trips 
0
1

SELECT route_id, COUNT(*) FROM trips GROUP BY route_id ORDER BY route_id::int

"1"	"2834"
"2"	"2611"
"3"	"2299"
"4"	"2560"
"5"	"1571"
...

SELECT route_id, service_id, COUNT(*) FROM trips 
GROUP BY route_id, service_id ORDER BY route_id::int, service_id

"1"	"191020500"	"264"
"1"	"193444001"	"377"
"1"	"198046503"	"268"
"1"	"198049002"	"376"
"1"	"198055003"	"377"
"1"	"198337601"	"223"
"1"	"199030004"	"377"
"1"	"199594602"	"224"
"1"	"200039050"	"348"
"2"	"191020500"	"250"
"2"	"193444001"	"344"
"2"	"198046503"	"254"
"2"	"198049002"	"343"
"2"	"198055003"	"343"
"2"	"198337601"	"210"
"2"	"199030004"	"343"
"2"	"199594602"	"208"
"2"	"200039050"	"316"
"3"	"191020500"	"244"
...

------------------------------
-- TABLE stop_times, PK: (trip_id, stop_sequence)

SELECT * FROM stop_times LIMIT 3

SELECT trip_id, stop_sequence, arrival_time, departure_time, stop_id FROM stop_times LIMIT 3

SELECT * FROM stop_times WHERE arrival_time <> departure_time
0

SELECT COUNT(*) FROM stop_times 
92262

SELECT COUNT(DISTINCT trip_id) FROM stop_times 
168758

SELECT trip_id, MAX(stop_sequence) AS no_stops FROM stop_times GROUP BY trip_id
"105624332191013000"	35
"105624333191013000"	35
"105624334191013000"	14

------------------------------
-- Join of trips, shape_geoms, stop_times, AND stops

SELECT COUNT(*) FROM trips t JOIN stop_times s ON t.trip_id = s.trip_id
3515213

SELECT COUNT(*) FROM trips WHERE trip_id NOT IN (SELECT trip_id FROM stops)
0

SELECT DISTINCT trip_id FROM trips LIMIT 2

SELECT route_id, service_id, trip_id, direction_id, shape_id FROM trips LIMIT 3

SELECT t.trip_id, sequence_id, route_id, service_id, direction_id, shape_id, arrival_time, stop_id
FROM trips t JOIN stop_times s ON t.trip_id = s.trip_id
WHERE t.trip_id = '105725414193315001' 
ORDER BY stop_sequence

------------------------------
-- Creation of tables
------------------------------

DROP VIEW IF EXISTS service_dates;
CREATE VIEW service_dates AS (
	SELECT service_id, date_trunc('day', d)::date AS date 
	FROM calendar c, generate_series(start_date, end_date, '1 day'::interval) AS d
	WHERE (
		(monday = 1 AND extract(isodow FROM d) = 1) OR
		(tuesday = 1 AND extract(isodow FROM d) = 2) OR
		(wednesday = 1 AND extract(isodow FROM d) = 3) OR
		(thursday = 1 AND extract(isodow FROM d) = 4) OR
		(friday = 1 AND extract(isodow FROM d) = 5) OR
		(saturday = 1 AND extract(isodow FROM d) = 6) OR
		(sunday = 1 AND extract(isodow FROM d) = 7) 
	)
	-- 130 rows
	EXCEPT
	SELECT service_id, date 
	FROM calendar_dates WHERE exception_type = 2
	-- 3 rows
	UNION
	SELECT c.service_id, date
	FROM calendar c JOIN calendar_dates d ON c.service_id = d.service_id 
	WHERE exception_type = 1 AND start_date <= date AND date <= end_date
	-- 21 rows
);

SELECT COUNT(*) FROM service_dates;
148

SELECT service_id, COUNT(DISTINCT date)
FROM service_dates
GROUP BY service_id
ORDER BY COUNT(DISTINCT date) desc
LIMIT 1

200039050;4

------------------------------

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

INSERT INTO trip_stops (trip_id, stop_sequence, no_stops, route_id, service_id,
	shape_id, stop_id, arrival_time) (
SELECT t.trip_id, stop_sequence, 
	MAX(stop_sequence) OVER (PARTITION BY t.trip_id),
	route_id, service_id, t.shape_id, st.stop_id, arrival_time
FROM trips t JOIN stop_times st ON t.trip_id = st.trip_id 
);
-- Query returned successfully: 92262 rows affected, 405 msec execution time.

SELECT COUNT(*) FROM trip_stops;
92262

UPDATE trip_stops t
SET perc = CASE 
	WHEN stop_sequence =  1 then 0::float 
	WHEN stop_sequence =  no_stops then 1.0::float
	ELSE ST_LineLocatePoint(shape_geom, stop_geom)
END
FROM shape_geoms g, stops s
WHERE t.shape_id = g.shape_id
AND t.stop_id = s.stop_id;
-- Query returned successfully: 92262 rows affected, 4.3 secs execution time.

SELECT * FROM trip_stops ORDER BY trip_id, stop_sequence LIMIT 500;

SELECT pg_size_pretty(pg_total_relation_size('trip_stops'));
"19 MB"

------------------------------

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
-- Query returned successfully: 88325 rows affected, 1.0 secs execution time.

SELECT COUNT(*) FROM trip_segs;
88325

UPDATE trip_segs t
SET seg_geom = ST_LineSubstring(shape_geom, perc1, perc2)
FROM shape_geoms g
WHERE t.shape_id = g.shape_id;
-- Query returned successfully: 88325 rows affected, 4.3 secs execution time.

UPDATE trip_segs t
SET seg_length = ST_Length(seg_geom), no_points = ST_NumPoints(seg_geom);
-- Query returned successfully: 88325 rows affected, 1.3 secs execution time.

SELECT * FROM trip_segs LIMIT 50;

SELECT pg_size_pretty(pg_total_relation_size('trip_segs'));
"130 MB"

------------------------------

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
	point_sequence, point_geom, 
	CASE
	WHEN point_sequence = 1 then stop1_arrival_time
	WHEN point_sequence = no_points then stop2_arrival_time
	ELSE stop1_arrival_time + ((stop2_arrival_time - stop1_arrival_time) * perc)
	END AS point_arrival_time
FROM temp3;

-- Query returned successfully: 2404669 rows affected, 01:05 minutes execution time.

SELECT COUNT(*) FROM trip_points
2404669

SELECT * FROM trip_point_segs
ORDER BY trip_id, service_id, stop1_sequence, point_sequence
LIMIT 500

-- To verify the increasing sequence of point_arrival_time

WITH temp AS (
	SELECT t.*, LEAD(point_arrival_time) OVER 
		(PARTITION BY trip_id, service_id, stop1_sequence 
		ORDER BY point_arrival_time) AS next_arrival_time
	FROM trip_point_segs t )
SELECT DISTINCT trip_id FROM temp WHERE point_arrival_time >= next_arrival_time;
-- Query returned successfully: 2404669 rows affected, 23.7 secs execution time.

SELECT COUNT(*) FROM trip_points;
2404669

SELECT * FROM trip_points 
ORDER BY trip_id, service_id, stop1_sequence, point_sequence LIMIT 50;

SELECT pg_size_pretty(pg_total_relation_size('trip_points'));
"383 MB"

------------------------------

DROP TABLE IF EXISTS trips_input;
CREATE TABLE trips_input (
	trip_id text, 
	route_id text,
	service_id text,
	date date,
	point_geom geometry,
	t timestamptz
);

INSERT INTO trips_input
SELECT trip_id, route_id, t.service_id, 
	date, point_geom, date + point_arrival_time AS t
FROM trip_points t JOIN service_dates s ON t.service_id = s.service_id;
-- Query returned successfully: 5964534 rows affected, 26.2 secs execution time.

SELECT COUNT(*) FROM trips_input
5964534

SELECT pg_size_pretty(pg_total_relation_size('trips_input'));
"621 MB"

-- Determine the trips for which the timestamps are NOT increasing
WITH temp AS (
	SELECT trip_id, t, LEAD(t) OVER (PARTITION BY trip_id ORDER BY t) AS t1
	FROM trips_input )
SELECT DISTINCT trip_id FROM temp WHERE t >= t1;
-- Total query runtime: 20.0 secs
-- 0 rows retrieved.

------------------------------

DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
	trip_id text NOT NULL,
	route_id text NOT NULL,
	date date NOT NULL,
	trip tgeompoint,
	PRIMARY KEY (trip_id, date)
);

INSERT INTO trips_mdb(trip_id, route_id, date, trip)
SELECT trip_id, route_id, date, tgeompointseq(array_agg(tgeompointinst(point_geom, t) ORDER BY T))
FROM trips_input
GROUP BY trip_id, route_id, date;
-- Query returned successfully: 9769 rows affected, 01:18 minutes execution time.

SELECT COUNT(*) FROM trips_mdb;
9769

SELECT pg_size_pretty(pg_total_relation_size('trips_mdb'));
"241 MB"

------------------------------
