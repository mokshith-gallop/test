-- BigQuery DDL: retail.agg_weekly_customer_ltv
-- Source: Hive retail.agg_weekly_customer_ltv (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: DATE week_start_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_weekly_customer_ltv`
(
    customer_sk         INT64,
    ltv_to_date         NUMERIC(16,2),
    orders_to_date      INT64,
    avg_order_value     NUMERIC(12,2),
    days_since_last_order INT64,
    rfm_score           STRING,
    churn_risk          NUMERIC(4,3),
    week_start_date     DATE
)
PARTITION BY week_start_date;
