-- BigQuery DDL: retail.fact_returns
-- Source: Hive retail.fact_returns (acme-analytics/hive/11-additional-facts.hql)
-- Partition: DATE return_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_returns`
(
    return_id       INT64,
    invoice_no      STRING,
    customer_sk     INT64,
    product_sk      INT64,
    return_ts       TIMESTAMP,
    quantity        INT64,
    refund_amount   NUMERIC(12,2),
    reason_code     STRING,
    return_channel  STRING,
    store_sk        INT64,
    return_date     DATE
)
PARTITION BY return_date;
