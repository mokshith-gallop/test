-- BigQuery DDL: raw.email_campaign_clicks
-- Source: Hive raw.email_campaign_clicks (acme-lake/hive/05-additional-raw-feeds.hql)
-- MAP<STRING,STRING> utm → JSON (AC-13: source column name is `utm`, not `utm_params`)
-- STRUCT geo preserved with direct mapping
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.email_campaign_clicks`
(
    campaign_id  STRING,
    send_id      STRING,
    recipient    STRING,
    clicked_at   TIMESTAMP,
    click_url    STRING,
    user_agent   STRING,
    ip_address   STRING,
    geo          STRUCT<country STRING, region STRING, city STRING>,
    utm          JSON,
    date_ts      STRING,
    partition_date DATE
)
PARTITION BY partition_date;
