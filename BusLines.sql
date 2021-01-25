DROP TABLE IF EXISTS routes CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS BusLines CASCADE;

CREATE TABLE trips (
  route_id text NOT NULL,
  service_id text NOT NULL,
  trip_id text NOT NULL,
  shape_id text
);
CREATE INDEX trips_trip_id ON trips (trip_id);

CREATE TABLE routes (
  route_id text NOT NULL,
  agency_id text NOT NULL,
  route_short_name text NOT NULL,
  route_long_name text NOT NULL,
  route_desc text NOT NULL,
  route_type text NOT NULL
);

COPY trips(route_id,service_id,trip_id,shape_id) from '/gtfsstaticagosto/trips.txt' DELIMITER ',' CSV HEADER;
COPY routes(route_id,agency_id,route_short_name,route_long_name,route_desc,route_type) from '/gtfsstaticagosto/routes.txt' DELIMITER ',' CSV HEADER;

CREATE TABLE BusLines (
    trip_id text NOT NULL,
    agency_id text NOT NULL,
    route_short_name text NOT NULL,
    route_long_name text NOT NULL,
    route_desc text NOT NULL,
    route_type text NOT NULL
);

INSERT INTO BusLines (trip_id, agency_id, route_short_name, route_long_name, route_desc, route_type) (
    SELECT t.trip_id, agency_id, route_short_name, route_long_name, route_desc, route_type
    FROM trips as t join routes as r on t.route_id = r.route_id
);