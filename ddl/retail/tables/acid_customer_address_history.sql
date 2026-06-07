-- BigQuery DDL: retail.acid_customer_address_history
-- Source: Hive retail.acid_customer_address_history (acme-analytics/hive/13-additional-acid-tables.hql)
-- AC-14: ACID ORC table → standard BigQuery managed table, no ORC properties
-- Clustering: CLUSTERED BY (customer_sk) INTO 8 BUCKETS → CLUSTER BY customer_sk

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.acid_customer_address_history`
(
    history_id      INT64,
    customer_sk     INT64,
    address_line1   STRING,
    address_city    STRING,
    address_region  STRING,
    address_country STRING,
    address_postal  STRING,
    eff_from        TIMESTAMP,
    eff_to          TIMESTAMP,
    is_current      BOOL,
    change_reason   STRING
)
CLUSTER BY customer_sk;
