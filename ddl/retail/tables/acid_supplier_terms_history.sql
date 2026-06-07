-- BigQuery DDL: retail.acid_supplier_terms_history
-- Source: Hive retail.acid_supplier_terms_history (acme-analytics/hive/13-additional-acid-tables.hql)
-- AC-14: ACID ORC table → standard BigQuery managed table, DECIMAL→NUMERIC
-- Clustering: CLUSTERED BY (supplier_sk) INTO 4 BUCKETS → CLUSTER BY supplier_sk

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.acid_supplier_terms_history`
(
    history_id         INT64,
    supplier_sk        INT64,
    payment_terms_days INT64,
    discount_pct       NUMERIC(5,2),
    eff_from           TIMESTAMP,
    eff_to             TIMESTAMP,
    is_current         BOOL,
    changed_by         STRING
)
CLUSTER BY supplier_sk;
