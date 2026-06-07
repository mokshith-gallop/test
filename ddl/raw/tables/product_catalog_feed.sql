-- BigQuery DDL: raw.product_catalog_feed
-- Source: Hive raw.product_catalog_feed (acme-lake/hive/05-additional-raw-feeds.hql)
-- MAP<STRING,STRING> metadata → JSON
-- Partition: STRING feed_date → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.product_catalog_feed`
(
    sku            STRING,
    supplier_id    STRING,
    upc            STRING,
    name           STRING,
    category       STRING,
    subcategory    STRING,
    color          STRING,
    size           STRING,
    msrp           NUMERIC(10,2),
    cost           NUMERIC(10,2),
    available_from DATE,
    discontinued_at DATE,
    metadata       JSON,
    feed_date      STRING,
    partition_date DATE
)
PARTITION BY partition_date;
