-- BigQuery DDL: staging.cleansed_customers
-- Source: Hive staging.cleansed_customers (acme-lake/hive/06-staging-tables.hql)
-- Partition: DATE load_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.cleansed_customers`
(
    customer_id     STRING,
    email_norm      STRING,
    phone_norm      STRING,
    first_name      STRING,
    last_name       STRING,
    addr_line1      STRING,
    addr_city       STRING,
    addr_region     STRING,
    addr_country    STRING,
    addr_postal     STRING,
    geocoded_lat    FLOAT64,
    geocoded_lon    FLOAT64,
    eff_from_ts     TIMESTAMP,
    record_hash     STRING,
    load_date       DATE
)
PARTITION BY load_date;
