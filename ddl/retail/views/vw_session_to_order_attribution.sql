-- BigQuery View: retail.vw_session_to_order_attribution
-- Source: Hive retail.vw_session_to_order_attribution (acme-analytics/hive/09-analytics-views.hql)
-- Cross-project: raw.mobile_events → ${PROJECT_US}.${DATASET_RAW}.mobile_events
-- Translation:
--   s.event_ts + INTERVAL '1' DAY → TIMESTAMP_ADD(s.event_ts, INTERVAL 1 DAY)
--   s.context.referrer → s.context.referrer (STRUCT access is same in BQ)

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_session_to_order_attribution` AS
SELECT
  s.user_id,
  s.event_ts                                AS session_ts,
  s.context.referrer                        AS referrer,
  f.invoice_no,
  f.invoice_ts                              AS order_ts,
  f.line_total
FROM `${PROJECT_US}.${DATASET_RAW}.mobile_events` s
LEFT JOIN `${PROJECT_US}.${DATASET_RETAIL}.dim_customer` dc ON dc.customer_id = s.user_id
LEFT JOIN `${PROJECT_US}.${DATASET_RETAIL}.fact_sales` f
       ON  f.customer_sk = dc.customer_sk
       AND f.invoice_ts BETWEEN s.event_ts AND TIMESTAMP_ADD(s.event_ts, INTERVAL 1 DAY);
