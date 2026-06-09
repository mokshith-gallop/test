-- Source: raw.fraud_signals
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: signal_date STRING -> hive-partitioned GCS path (auto-detected)
-- Storage: Avro (schema evolves quarterly) -> External Parquet over GCS
-- Note: Schema is auto-detected from Parquet footers after Avro-to-Parquet conversion.
--       Partition column signal_date is inferred from hive-partitioned GCS paths.

CREATE EXTERNAL TABLE `acme-lake-project.raw.fraud_signals`
WITH PARTITION COLUMNS
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://acme-lake-project-raw/fraud_signals/*'],
  hive_partition_uri_prefix = 'gs://acme-lake-project-raw/fraud_signals/',
  description = 'External table over GCS Parquet files converted from Avro. Schema auto-detected from Parquet footers.'
);
