-- BigQuery DDL: staging.geocoded_addresses
-- Source: Hive staging.geocoded_addresses (acme-lake/hive/06-staging-tables.hql)
-- Partition: DATE load_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.geocoded_addresses`
(
    raw_addr_hash  STRING,
    addr_line1     STRING,
    addr_city      STRING,
    addr_region    STRING,
    addr_country   STRING,
    addr_postal    STRING,
    lat            FLOAT64,
    lon            FLOAT64,
    confidence     NUMERIC(4,3),
    provider       STRING,
    load_date      DATE
)
PARTITION BY load_date;
