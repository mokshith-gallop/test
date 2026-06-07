-- BigQuery DDL: retail.dim_geography
-- Source: Hive retail.dim_geography (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_geography`
(
    geo_sk           INT64,
    country_iso2     STRING,
    country_name     STRING,
    region_code      STRING,
    region_name      STRING,
    city             STRING,
    postal_code      STRING,
    timezone         STRING,
    latitude         FLOAT64,
    longitude        FLOAT64
);
