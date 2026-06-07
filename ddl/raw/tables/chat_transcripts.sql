-- BigQuery DDL: raw.chat_transcripts
-- Source: Hive raw.chat_transcripts (acme-lake/hive/05-additional-raw-feeds.hql)
-- AC-13 note: session_metadata column absent in source schema — AC exception documented
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.chat_transcripts`
(
    chat_id        STRING,
    customer_id    STRING,
    agent_id       STRING,
    started_at     TIMESTAMP,
    ended_at       TIMESTAMP,
    duration_sec   INT64,
    message_count  INT64,
    transcript     STRING,
    sentiment      NUMERIC(4,3),
    date_ts        STRING,
    partition_date DATE
)
PARTITION BY partition_date;
