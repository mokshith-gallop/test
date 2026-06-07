-- BigQuery DDL: regional_eu.fact_returns_eu
-- Source: Hive regional.fact_returns_eu (acme-edge/hive/regional-additional-tables.hql)
-- Partition: DATE return_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.fact_returns_eu`
(
    return_id       INT64,
    order_id        STRING,
    customer_id     STRING,
    sku             STRING,
    return_ts       TIMESTAMP,
    refund_amount   NUMERIC(12,2),
    reason_code     STRING,
    country_iso2    STRING,
    return_date     DATE
)
PARTITION BY return_date;
