DROP TABLE bondis_1;
CREATE TABLE bondis_1 (
  trip_id text,
  seg_geom geometry
);

\! echo '...Inserting trip_mdb'
INSERT INTO bondis_1(
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

DROP TABLE bondis_2;
CREATE TABLE bondis_2 (
  trip_id text,
  seg_geom geometry
);

\! echo '...Inserting trip_mdb'
INSERT INTO bondis_2(
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

DROP TABLE bondis_3;
CREATE TABLE bondis_3 (
  trip_id text,
  seg_geom geometry
);

\! echo '...Inserting trip_mdb'
INSERT INTO bondis_3(
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

DROP TABLE bondis_4;
CREATE TABLE bondis_4 (
  trip_id text,
  seg_geom geometry
);

\! echo '...Inserting trip_mdb'
INSERT INTO bondis_4(
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


DROP TABLE bondis_5;
CREATE TABLE bondis_5 (
  trip_id text,
  seg_geom geometry
);

\! echo '...Inserting trip_mdb'
INSERT INTO bondis_5(
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