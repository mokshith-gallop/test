-- BigQuery DDL: staging.cleansed_orders
-- Source: Hive staging.cleansed_orders (acme-lake/hive/06-staging-tables.hql)
-- Partition: DATE order_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.cleansed_orders`
(
    order_id       STRING,
    customer_id    STRING,
    invoice_no     STRING,
    txn_ts         TIMESTAMP,
    line_count     INT64,
    gross_amount   NUMERIC(14,2),
    discount       NUMERIC(14,2),
    tax            NUMERIC(14,2),
    net_amount     NUMERIC(14,2),
    tender_type    STRING,
    source_feed    STRING,
    order_date     DATE
)
PARTITION BY order_date;
