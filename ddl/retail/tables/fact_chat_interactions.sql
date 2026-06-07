-- BigQuery DDL: retail.fact_chat_interactions
-- Source: Hive retail.fact_chat_interactions (acme-analytics/hive/11-additional-facts.hql)
-- Partition: DATE start_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_chat_interactions`
(
    chat_id          STRING,
    customer_sk      INT64,
    agent_sk         INT64,
    started_at       TIMESTAMP,
    ended_at         TIMESTAMP,
    duration_sec     INT64,
    message_count    INT64,
    resolved         BOOL,
    csat_score       INT64,
    sentiment_avg    NUMERIC(4,3),
    start_date       DATE
)
PARTITION BY start_date;
