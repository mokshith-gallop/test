-- BigQuery DDL: retail.dim_color
-- Source: Hive retail.dim_color (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_color`
(
    color_sk        INT64,
    color_code      STRING,
    color_name      STRING,
    color_family    STRING,
    hex_code        STRING
);
