WITH buckets (bucketNo, bucketRange) AS (
	SELECT 1, intrange '[0, 2)' UNION
	SELECT 2, intrange '[2, 10)' UNION
	SELECT 3, intrange '[10, 50)' UNION
	SELECT 4, intrange '[100, 200)' UNION
	SELECT 5, intrange '[200, 500)' UNION
	SELECT 6, intrange '[500, 1000)' UNION
	SELECT 7, intrange '[1000, 100000)'),
vals (trip_id, amount) AS (
    SELECT trip_id, count(trip_id) AS amount
    FROM positions
    GROUP BY trip_id
),
valswithBucket (bucketNo, bucketRange, trip_id) AS (
	SELECT bucketNo, bucketRange, trip_id
	FROM buckets LEFT OUTER JOIN vals ON amount::int <@ bucketRange
),
histogram (bucketNo, bucketRange, freq) AS (
    SELECT bucketNo, bucketRange, count(*) AS freq
    FROM valswithBucket
	GROUP BY bucketNo, bucketRange
	ORDER BY bucketNo, bucketRange
)
SELECT bucketNo, bucketRange, freq,
	repeat('■', ( freq::float / max(freq) OVER () * 30 )::int ) AS bar
FROM histogram;