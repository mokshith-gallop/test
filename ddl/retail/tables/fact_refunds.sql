-- BigQuery DDL: retail.fact_refunds
-- Source: Hive retail.fact_refunds (acme-analytics/hive/11-additional-facts.hql)
-- Partition: DATE refund_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_refunds`
(
    refund_id       INT64,
    payment_id      INT64,
    return_id       INT64,
    customer_sk     INT64,
    amount          NUMERIC(14,2),
    currency_code   STRING,
    refund_ts       TIMESTAMP,
    refund_method   STRING,
    refund_date     DATE
)
PARTITION BY refund_date;
