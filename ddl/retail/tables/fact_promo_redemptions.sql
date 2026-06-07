-- BigQuery DDL: retail.fact_promo_redemptions
-- Source: Hive retail.fact_promo_redemptions (acme-analytics/hive/11-additional-facts.hql)
-- Partition: DATE redemption_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_promo_redemptions`
(
    redemption_id   INT64,
    promo_sk        INT64,
    invoice_no      STRING,
    customer_sk     INT64,
    discount_amount NUMERIC(12,2),
    applied_ts      TIMESTAMP,
    channel         STRING,
    redemption_date DATE
)
PARTITION BY redemption_date;
