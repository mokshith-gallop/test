-- Source: raw.sales_retail
-- Origin: clusters/acme-lake/hive/02-raw-external-tables.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: TEXTFILE (CSV) -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.sales_retail`
(
  `invoice_no`   STRING,
  `stock_code`   STRING,
  `description`  STRING,
  `quantity`     INT64,
  `invoice_date` STRING,
  `unit_price`   NUMERIC,
  `customer_id`  STRING,
  `country`      STRING,
  `ingest_ts`    TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
