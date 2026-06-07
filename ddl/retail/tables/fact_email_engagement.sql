-- BigQuery DDL: retail.fact_email_engagement
-- Source: Hive retail.fact_email_engagement (acme-analytics/hive/11-additional-facts.hql)
-- ARRAY<STRUCT<ts:TIMESTAMP, url:STRING>> preserved
-- Partition: DATE event_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_email_engagement`
(
    send_id         STRING,
    campaign_sk     INT64,
    user_sk         INT64,
    event_type      STRING,
    event_ts        TIMESTAMP,
    link_url        STRING,
    clicks          ARRAY<STRUCT<ts TIMESTAMP, url STRING>>,
    event_date      DATE
)
PARTITION BY event_date;
