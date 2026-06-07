-- BigQuery DDL: raw.warehouse_picks
-- Source: Hive raw.warehouse_picks (acme-lake/hive/05-additional-raw-feeds.hql)
-- Partition: STRING date_ts + STRING warehouse_id_partition → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.warehouse_picks`
(
    pick_id        INT64,
    warehouse_id   STRING,
    bin_id         STRING,
    sku            STRING,
    picker_id      STRING,
    quantity       INT64,
    picked_at      TIMESTAMP,
    duration_ms    INT64,
    date_ts        STRING,
    warehouse_id_partition STRING,
    partition_date DATE
)
PARTITION BY partition_date;
