CREATE TABLE IF NOT EXISTS metadata (
  id bigint,
  route_id text,
  agency_id int,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS positions (
  id bigint,
  instant bigint NOT NULL,
  latitude float NOT NULL,
  longitude float NOT NULL,
  PRIMARY KEY (id, instant),
  CONSTRAINT fk_metadata
    FOREIGN KEY(id)
    REFERENCES metadata(id)
);
