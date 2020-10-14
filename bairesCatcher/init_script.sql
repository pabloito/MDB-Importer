CREATE TABLE IF NOT EXISTS positions
(
    trip_id     text,
    vehicle_id  text   NOT NULL,
    instant     bigint NOT NULL,
    latitude    float  NOT NULL,
    longitude   float  NOT NULL,
    startdate   text,
    starttime   text,
    directionId int,
    PRIMARY KEY (trip_id, vehicle_id, instant)
);

CREATE TABLE IF NOT EXISTS trips_mdb_rt
(
  trip_id text NOT NULL,
  vehicle_id text NOT NULL,
  startdate text NOT NULL,
  starttime text NOT NULL,
  starttimefull timestamp,
  trip tgeompoint,
  traj geometry,
  CONSTRAINT trips_mdb_pkey PRIMARY KEY (trip_id, vehicle_id, startdate, starttime)
)