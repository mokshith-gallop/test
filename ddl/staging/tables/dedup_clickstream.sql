-- BigQuery DDL: staging.dedup_clickstream
-- Source: Hive staging.dedup_clickstream (acme-lake/hive/06-staging-tables.hql)
-- Partition: STRING date_ts + STRING country_partition → derived partition_date DATE
-- Clustering: CLUSTERED BY (user_id) INTO 16 BUCKETS → CLUSTER BY user_id

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.dedup_clickstream`
(
    session_id     STRING,
    user_id        STRING,
    event_ts       TIMESTAMP,
    page_url       STRING,
    referrer_url   STRING,
    ip             STRING,
    country        STRING,
    bot_score      NUMERIC(4,3),
    device_type    STRING,
    date_ts        STRING,
    country_partition STRING,
    partition_date DATE
)
PARTITION BY partition_date
CLUSTER BY user_id;
