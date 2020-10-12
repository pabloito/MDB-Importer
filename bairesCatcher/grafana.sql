-- Average speed by starting hour (ST)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('hour',startTimestamp(Trip)) at time zone 'America/Argentina/Buenos_Aires' as time
FROM Trips_mdb
group by time
order by time;

--Average speed by starting hour (RT)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('hour', starttimefull) at time zone 'America/Argentina/Buenos_Aires' as time
FROM Trips_mdbrt
WHERE starttimefull is not null
group by time
order by time;

-- Average speed by starting day (ST)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('day',startTimestamp(Trip)) at time zone 'America/Argentina/Buenos_Aires' as time
FROM Trips_mdb
group by time
order by time;

--Average speed by starting day (RT)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('day', starttimefull) at time zone 'America/Argentina/Buenos_Aires' as time
FROM Trips_mdbrt
WHERE starttimefull is not null
group by time
order by time;


SELECT
  'Aug 23 13:43:07 America/Argentina/Buenos_Aires 2020'::timestamp with time zone as time,
  100 as value,
  s.stop_lat as latitude,
  s.stop_lon as longitude,
  s.stop_id as name
FROM stops s inner join stop_times st on st.stop_id = s.stop_id
limit 100;
