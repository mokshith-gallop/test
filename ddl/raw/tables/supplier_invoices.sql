-- BigQuery DDL: raw.supplier_invoices
-- Source: Hive raw.supplier_invoices (acme-lake/hive/05-additional-raw-feeds.hql)
-- ARRAY<STRUCT<...>> with type widening applied
-- Partition: multi-col (feed_year INT, feed_month INT) → generated partition_month DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.supplier_invoices`
(
    invoice_no    STRING,
    supplier_id   STRING,
    invoice_date  DATE,
    due_date      DATE,
    total_amount  NUMERIC(14,2),
    currency      STRING,
    line_items    ARRAY<STRUCT<sku STRING, qty INT64, unit_price NUMERIC(10,2)>>,
    raw_xml       STRING,
    feed_year     INT64,
    feed_month    INT64,
    partition_month DATE
)
PARTITION BY partition_month;
