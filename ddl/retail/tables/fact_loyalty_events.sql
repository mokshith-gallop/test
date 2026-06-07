-- BigQuery DDL: retail.fact_loyalty_events
-- Source: Hive retail.fact_loyalty_events (acme-analytics/hive/11-additional-facts.hql)
-- MAP<STRING,STRING> meta → JSON (AC-13)
-- Partition: DATE event_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_loyalty_events`
(
    event_id        INT64,
    member_id       STRING,
    event_type      STRING,
    points          INT64,
    store_sk        INT64,
    tx_id           STRING,
    event_ts        TIMESTAMP,
    meta            JSON,
    event_date      DATE
)
PARTITION BY event_date;
