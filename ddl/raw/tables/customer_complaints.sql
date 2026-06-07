-- BigQuery DDL: raw.customer_complaints
-- Source: Hive raw.customer_complaints (acme-lake/hive/05-additional-raw-feeds.hql)
-- AC-13 note: resolution_details column absent in source schema — AC exception documented
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.customer_complaints`
(
    complaint_id  STRING,
    customer_id   STRING,
    invoice_no    STRING,
    channel       STRING,
    severity      STRING,
    summary       STRING,
    body          STRING,
    created_at    TIMESTAMP,
    resolved_at   TIMESTAMP,
    csat_score    INT64,
    date_ts       STRING,
    partition_date DATE
)
PARTITION BY partition_date;
