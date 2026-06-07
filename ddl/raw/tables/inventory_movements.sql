-- BigQuery DDL: raw.inventory_movements
-- Source: Hive raw.inventory_movements (acme-lake/hive/05-additional-raw-feeds.hql)
-- Partition: multi-col (year INT, month INT, day INT) → generated partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.inventory_movements`
(
    movement_id    INT64,
    sku            STRING,
    warehouse_id   STRING,
    bin_location   STRING,
    movement_type  STRING,
    quantity       INT64,
    movement_ts    TIMESTAMP,
    reference_doc  STRING,
    operator_id    STRING,
    reason_code    STRING,
    year           INT64,
    month          INT64,
    day            INT64,
    partition_date DATE
)
PARTITION BY partition_date;
