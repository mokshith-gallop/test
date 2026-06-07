-- BigQuery DDL: retail.fact_inventory_movements
-- Source: Hive retail.fact_inventory_movements (acme-analytics/hive/11-additional-facts.hql)
-- AC-8: partition by DATE(year, month, day), cluster by region
-- Multi-col partition (year/month/day/region) → generated partition_date DATE
-- Clustering: CLUSTERED BY (sku) INTO 32 BUCKETS → CLUSTER BY region (per AC-8)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_inventory_movements`
(
    movement_id    INT64,
    movement_ts    TIMESTAMP,
    sku            STRING,
    warehouse_sk   INT64,
    store_sk       INT64,
    movement_type  STRING,
    quantity       INT64,
    reference_doc  STRING,
    reason_code    STRING,
    operator_sk    INT64,
    year           INT64,
    month          INT64,
    day            INT64,
    region         STRING,
    partition_date DATE
)
PARTITION BY partition_date
CLUSTER BY region;
