-- BigQuery DDL: regional_eu.dim_locale_eu
-- Source: Hive regional.dim_locale_eu (acme-edge/hive/regional-additional-tables.hql)
-- No partition (small dimension table)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.dim_locale_eu`
(
    locale_code     STRING,
    country_iso2    STRING,
    language_iso2   STRING,
    timezone        STRING,
    currency_code   STRING,
    decimal_sep     STRING,
    date_format     STRING
);
