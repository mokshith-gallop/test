-- BigQuery DDL: retail.agg_daily_sales_by_store
-- Source: Hive retail.agg_daily_sales_by_store (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: DATE sale_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_daily_sales_by_store`
(
    store_sk            INT64,
    gross_revenue       NUMERIC(16,2),
    net_revenue         NUMERIC(16,2),
    units_sold          INT64,
    txn_count           INT64,
    avg_basket          NUMERIC(12,2),
    sale_date           DATE
)
PARTITION BY sale_date;
