-- Source: raw.loyalty_events
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: RegexSerDe TEXTFILE -> BigQuery native (managed) via Parquet transit
-- Note: Parquet transit load required — source uses RegexSerDe

CREATE OR REPLACE TABLE `acme-lake-project.raw.loyalty_events`
(
  `event_ts_str` STRING,
  `member_id`    STRING,
  `event_type`   STRING,
  `points`       STRING,
  `store_id`     STRING,
  `tx_id`        STRING,
  `meta_raw`     STRING,
  `ingest_ts`    TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR)
OPTIONS (
  description = 'Parquet transit load required - source is RegexSerDe'
);
