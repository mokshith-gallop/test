-- Source: raw.inventory_movements
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: (year INT, month INT, day INT) -> movement_date DATE (DAY granularity) — Pattern B
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.inventory_movements`
(
  `movement_id`   INT64,
  `sku`           STRING,
  `warehouse_id`  STRING,
  `bin_location`  STRING,
  `movement_type` STRING,
  `quantity`      INT64,
  `movement_ts`   DATETIME,
  `reference_doc` STRING,
  `operator_id`   STRING,
  `reason_code`   STRING,
  `movement_date` DATE
)
PARTITION BY `movement_date`;
