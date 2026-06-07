-- BigQuery DDL: retail.inventory_realtime_snapshot
-- Source: Hive retail.kudu_inventory_realtime (acme-analytics/hive/14-kudu-realtime.hql)
-- Category: kudu_snapshot (Kudu PRIMARY KEY/HASH → standard BigQuery table)
-- Kudu BIGINT timestamps → INT64 (epoch millis)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.inventory_realtime_snapshot`
(
    warehouse_id    STRING,
    sku             STRING,
    on_hand         INT64,
    allocated       INT64,
    available       INT64,
    last_updated_ts INT64
);
