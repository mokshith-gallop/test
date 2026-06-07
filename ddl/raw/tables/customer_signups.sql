-- BigQuery DDL: raw.customer_signups
-- Source: Hive raw.customer_signups (Avro schema: customer_signups-v3.avsc)
-- Category: avro_net_new (absent from live Hive metastore)
-- Partition: STRING signup_date → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.customer_signups`
(
    customer_id    STRING,
    email          STRING,
    phone          STRING,
    first_name     STRING,
    last_name      STRING,
    addr_line1     STRING,
    addr_city      STRING,
    addr_region    STRING,
    addr_country   STRING,
    addr_postal    STRING,
    signup_source  STRING,
    marketing_opt_in BOOL,
    signup_date    STRING,
    partition_date DATE
)
PARTITION BY partition_date;
