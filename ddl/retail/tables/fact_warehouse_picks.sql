-- BigQuery DDL: retail.fact_warehouse_picks
-- Source: Hive retail.fact_warehouse_picks (acme-analytics/hive/11-additional-facts.hql)
-- Partition: DATE pick_date (direct; warehouse_partition dropped to regular column)
-- Clustering: CLUSTERED BY (picker_sk) INTO 8 BUCKETS → CLUSTER BY picker_sk

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_warehouse_picks`
(
    pick_id          INT64,
    warehouse_sk     INT64,
    picker_sk        INT64,
    sku              STRING,
    quantity         INT64,
    picked_ts        TIMESTAMP,
    duration_ms      INT64,
    bin_location     STRING,
    pick_date        DATE,
    warehouse_partition STRING
)
PARTITION BY pick_date
CLUSTER BY picker_sk;
