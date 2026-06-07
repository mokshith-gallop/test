-- BigQuery DDL: retail.acid_inventory_adjustments_log
-- Source: Hive retail.acid_inventory_adjustments_log (acme-analytics/hive/13-additional-acid-tables.hql)
-- AC-14: ACID ORC table → standard BigQuery managed table
-- Clustering: CLUSTERED BY (adjustment_id) INTO 4 BUCKETS → CLUSTER BY adjustment_id

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.acid_inventory_adjustments_log`
(
    adjustment_id   INT64,
    warehouse_sk    INT64,
    sku             STRING,
    quantity_delta  INT64,
    reason_code     STRING,
    notes           STRING,
    adjusted_by     STRING,
    adjusted_at     TIMESTAMP,
    approved_by     STRING,
    approved_at     TIMESTAMP
)
CLUSTER BY adjustment_id;
