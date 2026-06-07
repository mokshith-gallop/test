-- BigQuery DDL: retail.dim_promotion
-- Source: Hive retail.dim_promotion (acme-analytics/hive/10-additional-dims.hql)
-- Category: dim_net_new
-- MAP<STRING,STRING> eligibility → JSON
-- ARRAY<STRING> channels preserved

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.dim_promotion`
(
    promo_sk        INT64,
    promo_id        STRING,
    name            STRING,
    promo_type      STRING,
    pct_off         NUMERIC(5,2),
    flat_off        NUMERIC(10,2),
    start_dt        DATE,
    end_dt          DATE,
    budget          NUMERIC(14,2),
    channels        ARRAY<STRING>,
    eligibility     JSON
);
