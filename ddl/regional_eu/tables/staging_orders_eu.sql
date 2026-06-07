-- BigQuery DDL: regional_eu.staging_orders_eu
-- Source: Hive regional.staging_orders_eu (acme-edge/hive/regional-additional-tables.hql)
-- Partition: DATE snapshot_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.staging_orders_eu`
(
    order_id        STRING,
    customer_id     STRING,
    sku             STRING,
    quantity        INT64,
    unit_price      NUMERIC(10,2),
    currency_code   STRING,
    order_ts        TIMESTAMP,
    op              STRING,
    snapshot_date   DATE
)
PARTITION BY snapshot_date;
