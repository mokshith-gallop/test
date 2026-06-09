-- Source: raw.mobile_events
-- Origin: clusters/acme-lake/hive/07-json-raw.hql
-- Partition: (event_date STRING, hour_bucket TINYINT) -> event_ts TIMESTAMP (HOUR granularity) — Pattern B
-- Cluster: hour_bucket retained as data column + CLUSTER BY
-- Storage: JsonSerDe TEXTFILE -> BigQuery native (managed)
-- Types: MAP<STRING,STRING> properties -> JSON
--        STRUCT<ip,country,session_id,referrer> context preserved
--        ARRAY<STRUCT<sku,qty,price>> items -> ARRAY<STRUCT<sku STRING, qty INT64, price NUMERIC>>
-- Note: Source event_ts TIMESTAMP renamed to event_ts_orig DATETIME to avoid
--       clash with synthetic partition column event_ts TIMESTAMP

CREATE OR REPLACE TABLE `acme-lake-project.raw.mobile_events`
(
  `event_id`     STRING,
  `event_ts_orig` DATETIME,
  `user_id`      STRING,
  `app_version`  STRING,
  `device_type`  STRING,
  `platform`     STRING,
  `properties`   JSON,
  `context`      STRUCT<`ip` STRING, `country` STRING, `session_id` STRING, `referrer` STRING>,
  `items`        ARRAY<STRUCT<`sku` STRING, `qty` INT64, `price` NUMERIC>>,
  `hour_bucket`  INT64,
  `event_ts`     TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`event_ts`, HOUR)
CLUSTER BY `hour_bucket`;
