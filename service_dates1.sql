DROP VIEW IF EXISTS service_dates;
CREATE VIEW service_dates AS (
	SELECT service_id, date_trunc('day', date)::date AS date
	FROM calendar_dates d
	WHERE exception_type = 1
);