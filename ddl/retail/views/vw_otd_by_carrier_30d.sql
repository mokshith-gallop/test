-- BigQuery View: retail.vw_otd_by_carrier_30d
-- Source: Hive retail.vw_otd_by_carrier_30d (acme-analytics/hive/16-additional-views.hql)
-- Translation:
--   shipped_ts + INTERVAL '48' HOUR → TIMESTAMP_ADD(shipped_ts, INTERVAL 48 HOUR)
--   unix_timestamp(delivered_ts) - unix_timestamp(shipped_ts)
--     → UNIX_SECONDS(delivered_ts) - UNIX_SECONDS(shipped_ts)
--   date_sub(current_date(), 30) → DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
--   shipped_ts >= date → CAST comparison (shipped_ts is TIMESTAMP, filter is DATE)

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_otd_by_carrier_30d` AS
SELECT
    carrier,
    COUNT(*)                                                                     AS shipments,
    AVG(CASE WHEN delivered_ts <= TIMESTAMP_ADD(shipped_ts, INTERVAL 48 HOUR)
             THEN 1.0 ELSE 0.0 END)                                              AS otd_rate,
    AVG(UNIX_SECONDS(delivered_ts) - UNIX_SECONDS(shipped_ts)) / 3600.0           AS avg_transit_hours
FROM `${PROJECT_US}.${DATASET_RETAIL}.fact_shipments`
WHERE shipped_ts >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
GROUP BY carrier;
