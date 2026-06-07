-- BigQuery DDL: retail.dim_employee
-- Source: Hive retail.dim_employee (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_employee`
(
    employee_sk     INT64,
    employee_id     STRING,
    first_name      STRING,
    last_name       STRING,
    hire_dt         DATE,
    termination_dt  DATE,
    role            STRING,
    department      STRING,
    home_store_sk   INT64,
    manager_sk      INT64,
    salary_band     STRING
);
