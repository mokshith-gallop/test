-- Source: raw.return_authorizations
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: TEXTFILE (TSV) -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.return_authorizations`
(
  `rma_id`        STRING,
  `customer_id`   STRING,
  `invoice_no`    STRING,
  `stock_code`    STRING,
  `quantity`      INT64,
  `reason_code`   STRING,
  `reason_text`   STRING,
  `requested_at`  DATETIME,
  `approved`      BOOL,
  `refund_amount` NUMERIC,
  `ingest_ts`     TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
