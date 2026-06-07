-- BigQuery DDL: retail.acid_loyalty_points_ledger
-- Source: Hive retail.acid_loyalty_points_ledger (acme-analytics/hive/13-additional-acid-tables.hql)
-- AC-14: ACID ORC table → standard BigQuery managed table
-- Clustering: CLUSTERED BY (member_id) INTO 8 BUCKETS → CLUSTER BY member_id

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.acid_loyalty_points_ledger`
(
    entry_id        INT64,
    member_id       STRING,
    points_delta    INT64,
    running_balance INT64,
    event_ts        TIMESTAMP,
    event_type      STRING,
    reference_id    STRING,
    expiry_ts       TIMESTAMP
)
CLUSTER BY member_id;
