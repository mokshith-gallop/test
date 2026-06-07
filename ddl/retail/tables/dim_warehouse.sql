-- BigQuery DDL: retail.dim_warehouse
-- Source: Hive retail.dim_warehouse (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new
-- STRUCT<lat:DOUBLE, lon:DOUBLE> → STRUCT<lat FLOAT64, lon FLOAT64>

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_warehouse`
(
    warehouse_sk    INT64,
    warehouse_id    STRING,
    name            STRING,
    type            STRING,
    operator        STRING,
    region          STRING,
    capacity_units  INT64,
    open_dt         DATE,
    geocode         STRUCT<lat FLOAT64, lon FLOAT64>
);
