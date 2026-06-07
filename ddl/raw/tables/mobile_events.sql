-- BigQuery DDL: raw.mobile_events
-- Source: Hive raw.mobile_events (acme-lake/hive/07-json-raw.hql)
-- AC-6: properties JSON, context STRUCT<ip_address STRING, ...>,
--        items ARRAY<STRUCT<...>>, PARTITION BY partition_date,
--        CLUSTER BY platform, hour_bucket
-- Type mappings: MAP→JSON, STRUCT ip→ip_address, INT→INT64, DECIMAL→NUMERIC, TINYINT→INT64

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.mobile_events`
(
    event_id        STRING,
    event_ts        TIMESTAMP,
    user_id         STRING,
    app_version     STRING,
    device_type     STRING,
    platform        STRING,
    properties      JSON,
    context         STRUCT<ip_address STRING, country STRING, session_id STRING, referrer STRING>,
    items           ARRAY<STRUCT<sku STRING, qty INT64, price NUMERIC(10,2)>>,
    event_date      STRING,
    hour_bucket     INT64,
    partition_date  DATE
)
PARTITION BY partition_date
CLUSTER BY platform, hour_bucket;
