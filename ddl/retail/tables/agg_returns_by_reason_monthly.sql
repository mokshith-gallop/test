-- BigQuery DDL: retail.agg_returns_by_reason_monthly
-- Source: Hive retail.agg_returns_by_reason_monthly (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: DATE month_start (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_returns_by_reason_monthly`
(
    reason_code         STRING,
    return_count        INT64,
    return_units        INT64,
    total_refunded      NUMERIC(16,2),
    avg_days_to_return  NUMERIC(8,2),
    month_start         DATE
)
PARTITION BY month_start;
