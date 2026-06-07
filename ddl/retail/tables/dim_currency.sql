-- BigQuery DDL: retail.dim_currency
-- Source: Hive retail.dim_currency (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_currency`
(
    currency_code   STRING,
    currency_name   STRING,
    minor_unit      INT64,
    symbol          STRING
);
