-- BigQuery DDL: retail.returns_ledger
-- Source: Hive retail.returns_ledger (acme-analytics/hive/06-acid-tables.hql)
-- AC-10: refund_amount NUMERIC, no ORC/bucketing properties (plain BigQuery table)
-- AC-14: ACID table → standard BigQuery managed table, DECIMAL→NUMERIC
-- Clustering: CLUSTERED BY (return_id) INTO 4 BUCKETS → CLUSTER BY return_id

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.returns_ledger`
(
    return_id       INT64,
    invoice_no      STRING,
    customer_sk     INT64,
    return_ts       TIMESTAMP,
    refund_amount   NUMERIC(12,2),
    reason_code     STRING,
    status          STRING
)
CLUSTER BY return_id;
