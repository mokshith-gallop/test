-- BigQuery DDL: retail.sales_cube
-- Source: Hive retail.sales_cube (acme-analytics/hive/08-rollup-etl.hql)
-- TINYINT dim_level → INT64, SMALLINT month_key → INT64
-- Partition: DATE as_of_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.sales_cube`
(
    dim_level       INT64,
    cube_key        STRING,
    country         STRING,
    month_key       INT64,
    product_sk      INT64,
    orders          INT64,
    revenue         NUMERIC(18,2),
    units           INT64,
    as_of_date      DATE
)
PARTITION BY as_of_date;
