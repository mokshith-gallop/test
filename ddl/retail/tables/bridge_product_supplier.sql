-- BigQuery DDL: retail.bridge_product_supplier
-- Source: Hive retail.bridge_product_supplier (acme-analytics/hive/15-bridge-and-scd2.hql)
-- No partition (M:N bridge table)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.bridge_product_supplier`
(
    product_sk         INT64,
    supplier_sk        INT64,
    primary_supplier   BOOL,
    supplier_sku       STRING,
    unit_cost          NUMERIC(12,4),
    lead_time_days     INT64,
    moq                INT64,
    valid_from         DATE,
    valid_to           DATE
);
