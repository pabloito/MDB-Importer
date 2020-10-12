-- Average speed by starting hour (ST)
SELECT AVG(twavg(speed(Trip))) as static, date_trunc('hour',startTimestamp(Trip)) at time zone 'GMT-3' as time
FROM Trips_mdb
group by time
order by time;

--Average speed by starting hour (RT)
SELECT AVG(twavg(speed(Trip))) as realtime, date_trunc('hour', starttimefull) at time zone 'America/Argentina/Buenos_Aires' as time
FROM Trips_mdbrt
WHERE starttimefull is not null
group by time
order by time;

-- Average speed by starting day (ST)
SELECT AVG(twavg(speed(Trip))) as static, date_trunc('day',startTimestamp(Trip)) at time zone 'GMT-3' as time
FROM Trips_mdb
group by time
order by time;

--Average speed by starting day (RT)
SELECT AVG(twavg(speed(Trip))) as realtime, date_trunc('day', starttimefull) at time zone 'America/Argentina/Buenos_Aires' as time
FROM Trips_mdbrt
WHERE starttimefull is not null
group by time
order by time;

-- Average delay by line
SELECT NOW() AS "time", bl.route_short_name AS metric,
  AVG(EXTRACT(EPOCH FROM timespan(rt.trip))/60 - EXTRACT(EPOCH FROM timespan(st.trip))/60) as value
FROM trips_mdb as rt
  join trips_mdb_static as st on rt.trip_id = st.trip_id
  join buslines as bl on rt.trip_id = bl.trip_id
GROUP BY route_short_name
ORDER BY value DESC;

-- Lines that pass less than 200 m of Teatro Colon
WITH trip_distances as (
 SELECT bl.route_short_name as line, ST_Length(shortestLine(trip, ST_SetSRID(ST_MakePoint(4199468.71, 6145133.6),5345))) as distance
    FROM trips_mdb_static as st join buslines as bl on st.trip_id = bl.trip_id
    WHERE ST_Length(shortestLine(trip, ST_SetSRID(ST_MakePoint(4199468.71, 6145133.6),5345))) < 200
)
SELECT NOW() AS "time", line AS metric, AVG(distance) as value
FROM trip_distances
GROUP BY line
ORDER BY value ASC;

-- IDS of buses that pass less than 200 metres of Teatro Colon
select trip_id from buslines as b join (WITH trip_distances as (
 SELECT bl.route_short_name as line, ST_Length(shortestLine(trip, ST_SetSRID(ST_MakePoint(4199468.71, 6145133.6),5345))) as distance
    FROM trips_mdb_static as st join buslines as bl on st.trip_id = bl.trip_id
    WHERE ST_Length(shortestLine(trip, ST_SetSRID(ST_MakePoint(4199468.71, 6145133.6),5345))) < 200
)
SELECT NOW() AS "time", line AS metric, line, AVG(distance) as value
FROM trip_distances
GROUP BY line) as a on b.route_short_name = line;
