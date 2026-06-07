-- BigQuery DDL: regional_eu.dim_customer_snapshot
-- Source: Hive regional.dim_customer_snapshot (acme-edge/hive/regional-events.hql)
-- No partition (small Sqoop landing table)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.dim_customer_snapshot`
(
    customer_sk    INT64,
    customer_id    STRING,
    country        STRING,
    snapshot_date  DATE
);
