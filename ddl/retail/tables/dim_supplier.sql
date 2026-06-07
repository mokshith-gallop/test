-- BigQuery DDL: retail.dim_supplier
-- Source: Hive retail.dim_supplier (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new
-- STRUCT<name:STRING, email:STRING, phone:STRING> preserved
-- ARRAY<STRING> categories preserved

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_supplier`
(
    supplier_sk      INT64,
    supplier_id      STRING,
    supplier_name    STRING,
    country          STRING,
    tax_id           STRING,
    payment_terms_days INT64,
    onboard_dt       DATE,
    risk_rating      STRING,
    primary_contact  STRUCT<name STRING, email STRING, phone STRING>,
    categories       ARRAY<STRING>
);
