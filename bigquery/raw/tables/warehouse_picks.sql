-- Source: raw.warehouse_picks
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: (date_ts STRING, warehouse_id_partition STRING) -> ingest_ts TIMESTAMP (HOUR granularity) — Pattern B
-- Cluster: warehouse_id_partition retained as data column + CLUSTER BY
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.warehouse_picks`
(
  `pick_id`                INT64,
  `warehouse_id`           STRING,
  `bin_id`                 STRING,
  `sku`                    STRING,
  `picker_id`              STRING,
  `quantity`               INT64,
  `picked_at`              DATETIME,
  `duration_ms`            INT64,
  `warehouse_id_partition` STRING,
  `ingest_ts`              TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR)
CLUSTER BY `warehouse_id_partition`;
