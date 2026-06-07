-- BigQuery DDL: retail.fact_shipments
-- Source: Hive retail.fact_shipments (acme-analytics/hive/11-additional-facts.hql)
-- ARRAY<STRUCT<ts:TIMESTAMP, status:STRING, location:STRING>> preserved
-- Multi-col partition (ship_year/ship_month/ship_day/carrier_partition) → generated partition_date DATE
-- Clustering: CLUSTERED BY (warehouse_sk) INTO 16 BUCKETS → CLUSTER BY warehouse_sk

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_shipments`
(
    shipment_id     STRING,
    invoice_no      STRING,
    customer_sk     INT64,
    warehouse_sk    INT64,
    carrier         STRING,
    tracking_no     STRING,
    shipped_ts      TIMESTAMP,
    delivered_ts    TIMESTAMP,
    sla_hours       INT64,
    tracking_events ARRAY<STRUCT<ts TIMESTAMP, status STRING, location STRING>>,
    ship_year       INT64,
    ship_month      INT64,
    ship_day        INT64,
    carrier_partition STRING,
    partition_date  DATE
)
PARTITION BY partition_date
CLUSTER BY warehouse_sk;
