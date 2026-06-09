-- Source: raw.email_campaign_clicks
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: JsonSerDe TEXTFILE -> BigQuery native (managed)
-- Types: MAP<STRING,STRING> utm -> JSON; STRUCT geo preserved

CREATE OR REPLACE TABLE `acme-lake-project.raw.email_campaign_clicks`
(
  `campaign_id` STRING,
  `send_id`     STRING,
  `recipient`   STRING,
  `clicked_at`  DATETIME,
  `click_url`   STRING,
  `user_agent`  STRING,
  `ip_address`  STRING,
  `geo`         STRUCT<`country` STRING, `region` STRING, `city` STRING>,
  `utm`         JSON,
  `ingest_ts`   TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR);
