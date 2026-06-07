-- BigQuery DDL: retail.agg_marketing_attribution_cube
-- Source: Hive retail.agg_marketing_attribution_cube (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: DATE period_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_marketing_attribution_cube`
(
    channel             STRING,
    campaign_sk         INT64,
    region              STRING,
    attributed_revenue  NUMERIC(16,2),
    attributed_units    INT64,
    cost                NUMERIC(14,2),
    roas                NUMERIC(8,4),
    grouping_id         INT64,
    period_date         DATE
)
PARTITION BY period_date;
