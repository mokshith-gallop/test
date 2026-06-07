-- BigQuery DDL: raw.pos_transactions
-- Source: Hive raw.pos_transactions (acme-lake/hive/05-additional-raw-feeds.hql)
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.pos_transactions`
(
    txn_id          INT64,
    store_id        STRING,
    register_id     STRING,
    cashier_id      STRING,
    customer_id     STRING,
    invoice_no      STRING,
    txn_ts          TIMESTAMP,
    line_count      INT64,
    gross_amount    NUMERIC(14,2),
    discount_amount NUMERIC(14,2),
    tax_amount      NUMERIC(14,2),
    tender_type     STRING,
    void_flag       BOOL,
    date_ts         STRING,
    partition_date  DATE
)
PARTITION BY partition_date;
