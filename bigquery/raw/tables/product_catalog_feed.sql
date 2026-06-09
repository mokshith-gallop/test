-- Source: raw.product_catalog_feed
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: feed_date STRING -> ingest_ts TIMESTAMP (HOUR granularity) — Pattern A
-- Storage: RCFILE -> BigQuery native (managed) via Parquet transit
-- Type: MAP<STRING,STRING> metadata -> JSON
-- Note: Parquet transit load required — source is RCFile

CREATE OR REPLACE TABLE `acme-lake-project.raw.product_catalog_feed`
(
  `sku`             STRING,
  `supplier_id`     STRING,
  `upc`             STRING,
  `name`            STRING,
  `category`        STRING,
  `subcategory`     STRING,
  `color`           STRING,
  `size`            STRING,
  `msrp`            NUMERIC,
  `cost`            NUMERIC,
  `available_from`  DATE,
  `discontinued_at` DATE,
  `metadata`        JSON,
  `ingest_ts`       TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR)
OPTIONS (
  description = 'Parquet transit load required - source is RCFile'
);
