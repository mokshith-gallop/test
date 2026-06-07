-- BigQuery DDL: retail.fact_app_clicks
-- Source: Hive retail.fact_app_clicks (acme-analytics/hive/11-additional-facts.hql)
-- MAP<STRING,STRING> properties → JSON
-- STRUCT<platform:STRING, version:STRING, model:STRING> preserved
-- Partition: DATE event_date (direct; platform_partition dropped to regular column)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_app_clicks`
(
    session_id      STRING,
    user_sk         INT64,
    event_ts        TIMESTAMP,
    event_type      STRING,
    screen          STRING,
    target_id       STRING,
    properties      JSON,
    device          STRUCT<platform STRING, version STRING, model STRING>,
    event_date      DATE,
    platform_partition STRING
)
PARTITION BY event_date;
