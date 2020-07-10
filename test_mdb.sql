SELECT count(*) FROM trips_mdb;
SELECT count(*) FROM trips_mdb WHERE GeometryType(Traj) = 'POINT';
SELECT count(*) FROM trips_mdb WHERE GeometryType(Traj) = 'LINESTRING';

SELECT extent(Trip) from trips_mdb;
SELECT maxValue(tcount(Trip)) FROM trips_mdb;
SELECT AVG(timespan(Trip)/numInstants(Trip)) FROM trips_mdb;
SELECT SUM(length(Trip)) / 1e3 as TotalLengthKm FROM trips_mdb;
SELECT AVG(timespan(Trip)) FROM trips_mdb;
SELECT AVG(timespan(Trip)/numInstants(Trip)) FROM trips_mdb WHERE length(Trip) > 0;

WITH buckets (bucketNo, bucketRange) AS (
	SELECT 1, floatrange '[0, 0]' UNION
	SELECT 2, floatrange '(0, 100)' UNION
	SELECT 3, floatrange '[100, 1000)' UNION
	SELECT 4, floatrange '[1000, 5000)' UNION
	SELECT 5, floatrange '[5000, 10000)' UNION
	SELECT 6, floatrange '[10000, 50000)' UNION
	SELECT 7, floatrange '[50000, 100000)' ),
histogram AS (
	SELECT bucketNo, bucketRange, count(trip_id) as freq
	FROM buckets left outer join trips_mdb on length(trip) <@ bucketRange
	GROUP BY bucketNo, bucketRange
	ORDER BY bucketNo, bucketRange
)
SELECT bucketNo, bucketRange, freq,
	repeat('■', ( freq::float / max(freq) OVER () * 30 )::int ) AS bar
FROM histogram;