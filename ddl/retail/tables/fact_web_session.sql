-- BigQuery DDL: retail.fact_web_session
-- Source: Hive retail.fact_web_session (acme-analytics/hive/03-retail-tables.hql)
-- Partition: DATE event_date (direct passthrough; country partition dropped to regular column)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_web_session`
(
    event_ts       TIMESTAMP,
    ip             STRING,
    url            STRING,
    user_id        STRING,
    city           STRING,
    state          STRING,
    event_date     DATE,
    country        STRING
)
PARTITION BY event_date;
