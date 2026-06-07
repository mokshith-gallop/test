-- BigQuery DDL: retail.fact_inventory_snapshot
-- Source: Hive retail.fact_inventory_snapshot (acme-analytics/hive/11-additional-facts.hql)
-- Partition: DATE snapshot_date (direct passthrough)
-- Clustering: CLUSTERED BY (sku) INTO 16 BUCKETS → CLUSTER BY sku

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_inventory_snapshot`
(
    sku            STRING,
    warehouse_sk   INT64,
    on_hand_units  INT64,
    allocated_units INT64,
    in_transit_units INT64,
    available_units INT64,
    avg_cost       NUMERIC(12,4),
    last_movement_ts TIMESTAMP,
    snapshot_date  DATE
)
PARTITION BY snapshot_date
CLUSTER BY sku;
