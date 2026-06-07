-- BigQuery DDL: retail.bridge_product_attribute
-- Source: Hive retail.bridge_product_attribute (acme-analytics/hive/15-bridge-and-scd2.hql)
-- No partition (M:N bridge table)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.bridge_product_attribute`
(
    product_sk     INT64,
    attribute_name STRING,
    attribute_value STRING,
    primary_value  BOOL,
    sort_order     INT64
);
