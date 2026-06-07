-- BigQuery DDL: retail.agg_hourly_warehouse_kpi
-- Source: Hive retail.agg_hourly_warehouse_kpi (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: STRING snapshot_hour → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_hourly_warehouse_kpi`
(
    warehouse_sk        INT64,
    units_in            INT64,
    units_picked        INT64,
    units_shipped       INT64,
    pick_rate_uph       NUMERIC(8,2),
    backlog_units       INT64,
    avg_pick_seconds    NUMERIC(8,2),
    snapshot_hour       STRING,
    partition_date      DATE
)
PARTITION BY partition_date;
