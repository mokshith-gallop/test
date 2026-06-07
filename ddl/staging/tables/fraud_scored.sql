-- BigQuery DDL: staging.fraud_scored
-- Source: Hive staging.fraud_scored (acme-lake/hive/06-staging-tables.hql)
-- Partition: DATE score_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.fraud_scored`
(
    txn_id         INT64,
    customer_id    STRING,
    fraud_score    NUMERIC(5,4),
    risk_band      STRING,
    signals        ARRAY<STRING>,
    scored_at      TIMESTAMP,
    score_date     DATE
)
PARTITION BY score_date;
