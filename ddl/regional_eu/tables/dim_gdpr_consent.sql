-- BigQuery DDL: regional_eu.dim_gdpr_consent
-- Source: Hive regional.dim_gdpr_consent (acme-edge/hive/regional-additional-tables.hql)
-- AC-12: granted BOOL, consent_date DATE partition key, EU location
-- Partition: DATE consent_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.dim_gdpr_consent`
(
    consent_id      STRING,
    customer_id     STRING,
    consent_type    STRING,
    granted         BOOL,
    granted_ts      TIMESTAMP,
    withdrawn_ts    TIMESTAMP,
    source          STRING,
    legal_basis     STRING,
    expiry_ts       TIMESTAMP,
    consent_date    DATE
)
PARTITION BY consent_date;
