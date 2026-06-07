-- BigQuery DDL: retail.bridge_promo_eligibility
-- Source: Hive retail.bridge_promo_eligibility (acme-analytics/hive/15-bridge-and-scd2.hql)
-- Partition: DATE load_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.bridge_promo_eligibility`
(
    customer_sk    INT64,
    promo_sk       INT64,
    eligible       BOOL,
    reason         STRING,
    valid_from     DATE,
    valid_to       DATE,
    load_date      DATE
)
PARTITION BY load_date;
