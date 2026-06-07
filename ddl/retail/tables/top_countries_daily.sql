-- BigQuery DDL: retail.top_countries_daily
-- Source: Hive retail.top_countries_daily (acme-analytics/hive/08-rollup-etl.hql)
-- TINYINT rank → INT64
-- No partition (small rollup table)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.top_countries_daily`
(
    as_of_date   DATE,
    country      STRING,
    orders       INT64,
    revenue      NUMERIC(18,2),
    rank         INT64
);
