-- Source: staging.cleansed_products
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- Partition: load_date DATE (native, no change — Pattern C)
-- Storage: PARQUET -> BigQuery native (managed)

CREATE OR REPLACE TABLE `acme-lake-project.staging.cleansed_products`
(
  `sku`           STRING,
  `upc`           STRING,
  `name_norm`     STRING,
  `category_norm` STRING,
  `subcategory`   STRING,
  `color_norm`    STRING,
  `size_norm`     STRING,
  `msrp`          NUMERIC,
  `cost`          NUMERIC,
  `supplier_id`   STRING,
  `available`     BOOL,
  `load_date`     DATE
)
PARTITION BY `load_date`;
