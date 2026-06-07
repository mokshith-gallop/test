-- BigQuery DDL: retail.dim_payment_method
-- Source: Hive retail.dim_payment_method (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_payment_method`
(
    payment_method_sk INT64,
    method_code       STRING,
    method_name       STRING,
    category          STRING,
    fee_pct           NUMERIC(5,4),
    fee_flat          NUMERIC(8,2),
    settlement_days   INT64
);
