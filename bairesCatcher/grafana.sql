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