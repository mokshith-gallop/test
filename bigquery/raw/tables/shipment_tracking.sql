-- Source: raw.shipment_tracking
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: (date_ts STRING, carrier_partition STRING) -> ingest_ts TIMESTAMP (HOUR granularity) — Pattern B
-- Cluster: carrier_partition retained as data column + CLUSTER BY
-- Storage: TEXTFILE (CSV) -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.raw.shipment_tracking`
(
  `tracking_no`       STRING,
  `carrier`           STRING,
  `invoice_no`        STRING,
  `customer_id`       STRING,
  `shipped_at`        DATETIME,
  `delivered_at`      DATETIME,
  `status`            STRING,
  `last_location`     STRING,
  `estimated_eta`     DATETIME,
  `carrier_partition` STRING,
  `ingest_ts`         TIMESTAMP
)
PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR)
CLUSTER BY `carrier_partition`;
