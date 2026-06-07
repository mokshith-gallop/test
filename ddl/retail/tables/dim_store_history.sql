-- BigQuery DDL: retail.dim_store_history
-- Source: Hive retail.dim_store_history (acme-analytics/hive/15-bridge-and-scd2.hql)
-- SCD-2 history dimension, no partition (small table)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_store_history`
(
    history_id      INT64,
    store_sk        INT64,
    store_type      STRING,
    manager_employee_sk INT64,
    sq_ft           INT64,
    eff_from        DATE,
    eff_to          DATE,
    is_current      BOOL,
    change_reason   STRING
);
