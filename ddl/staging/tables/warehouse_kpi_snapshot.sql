-- BigQuery DDL: staging.warehouse_kpi_snapshot
-- Source: Hive staging.warehouse_kpi_snapshot (acme-lake/hive/06-staging-tables.hql)
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.warehouse_kpi_snapshot`
(
    warehouse_id   STRING,
    snapshot_ts    TIMESTAMP,
    units_in       INT64,
    units_picked   INT64,
    units_shipped  INT64,
    pick_rate_uph  NUMERIC(8,2),
    backlog_units  INT64,
    avg_pick_ms    INT64,
    date_ts        STRING,
    partition_date DATE
)
PARTITION BY partition_date;
