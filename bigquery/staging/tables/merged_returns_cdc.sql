-- Source: staging.merged_returns_cdc
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: snapshot_date DATE (native, no change — Pattern C)
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.staging.merged_returns_cdc`
(
  `return_id`     INT64,
  `invoice_no`    STRING,
  `customer_sk`   INT64,
  `return_ts`     DATETIME,
  `refund_amount` NUMERIC,
  `reason_code`   STRING,
  `status`        STRING,
  `is_deleted`    BOOL,
  `snapshot_date` DATE
)
PARTITION BY `snapshot_date`;
