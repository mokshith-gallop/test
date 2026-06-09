-- Source: raw.supplier_invoices
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: (feed_year INT, feed_month INT) -> invoice_month DATE (MONTH granularity) — Pattern B
-- Storage: SEQUENCEFILE -> BigQuery native (managed) via Parquet transit
-- Type: ARRAY<STRUCT<sku:STRING, qty:INT, unit_price:DECIMAL(10,2)>> -> ARRAY<STRUCT<sku STRING, qty INT64, unit_price NUMERIC>>
-- Note: Parquet transit load required — source is SequenceFile

CREATE OR REPLACE TABLE `acme-lake-project.raw.supplier_invoices`
(
  `invoice_no`   STRING,
  `supplier_id`  STRING,
  `invoice_date` DATE,
  `due_date`     DATE,
  `total_amount` NUMERIC,
  `currency`     STRING,
  `line_items`   ARRAY<STRUCT<`sku` STRING, `qty` INT64, `unit_price` NUMERIC>>,
  `raw_xml`      STRING,
  `invoice_month` DATE
)
PARTITION BY DATE_TRUNC(`invoice_month`, MONTH)
OPTIONS (
  description = 'Parquet transit load required - source is SequenceFile'
);
