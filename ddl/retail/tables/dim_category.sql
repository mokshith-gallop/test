-- BigQuery DDL: retail.dim_category
-- Source: Hive retail.dim_category (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new (self-referencing hierarchy)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_category`
(
    category_sk     INT64,
    category_id     STRING,
    parent_id       STRING,
    name            STRING,
    depth           INT64,
    sort_order      INT64
);
