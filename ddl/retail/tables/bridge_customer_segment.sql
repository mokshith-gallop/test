-- BigQuery DDL: retail.bridge_customer_segment
-- Source: Hive retail.bridge_customer_segment (acme-analytics/hive/15-bridge-and-scd2.hql)
-- Partition: DATE snapshot_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.bridge_customer_segment`
(
    customer_sk     INT64,
    segment_id      STRING,
    segment_name    STRING,
    assigned_dt     DATE,
    expires_dt      DATE,
    confidence      NUMERIC(4,3),
    source          STRING,
    snapshot_date   DATE
)
PARTITION BY snapshot_date;
