-- BigQuery View: staging.v_returns_pending
-- Source: Hive staging.v_returns_pending (acme-lake/hive/06-staging-tables.hql)
-- Translation:
--   DATEDIFF(current_date(), to_date(r.requested_at))
--     → DATE_DIFF(CURRENT_DATE(), DATE(r.requested_at), DAY)

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_STAGING}.v_returns_pending` AS
SELECT
    r.rma_id,
    r.customer_id,
    r.invoice_no,
    r.stock_code,
    r.quantity,
    r.requested_at,
    DATE_DIFF(CURRENT_DATE(), DATE(r.requested_at), DAY) AS days_pending
FROM `${PROJECT_US}.${DATASET_RAW}.return_authorizations` r
WHERE r.approved IS NULL OR r.approved = FALSE;
