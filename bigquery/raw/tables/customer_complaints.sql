-- Source: raw.customer_complaints
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: TEXTFILE (TSV) -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.customer_complaints`
(
  `complaint_id` STRING,
  `customer_id`  STRING,
  `invoice_no`   STRING,
  `channel`      STRING,
  `severity`     STRING,
  `summary`      STRING,
  `body`         STRING,
  `created_at`   DATETIME,
  `resolved_at`  DATETIME,
  `csat_score`   INT64,
  `ingest_ts`    TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
