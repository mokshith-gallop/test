-- BigQuery DDL: raw.sales_retail
-- Source: Hive raw.sales_retail (acme-lake/hive/02-raw-external-tables.hql)
-- Partition: STRING date_ts → derived partition_date DATE
-- AC-5: partition_date DATE, date_ts STRING retained, unit_price NUMERIC, require_partition_filter

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.sales_retail`
(
    invoice_no     STRING,
    stock_code     STRING,
    description    STRING,
    quantity       INT64,
    invoice_date   STRING,
    unit_price     NUMERIC(10,2),
    customer_id    STRING,
    country        STRING,
    date_ts        STRING,
    partition_date DATE
)
PARTITION BY partition_date
OPTIONS (
    require_partition_filter = TRUE
);
