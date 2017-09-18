-- By Hayden Woodhead and Dominic Porter
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE TABLE IF NOT EXISTS agency (
  agency_id UUID NOT NULL UNIQUE,
  gtfs_agency_id text,
  agency_name text NOT NULL,
  PRIMARY KEY (agency_id)
);

CREATE TABLE IF NOT EXISTS routes (
  route_id UUID NOT NULL UNIQUE,
  gtfs_route_id text,
  agency_id UUID NOT NULL,
  route_short_name text NOT NULL,
  route_long_name text NOT NULL,
  route_type int,
  CONSTRAINT routes_agency_id_fkey FOREIGN KEY (agency_id)
    REFERENCES agency (agency_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  PRIMARY KEY (route_id)
);

CREATE TABLE IF NOT EXISTS stops (
  stop_id UUID NOT NULL UNIQUE ,
  stop_code text,
  stop_name text NOT NULL,
  stop_lat DOUBLE PRECISION NOT NULL,
  stop_lon DOUBLE PRECISION NOT NULL,
  PRIMARY KEY (stop_id)
);

CREATE TABLE IF NOT EXISTS calendar (
  service_id UUID NOT NULL UNIQUE,
  gtfs_service_id text,
  start_date text,
  end_date text,
  monday BOOLEAN,
  tuesday BOOLEAN,
  wednesday BOOLEAN,
  thursday BOOLEAN,
  friday BOOLEAN,
  saturday BOOLEAN,
  sunday BOOLEAN,
  PRIMARY KEY (service_id)
);

CREATE TABLE IF NOT EXISTS trips (
  trip_id UUID NOT NULL UNIQUE,
  route_id UUID NOT NULL,
  service_id UUID NOT NULL,
  gtfs_trip_id text,
  trip_headsign text NOT NULL,
  CONSTRAINT trips_route_id_fkey FOREIGN KEY (route_id)
    REFERENCES routes (route_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT trips_service_id_fkey FOREIGN KEY (service_id)
    REFERENCES calendar (service_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  PRIMARY KEY (trip_id)
);

CREATE TABLE IF NOT EXISTS stop_times (
  stoptime_id UUID NOT NULL UNIQUE,
  trip_id UUID NOT NULL,
  arrival_time time NOT NULL,
  departure_time time NOT NULL,
  stop_id UUID NOT NULL,
  stop_sequence integer NOT NULL,
  CONSTRAINT stop_times_trip_id_fkey FOREIGN KEY (trip_id)
    REFERENCES trips (trip_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT stop_times_stop_id_fkey FOREIGN KEY (stop_id)
    REFERENCES stops (stop_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  PRIMARY KEY (stoptime_id)
);

CREATE TABLE IF NOT EXISTS users (
  user_id UUID NOT NULL UNIQUE,
  email text,
  name text,
  password bytea,
  date_created TIMESTAMPTZ,
  PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS tokens (
  token_id UUID NOT NULL UNIQUE,
  user_id UUID NOT NULL,
  date_created TIMESTAMPTZ,
  PRIMARY KEY (token_id),
  CONSTRAINT tokens_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS notification (
  notification_id UUID NOT NULL UNIQUE,
  user_id UUID NOT NULL,
  type char(1),
  name text,
  value text,
  CONSTRAINT notification_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT valid_type CHECK (type IN ('e', 't', 'p')),
  PRIMARY KEY (notification_id)
);

CREATE TABLE IF NOT EXISTS subscription (
  sub_id UUID NOT NULL UNIQUE,
  trip_id UUID NOT NULL,
  stoptime_id UUID NOT NULL,
  user_id UUID NOT NULL,
  archived BOOLEAN,
  date_created TIMESTAMPTZ,
  monday BOOLEAN,
  tuesday BOOLEAN,
  wednesday BOOLEAN,
  thursday BOOLEAN,
  friday BOOLEAN,
  saturday BOOLEAN,
  sunday BOOLEAN,
  CONSTRAINT subscription_trip_id_fkey FOREIGN KEY (trip_id)
    REFERENCES trips (trip_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT subscription_stoptime_id_fkey FOREIGN KEY (stoptime_id)
    REFERENCES stop_times (stoptime_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT subscription_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES users (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  PRIMARY KEY (sub_id)
);

CREATE TABLE IF NOT EXISTS notification_event (
  notification_event_id UUID NOT NULL UNIQUE,
  sub_id UUID NOT NULL,
  date_created TIMESTAMPTZ,
  CONSTRAINT notification_event_sub_id_fkey FOREIGN KEY (sub_id)
    REFERENCES subscription (sub_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  PRIMARY KEY (notification_event_id)
);

CREATE TABLE IF NOT EXISTS sub_notification (
  sub_id UUID NOT NULL UNIQUE,
  notification_id UUID NOT NULL UNIQUE,
  CONSTRAINT sub_notification_sub_id_fkey FOREIGN KEY (sub_id)
    REFERENCES subscription (sub_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sub_notification_notification_id_fkey FOREIGN KEY (notification_id)
    REFERENCES notification (notification_id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  PRIMARY KEY (sub_id, notification_id)
);
