-- Source: staging.dedup_clickstream
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: (date_ts STRING, country_partition STRING) -> event_date DATE (DAY granularity) — Pattern B
-- Cluster: CLUSTERED BY (user_id) INTO 16 BUCKETS -> CLUSTER BY country_partition, user_id
-- Storage: PARQUET -> BigQuery native (managed)
-- Note: country_partition retained as data column + included in CLUSTER BY

CREATE OR REPLACE TABLE `acme-lake-project.staging.dedup_clickstream`
(
  `session_id`         STRING,
  `user_id`            STRING,
  `event_ts`           DATETIME,
  `page_url`           STRING,
  `referrer_url`       STRING,
  `ip`                 STRING,
  `country`            STRING,
  `bot_score`          NUMERIC,
  `device_type`        STRING,
  `country_partition`  STRING,
  `event_date`         DATE
)
PARTITION BY `event_date`
CLUSTER BY `country_partition`, `user_id`;
