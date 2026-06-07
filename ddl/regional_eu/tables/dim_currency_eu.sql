-- BigQuery DDL: regional_eu.dim_currency_eu
-- Source: Hive regional.dim_currency_eu (acme-edge/hive/regional-additional-tables.hql)
-- No partition (small dimension table)
-- EU location: ${PROJECT_EU}.${DATASET_REGIONAL}

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.dim_currency_eu`
(
    currency_code   STRING,
    currency_name   STRING,
    minor_unit      INT64,
    symbol          STRING,
    eurozone        BOOL
);
