-- BigQuery DDL: regional_eu.fact_orders_eu
-- Source: Hive regional.fact_orders_eu (acme-edge/hive/regional-additional-tables.hql)
-- AC-11: partition by DATE(order_year, order_month, 1), cluster by country_partition and customer_id,
--         vat_amount NUMERIC
-- Multi-col partition (order_year/order_month/country_partition) → generated partition_month DATE
-- Clustering: CLUSTERED BY (customer_id) INTO 16 BUCKETS → CLUSTER BY country_partition, customer_id

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.fact_orders_eu`
(
    order_id        STRING,
    customer_id     STRING,
    sku             STRING,
    quantity        INT64,
    unit_price      NUMERIC(10,2),
    line_total      NUMERIC(14,2),
    currency_code   STRING,
    vat_amount      NUMERIC(12,2),
    order_ts        TIMESTAMP,
    country_iso2    STRING,
    order_year      INT64,
    order_month     INT64,
    country_partition STRING,
    partition_month DATE
)
PARTITION BY partition_month
CLUSTER BY country_partition, customer_id;
