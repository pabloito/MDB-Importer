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