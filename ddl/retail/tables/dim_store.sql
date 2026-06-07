-- BigQuery DDL: retail.dim_store
-- Source: Hive retail.dim_store (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new (absent from live Hive metastore)
-- MAP<STRING,STRING> attributes → JSON

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_store`
(
    store_sk        INT64,
    store_id        STRING,
    store_name      STRING,
    store_type      STRING,
    region          STRING,
    city            STRING,
    state           STRING,
    country         STRING,
    open_dt         DATE,
    close_dt        DATE,
    sq_ft           INT64,
    manager_employee_sk INT64,
    attributes      JSON
);
