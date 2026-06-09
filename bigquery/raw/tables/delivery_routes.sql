-- Source: raw.delivery_routes
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: TEXTFILE (CSV) -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.delivery_routes`
(
  `route_id`      STRING,
  `driver_id`     STRING,
  `vehicle_id`    STRING,
  `planned_stops` INT64,
  `actual_stops`  INT64,
  `miles_driven`  NUMERIC,
  `fuel_used`     NUMERIC,
  `start_ts`      DATETIME,
  `end_ts`        DATETIME,
  `ingest_ts`     TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
