-- BigQuery DDL: retail.realtime_price_snapshot
-- Source: Hive retail.kudu_realtime_price (acme-analytics/hive/14-kudu-realtime.hql)
-- Category: kudu_snapshot (Kudu PRIMARY KEY/HASH → standard BigQuery table)
-- Kudu BIGINT timestamp → INT64 (epoch millis)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.realtime_price_snapshot`
(
    sku             STRING,
    store_id        STRING,
    price           NUMERIC(10,2),
    list_price      NUMERIC(10,2),
    cost            NUMERIC(10,2),
    margin_pct      NUMERIC(5,4),
    updated_ts      INT64,
    pricing_engine  STRING
);
