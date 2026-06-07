-- BigQuery DDL: regional_eu.fact_eu_promotions
-- Source: Hive regional.fact_eu_promotions (acme-edge/hive/regional-additional-tables.hql)
-- Partition: DATE redemption_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.fact_eu_promotions`
(
    redemption_id   INT64,
    promo_code      STRING,
    customer_id     STRING,
    order_id        STRING,
    discount_amount NUMERIC(12,2),
    currency_code   STRING,
    redeemed_ts     TIMESTAMP,
    country_iso2    STRING,
    redemption_date DATE
)
PARTITION BY redemption_date;
