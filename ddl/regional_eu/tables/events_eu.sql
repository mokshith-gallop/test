-- BigQuery DDL: regional_eu.events_eu
-- Source: Hive regional.events_eu (acme-edge/hive/regional-events.hql)
-- AC-13 note: payload_json is STRING in source (not MAP), stays STRING
-- Partition: STRING event_date → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.events_eu`
(
    event_id     STRING,
    event_ts     TIMESTAMP,
    user_id      STRING,
    event_type   STRING,
    country_iso2 STRING,
    payload_json STRING,
    event_date   STRING,
    partition_date DATE
)
PARTITION BY partition_date;
