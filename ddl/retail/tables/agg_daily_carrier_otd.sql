-- BigQuery DDL: retail.agg_daily_carrier_otd
-- Source: Hive retail.agg_daily_carrier_otd (acme-analytics/hive/12-aggregates-rollups.hql)
-- Partition: DATE ship_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.agg_daily_carrier_otd`
(
    carrier             STRING,
    shipments_total     INT64,
    delivered_on_time   INT64,
    delivered_late      INT64,
    in_transit          INT64,
    otd_pct             NUMERIC(5,4),
    avg_transit_hours   NUMERIC(8,2),
    ship_date           DATE
)
PARTITION BY ship_date;
