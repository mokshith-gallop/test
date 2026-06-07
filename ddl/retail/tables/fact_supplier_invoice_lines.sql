-- BigQuery DDL: retail.fact_supplier_invoice_lines
-- Source: Hive retail.fact_supplier_invoice_lines (acme-analytics/hive/11-additional-facts.hql)
-- Multi-col partition (invoice_year/invoice_month) → generated partition_month DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_supplier_invoice_lines`
(
    invoice_line_id  INT64,
    invoice_no       STRING,
    supplier_sk      INT64,
    sku              STRING,
    quantity         INT64,
    unit_cost        NUMERIC(12,4),
    line_total       NUMERIC(14,2),
    currency_code    STRING,
    received_ts      TIMESTAMP,
    invoice_year     INT64,
    invoice_month    INT64,
    partition_month  DATE
)
PARTITION BY partition_month;
