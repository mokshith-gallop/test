-- BigQuery DDL: retail.agg_daily_sales_by_product
-- Source: Hive retail.agg_daily_sales_by_product (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: DATE sale_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_daily_sales_by_product`
(
    product_sk          INT64,
    units_sold          INT64,
    gross_revenue       NUMERIC(16,2),
    margin_pct          NUMERIC(6,4),
    cogs                NUMERIC(16,2),
    return_units        INT64,
    net_units           INT64,
    sale_date           DATE
)
PARTITION BY sale_date;
