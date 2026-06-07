-- BigQuery DDL: retail.agg_monthly_supplier_performance
-- Source: Hive retail.agg_monthly_supplier_performance (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: DATE month_start (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_monthly_supplier_performance`
(
    supplier_sk         INT64,
    orders_placed       INT64,
    units_received      INT64,
    on_time_pct         NUMERIC(5,4),
    fill_rate_pct       NUMERIC(5,4),
    avg_lead_time_days  NUMERIC(6,2),
    quality_score       NUMERIC(4,3),
    total_spend         NUMERIC(16,2),
    month_start         DATE
)
PARTITION BY month_start;
