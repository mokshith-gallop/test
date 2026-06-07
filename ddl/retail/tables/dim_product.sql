-- BigQuery DDL: retail.dim_product
-- Source: Hive retail.dim_product (acme-analytics/hive/03-retail-tables.hql)
-- No partition (small dimension table)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_product`
(
    product_sk     INT64,
    stock_code     STRING,
    description    STRING,
    unit_price     NUMERIC(10,2)
);
