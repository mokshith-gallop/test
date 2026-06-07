-- BigQuery DDL: retail.fact_customer_complaints
-- Source: Hive retail.fact_customer_complaints (acme-analytics/hive/11-additional-facts.hql)
-- Partition: DATE created_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_customer_complaints`
(
    complaint_id    STRING,
    customer_sk     INT64,
    invoice_no      STRING,
    channel         STRING,
    severity        STRING,
    summary         STRING,
    created_at      TIMESTAMP,
    resolved_at     TIMESTAMP,
    csat_score      INT64,
    created_date    DATE
)
PARTITION BY created_date;
