-- Source: staging.normalized_carrier_events
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity) — Pattern A
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.staging.normalized_carrier_events`
(
  `tracking_no`      STRING,
  `carrier`          STRING,
  `event_type`       STRING,
  `event_ts`         DATETIME,
  `location_city`    STRING,
  `location_region`  STRING,
  `location_country` STRING,
  `ingest_ts`        TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
