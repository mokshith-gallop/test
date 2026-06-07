-- BigQuery DDL: staging.normalized_carrier_events
-- Source: Hive staging.normalized_carrier_events (acme-lake/hive/06-staging-tables.hql)
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.normalized_carrier_events`
(
    tracking_no    STRING,
    carrier        STRING,
    event_type     STRING,
    event_ts       TIMESTAMP,
    location_city  STRING,
    location_region STRING,
    location_country STRING,
    date_ts        STRING,
    partition_date DATE
)
PARTITION BY partition_date;
