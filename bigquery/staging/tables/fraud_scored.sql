-- Source: staging.fraud_scored
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: score_date DATE (native, no change — Pattern C)
-- Storage: PARQUET -> BigQuery native (managed)
-- Type: ARRAY<STRING> signals preserved as-is

CREATE OR REPLACE TABLE `acme-lake-project.staging.fraud_scored`
(
  `txn_id`       INT64,
  `customer_id`  STRING,
  `fraud_score`  NUMERIC,
  `risk_band`    STRING,
  `signals`      ARRAY<STRING>,
  `scored_at`    DATETIME,
  `score_date`   DATE
)
PARTITION BY `score_date`;
