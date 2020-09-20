alter table trips_mdb_static add column starttime timestamp;
update trips_mdb set starttime = startTimestamp(trip);