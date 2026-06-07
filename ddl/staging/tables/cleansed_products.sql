-- BigQuery DDL: staging.cleansed_products
-- Source: Hive staging.cleansed_products (acme-lake/hive/06-staging-tables.hql)
-- Partition: DATE load_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_STAGING}.cleansed_products`
(
    sku            STRING,
    upc            STRING,
    name_norm      STRING,
    category_norm  STRING,
    subcategory    STRING,
    color_norm     STRING,
    size_norm      STRING,
    msrp           NUMERIC(10,2),
    cost           NUMERIC(10,2),
    supplier_id    STRING,
    available      BOOL,
    load_date      DATE
)
PARTITION BY load_date;
