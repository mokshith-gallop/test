-- BigQuery DDL: staging.merged_returns_cdc
-- Source: Hive staging.merged_returns_cdc (acme-lake/hive/06-staging-tables.hql)
-- Partition: DATE snapshot_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.merged_returns_cdc`
(
    return_id      INT64,
    invoice_no     STRING,
    customer_sk    INT64,
    return_ts      TIMESTAMP,
    refund_amount  NUMERIC(12,2),
    reason_code    STRING,
    status         STRING,
    is_deleted     BOOL,
    snapshot_date  DATE
)
PARTITION BY snapshot_date;
