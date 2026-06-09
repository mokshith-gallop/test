-- Source: raw.pos_transactions
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.pos_transactions`
(
  `txn_id`          INT64,
  `store_id`        STRING,
  `register_id`     STRING,
  `cashier_id`      STRING,
  `customer_id`     STRING,
  `invoice_no`      STRING,
  `txn_ts`          DATETIME,
  `line_count`      INT64,
  `gross_amount`    NUMERIC,
  `discount_amount` NUMERIC,
  `tax_amount`      NUMERIC,
  `tender_type`     STRING,
  `void_flag`       BOOL,
  `ingest_ts`       TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
