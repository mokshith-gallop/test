-- BigQuery DDL: regional_eu.staging_customers_eu_cdc
-- Source: Hive regional.staging_customers_eu_cdc (acme-edge/hive/regional-additional-tables.hql)
-- Partition: DATE snapshot_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.staging_customers_eu_cdc`
(
    customer_id     STRING,
    email           STRING,
    first_name      STRING,
    last_name       STRING,
    country_iso2    STRING,
    addr_postal     STRING,
    consent_marketing BOOL,
    updated_ts      TIMESTAMP,
    op              STRING,
    snapshot_date   DATE
)
PARTITION BY snapshot_date;
