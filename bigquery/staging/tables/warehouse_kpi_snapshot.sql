-- Source: staging.warehouse_kpi_snapshot
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity) — Pattern A
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.staging.warehouse_kpi_snapshot`
(
  `warehouse_id`  STRING,
  `snapshot_ts`   DATETIME,
  `units_in`      INT64,
  `units_picked`  INT64,
  `units_shipped` INT64,
  `pick_rate_uph` NUMERIC,
  `backlog_units` INT64,
  `avg_pick_ms`   INT64,
  `ingest_ts`     TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
