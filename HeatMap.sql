-- Segments where realtime was close to static.
-- Tolerance 100m and 20s
DROP TABLE heatmap1;
CREATE TABLE heatmap1 (
  trip_id text,
  seg_geom geometry
);
INSERT INTO heatmap1(
    trip_id,
    seg_geom)
SELECT ST.trip_id,
       getvalues(atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 100), TRUE))))
FROM trips_mdb ST,
     trips_mdbrt RT
WHERE ST.trip_id = RT.trip_id
  AND ST.Trip && expandSpatial(RT.Trip, 100)
  AND atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 20), TRUE))) IS NOT NULL
ORDER BY ST.trip_id;

-- Segments where realtime was close to static.
-- Tolerance 50m and 10s
DROP TABLE heatmap2;
CREATE TABLE heatmap2 (
  trip_id text,
  seg_geom geometry
);
INSERT INTO heatmap2(
    trip_id,
    seg_geom)
SELECT ST.trip_id,
       getvalues(atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 50), TRUE))))
FROM trips_mdb ST,
     trips_mdbrt RT
WHERE ST.trip_id = RT.trip_id
  AND ST.Trip && expandSpatial(RT.Trip, 50)
  AND atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 10), TRUE))) IS NOT NULL
ORDER BY ST.trip_id;

-- Segments where realtime was close to static.
-- Tolerance 25m and 10s
DROP TABLE heatmap3;
CREATE TABLE heatmap3 (
  trip_id text,
  seg_geom geometry
);
INSERT INTO heatmap3(
    trip_id,
    seg_geom)
SELECT ST.trip_id,
       getvalues(atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 25), TRUE))))
FROM trips_mdb ST,
     trips_mdbrt RT
WHERE ST.trip_id = RT.trip_id
  AND ST.Trip && expandSpatial(RT.Trip, 25)
  AND atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 5), TRUE))) IS NOT NULL
ORDER BY ST.trip_id;

-- Segments where realtime was close to static.
-- Tolerance 10m and 2s
DROP TABLE heatmap4;
CREATE TABLE heatmap4 (
  trip_id text,
  seg_geom geometry
);
INSERT INTO heatmap4(
    trip_id,
    seg_geom)
SELECT ST.trip_id,
       getvalues(atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 10), TRUE))))
FROM trips_mdb ST,
     trips_mdbrt RT
WHERE ST.trip_id = RT.trip_id
  AND ST.Trip && expandSpatial(RT.Trip, 10)
  AND atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 2), TRUE))) IS NOT NULL
ORDER BY ST.trip_id;

-- Segments where realtime was close to static.
-- Tolerance 5m and 1s
DROP TABLE heatmap5;
CREATE TABLE heatmap5 (
  trip_id text,
  seg_geom geometry
);
INSERT INTO heatmap5(
    trip_id,
    seg_geom)
SELECT ST.trip_id,
       getvalues(atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 5), TRUE))))
FROM trips_mdb ST,
     trips_mdbrt RT
WHERE ST.trip_id = RT.trip_id
  AND ST.Trip && expandSpatial(RT.Trip, 5)
  AND atPeriodSet(ST.Trip, getTime(atValue(tdwithin(ST.Trip, RT.Trip, 1), TRUE))) IS NOT NULL
ORDER BY ST.trip_id;