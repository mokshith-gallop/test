-- BigQuery DDL: raw.return_authorizations
-- Source: Hive raw.return_authorizations (acme-lake/hive/05-additional-raw-feeds.hql)
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.return_authorizations`
(
    rma_id          STRING,
    customer_id     STRING,
    invoice_no      STRING,
    stock_code      STRING,
    quantity        INT64,
    reason_code     STRING,
    reason_text     STRING,
    requested_at    TIMESTAMP,
    approved        BOOL,
    refund_amount   NUMERIC(12,2),
    date_ts         STRING,
    partition_date  DATE
)
PARTITION BY partition_date;
