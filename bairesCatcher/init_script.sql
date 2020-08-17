CREATE TABLE IF NOT EXISTS positions (
  trip_id text,
  vehicle_id text NOT NULL,
  instant bigint NOT NULL,
  latitude float NOT NULL,
  longitude float NOT NULL,
  startdate text,
  starttime text,
  directionId int,
  PRIMARY KEY (trip_id, vehicle_id, instant)
);