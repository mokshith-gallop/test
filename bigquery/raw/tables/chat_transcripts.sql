-- Source: raw.chat_transcripts
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: TEXTFILE (TSV) -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.chat_transcripts`
(
  `chat_id`       STRING,
  `customer_id`   STRING,
  `agent_id`      STRING,
  `started_at`    DATETIME,
  `ended_at`      DATETIME,
  `duration_sec`  INT64,
  `message_count` INT64,
  `transcript`    STRING,
  `sentiment`     NUMERIC,
  `ingest_ts`     TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
