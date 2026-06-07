-- BigQuery DDL: raw.loyalty_events
-- Source: Hive raw.loyalty_events (acme-lake/hive/05-additional-raw-feeds.hql)
-- RegexSerDe feed; meta_raw is STRING in source (not MAP), stays STRING.
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.loyalty_events`
(
    event_ts_str   STRING,
    member_id      STRING,
    event_type     STRING,
    points         STRING,
    store_id       STRING,
    tx_id          STRING,
    meta_raw       STRING,
    date_ts        STRING,
    partition_date DATE
)
PARTITION BY partition_date;
