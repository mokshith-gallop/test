-- BigQuery DDL: retail.session_state_snapshot
-- Source: Hive retail.kudu_session_state (acme-analytics/hive/14-kudu-realtime.hql)
-- Category: kudu_snapshot (Kudu PRIMARY KEY/HASH → standard BigQuery table)
-- Kudu BIGINT timestamps → INT64 (epoch millis)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.session_state_snapshot`
(
    session_id      STRING,
    user_id         STRING,
    started_ts      INT64,
    last_event_ts   INT64,
    cart_value      NUMERIC(12,2),
    cart_items      INT64,
    current_screen  STRING,
    platform        STRING,
    geo_country     STRING
);
