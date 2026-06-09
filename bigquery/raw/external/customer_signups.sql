-- Source: raw.customer_signups
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- Partition: signup_date STRING -> hive-partitioned GCS path (auto-detected)
-- Storage: Avro (schema-evolved) -> External Parquet over GCS
-- Note: Schema is auto-detected from Parquet footers after Avro-to-Parquet conversion.
--       Partition column signup_date is inferred from hive-partitioned GCS paths.

CREATE EXTERNAL TABLE `acme-lake-project.raw.customer_signups`
WITH PARTITION COLUMNS
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://acme-lake-project-raw/customer_signups/*'],
  hive_partition_uri_prefix = 'gs://acme-lake-project-raw/customer_signups/',
  description = 'External table over GCS Parquet files converted from Avro. Schema auto-detected from Parquet footers.'
);
