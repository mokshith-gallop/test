-- BigQuery DDL: retail.dim_size
-- Source: Hive retail.dim_size (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_size`
(
    size_sk         INT64,
    size_code       STRING,
    size_name       STRING,
    size_system     STRING,
    sort_order      INT64
);
