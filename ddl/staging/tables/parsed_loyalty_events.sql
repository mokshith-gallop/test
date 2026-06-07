-- BigQuery DDL: staging.parsed_loyalty_events
-- Source: Hive staging.parsed_loyalty_events (acme-lake/hive/06-staging-tables.hql)
-- MAP<STRING,STRING> meta → JSON (AC-13)
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.parsed_loyalty_events`
(
    event_ts       TIMESTAMP,
    member_id      STRING,
    event_type     STRING,
    points         INT64,
    store_id       STRING,
    tx_id          STRING,
    meta           JSON,
    date_ts        STRING,
    partition_date DATE
)
PARTITION BY partition_date;
