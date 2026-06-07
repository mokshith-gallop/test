-- BigQuery DDL: retail.fact_payments
-- Source: Hive retail.fact_payments (acme-analytics/hive/11-additional-facts.hql)
-- AC-9: partition by DATE(post_year, post_month, 1), cluster by payment_method_partition
-- Multi-col partition (post_year/post_month/payment_method_partition) → generated partition_month DATE
-- Clustering: CLUSTERED BY (invoice_no) INTO 16 BUCKETS → CLUSTER BY payment_method_partition (per AC-9)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_payments`
(
    payment_id      INT64,
    invoice_no      STRING,
    customer_sk     INT64,
    payment_method_sk INT64,
    amount          NUMERIC(14,2),
    currency_code   STRING,
    payment_ts      TIMESTAMP,
    auth_code       STRING,
    settlement_id   STRING,
    fee_amount      NUMERIC(10,2),
    post_year       INT64,
    post_month      INT64,
    payment_method_partition STRING,
    partition_month DATE
)
PARTITION BY partition_month
CLUSTER BY payment_method_partition;
