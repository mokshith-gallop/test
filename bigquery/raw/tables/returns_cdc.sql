-- Source: raw.returns_cdc
-- Origin: clusters/acme-lake/hive/02-raw-external-tables.hql
-- Partition: snapshot_date DATE (native, no change — Pattern C)
-- Storage: TEXTFILE (CSV) -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.returns_cdc`
(
  `return_id`     INT64,
  `invoice_no`    STRING,
  `customer_sk`   INT64,
  `return_ts`     DATETIME,
  `refund_amount` NUMERIC,
  `reason_code`   STRING,
  `status`        STRING,
  `op`            STRING,
  `snapshot_date` DATE
)
PARTITION BY `snapshot_date`;
