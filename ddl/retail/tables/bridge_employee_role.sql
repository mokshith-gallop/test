-- BigQuery DDL: retail.bridge_employee_role
-- Source: Hive retail.bridge_employee_role (acme-analytics/hive/15-bridge-and-scd2.hql)
-- No partition (M:N bridge table)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.bridge_employee_role`
(
    employee_sk     INT64,
    role            STRING,
    primary_role    BOOL,
    eff_from        DATE,
    eff_to          DATE
);
