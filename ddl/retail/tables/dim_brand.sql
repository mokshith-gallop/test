-- BigQuery DDL: retail.dim_brand
-- Source: Hive retail.dim_brand (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_brand`
(
    brand_sk        INT64,
    brand_id        STRING,
    brand_name      STRING,
    parent_company  STRING,
    private_label   BOOL,
    launch_dt       DATE
);
