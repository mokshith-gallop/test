-- BigQuery DDL: retail.dim_customer
-- Source: Hive retail.dim_customer (acme-analytics/hive/03-retail-tables.hql)
-- No partition (small dimension table)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_customer`
(
    customer_sk    INT64,
    customer_id    STRING,
    country        STRING,
    first_seen_ts  TIMESTAMP,
    last_seen_ts   TIMESTAMP
);
