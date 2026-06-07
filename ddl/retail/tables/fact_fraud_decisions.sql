-- BigQuery DDL: retail.fact_fraud_decisions
-- Source: Hive retail.fact_fraud_decisions (acme-analytics/hive/11-additional-facts.hql)
-- ARRAY<STRING> rule_signals preserved
-- Partition: DATE decision_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_fraud_decisions`
(
    txn_id          INT64,
    customer_sk     INT64,
    fraud_score     NUMERIC(5,4),
    decision        STRING,
    rule_signals    ARRAY<STRING>,
    decided_ts      TIMESTAMP,
    decision_date   DATE
)
PARTITION BY decision_date;
