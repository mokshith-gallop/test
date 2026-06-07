-- BigQuery View: raw.v_fraud_signals_recent
-- Source: Hive raw.v_fraud_signals_recent (acme-lake/hive/05-additional-raw-feeds.hql)
-- Translation:
--   date_format(date_sub(current_date(), 1), 'yyyyMMdd')
--     → FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RAW}.v_fraud_signals_recent` AS
SELECT *
FROM `${PROJECT_US}.${DATASET_RAW}.fraud_signals`
WHERE signal_date >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY));
