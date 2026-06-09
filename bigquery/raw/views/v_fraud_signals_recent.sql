-- Source: raw.v_fraud_signals_recent (VIEW)
-- Origin: clusters/acme-lake/hive/05-additional-raw-feeds.hql
-- References: acme-lake-project.raw.fraud_signals
-- Translation: date_format(date_sub(current_date(), 1), 'yyyyMMdd')
--            -> FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))

CREATE OR REPLACE VIEW `acme-lake-project.raw.v_fraud_signals_recent` AS
SELECT *
FROM `acme-lake-project.raw.fraud_signals`
WHERE `signal_date` >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY));
