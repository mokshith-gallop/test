-- Source: staging.cleansed_customers
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: load_date DATE (native, no change — Pattern C)
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.staging.cleansed_customers`
(
  `customer_id`  STRING,
  `email_norm`   STRING,
  `phone_norm`   STRING,
  `first_name`   STRING,
  `last_name`    STRING,
  `addr_line1`   STRING,
  `addr_city`    STRING,
  `addr_region`  STRING,
  `addr_country` STRING,
  `addr_postal`  STRING,
  `geocoded_lat` FLOAT64,
  `geocoded_lon` FLOAT64,
  `eff_from_ts`  DATETIME,
  `record_hash`  STRING,
  `load_date`    DATE
)
PARTITION BY `load_date`;
