-- BigQuery DDL: regional_eu.dim_product_eu_catalog
-- Source: Hive regional.dim_product_eu_catalog (acme-edge/hive/regional-additional-tables.hql)
-- ARRAY<STRING> eu_compliance_flags preserved
-- No partition (small dimension table)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.dim_product_eu_catalog`
(
    sku             STRING,
    eu_sku          STRING,
    name            STRING,
    description_de  STRING,
    description_fr  STRING,
    description_it  STRING,
    description_es  STRING,
    vat_pct         NUMERIC(5,4),
    eu_compliance_flags ARRAY<STRING>
);
