-- BigQuery DDL: regional_eu.fact_mobile_app_events
-- Source: Hive regional.fact_mobile_app_events (acme-edge/hive/regional-additional-tables.hql)
-- MAP<STRING,STRING> properties → JSON (AC-13)
-- STRUCT<platform:STRING, model:STRING, os_version:STRING> preserved
-- Partition: STRING event_date + STRING platform_partition → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.fact_mobile_app_events`
(
    event_id        STRING,
    session_id      STRING,
    user_id         STRING,
    event_type      STRING,
    event_ts        TIMESTAMP,
    screen          STRING,
    device          STRUCT<platform STRING, model STRING, os_version STRING>,
    properties      JSON,
    country_iso2    STRING,
    event_date      STRING,
    platform_partition STRING,
    partition_date  DATE
)
PARTITION BY partition_date;
