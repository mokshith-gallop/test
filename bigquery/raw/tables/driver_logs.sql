-- Source: raw.driver_logs
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: JsonSerDe TEXTFILE -> BigQuery native (managed)
-- Types: STRUCT<lat:DOUBLE, lon:DOUBLE> gps preserved; MAP<STRING,STRING> extras -> JSON

CREATE OR REPLACE TABLE `acme-lake-project.raw.driver_logs`
(
  `driver_id`  STRING,
  `event_ts`   DATETIME,
  `event_type` STRING,
  `gps`        STRUCT<`lat` FLOAT64, `lon` FLOAT64>,
  `notes`      STRING,
  `extras`     JSON,
  `ingest_ts`  TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
