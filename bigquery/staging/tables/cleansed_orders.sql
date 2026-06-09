-- Source: staging.cleansed_orders
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: order_date DATE (native, no change — Pattern C)
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.staging.cleansed_orders`
(
  `order_id`     STRING,
  `customer_id`  STRING,
  `invoice_no`   STRING,
  `txn_ts`       DATETIME,
  `line_count`   INT64,
  `gross_amount` NUMERIC,
  `discount`     NUMERIC,
  `tax`          NUMERIC,
  `net_amount`   NUMERIC,
  `tender_type`  STRING,
  `source_feed`  STRING,
  `order_date`   DATE
)
PARTITION BY `order_date`;
