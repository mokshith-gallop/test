-- BigQuery DDL: raw.shipment_tracking
-- Source: Hive raw.shipment_tracking (acme-lake/hive/05-additional-raw-feeds.hql)
-- Partition: STRING date_ts + STRING carrier_partition → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.shipment_tracking`
(
    tracking_no   STRING,
    carrier       STRING,
    invoice_no    STRING,
    customer_id   STRING,
    shipped_at    TIMESTAMP,
    delivered_at  TIMESTAMP,
    status        STRING,
    last_location STRING,
    estimated_eta TIMESTAMP,
    date_ts       STRING,
    carrier_partition STRING,
    partition_date DATE
)
PARTITION BY partition_date;
