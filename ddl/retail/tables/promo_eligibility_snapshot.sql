-- BigQuery DDL: retail.promo_eligibility_snapshot
-- Source: Hive retail.kudu_promo_eligibility (acme-analytics/hive/14-kudu-realtime.hql)
-- Category: kudu_snapshot (Kudu PRIMARY KEY/HASH → standard BigQuery table)
-- Kudu BIGINT timestamps → INT64 (epoch millis)

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.promo_eligibility_snapshot`
(
    customer_id     STRING,
    promo_id        STRING,
    eligible        BOOL,
    eligibility_reason STRING,
    valid_from_ts   INT64,
    valid_to_ts     INT64,
    redeemed        BOOL
);
