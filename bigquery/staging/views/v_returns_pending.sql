-- Source: staging.v_returns_pending (VIEW)
-- Origin: clusters/acme-lake/hive/06-staging-tables.hql
-- References: acme-lake-project.raw.return_authorizations (cross-dataset)
-- Translation: DATEDIFF(current_date(), to_date(r.requested_at))
--            -> DATE_DIFF(CURRENT_DATE(), DATE(r.requested_at), DAY)

CREATE OR REPLACE VIEW `acme-lake-project.staging.v_returns_pending` AS
SELECT
  r.`rma_id`,
  r.`customer_id`,
  r.`invoice_no`,
  r.`stock_code`,
  r.`quantity`,
  r.`requested_at`,
  DATE_DIFF(CURRENT_DATE(), DATE(r.`requested_at`), DAY) AS `days_pending`
FROM `acme-lake-project.raw.return_authorizations` r
WHERE r.`approved` IS NULL OR r.`approved` = FALSE;
