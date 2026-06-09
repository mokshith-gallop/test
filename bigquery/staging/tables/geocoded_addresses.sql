-- Source: staging.geocoded_addresses
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: load_date DATE (native, no change — Pattern C)
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.staging.geocoded_addresses`
(
  `raw_addr_hash` STRING,
  `addr_line1`    STRING,
  `addr_city`     STRING,
  `addr_region`   STRING,
  `addr_country`  STRING,
  `addr_postal`   STRING,
  `lat`           FLOAT64,
  `lon`           FLOAT64,
  `confidence`    NUMERIC,
  `provider`      STRING,
  `load_date`     DATE
)
PARTITION BY `load_date`;
