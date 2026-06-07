-- BigQuery DDL: raw.driver_logs
-- Source: Hive raw.driver_logs (acme-lake/hive/05-additional-raw-feeds.hql)
-- STRUCT<lat:DOUBLE, lon:DOUBLE> → STRUCT<lat FLOAT64, lon FLOAT64>
-- MAP<STRING,STRING> extras → JSON
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.driver_logs`
(
    driver_id    STRING,
    event_ts     TIMESTAMP,
    event_type   STRING,
    gps          STRUCT<lat FLOAT64, lon FLOAT64>,
    notes        STRING,
    extras       JSON,
    date_ts      STRING,
    partition_date DATE
)
PARTITION BY partition_date;
