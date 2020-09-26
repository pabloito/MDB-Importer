-- Average speed by starting hour (ST)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('hour',startTimestamp(Trip)) as time
FROM Trips_mdb
group by time
order by time;

--Average speed by starting hour (RT)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('hour', starttimefull) as time
FROM Trips_mdbrt
WHERE starttimefull is not null
group by time
order by time;

-- Average speed by starting hour (ST, RT lines)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('hour',startTimestamp(Trip)) as time
FROM Trips_mdb t1
WHERE EXISTS (
	SELECT *
	FROM Trips_mdbrt t2
	WHERE t1.trip_id = t2.trip_id		
)
group by time
order by time;

-- Average speed by starting day (ST)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('day',startTimestamp(Trip)) as time
FROM Trips_mdb
group by time
order by time;

--Average speed by starting day (RT)
SELECT AVG(twavg(speed(Trip))) as value, date_trunc('day', starttimefull) as time
FROM Trips_mdbrt
WHERE starttimefull is not null
group by time
order by time;


