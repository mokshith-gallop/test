-- Source: staging.parsed_loyalty_events
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity) — Pattern A
-- Storage: PARQUET -> BigQuery native (managed)
-- Type: MAP<STRING,STRING> meta -> JSON

CREATE OR REPLACE TABLE `acme-lake-project.staging.parsed_loyalty_events`
(
  `event_ts`   DATETIME,
  `member_id`  STRING,
  `event_type` STRING,
  `points`     INT64,
  `store_id`   STRING,
  `tx_id`      STRING,
  `meta`       JSON,
  `ingest_ts`  TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
