-- BigQuery DDL: retail.dim_employee_history
-- Source: Hive retail.dim_employee_history (acme-analytics/hive/15-bridge-and-scd2.hql)
-- SCD-2 history dimension
-- Partition: INT eff_from_year → derived partition_year DATE (year-granularity)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_employee_history`
(
    history_id      INT64,
    employee_sk     INT64,
    role            STRING,
    department      STRING,
    home_store_sk   INT64,
    salary_band     STRING,
    eff_from        DATE,
    eff_to          DATE,
    is_current      BOOL,
    eff_from_year   INT64
);
