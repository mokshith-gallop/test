-- BigQuery View: retail.vw_customer_lifetime_value
-- Source: Hive retail.vw_customer_lifetime_value (acme-analytics/hive/09-analytics-views.hql)
-- Translation:
--   DATEDIFF(CURRENT_DATE(), last_order_date) → DATE_DIFF(CURRENT_DATE(), last_order_date, DAY)
--   CURRENT_DATE() → CURRENT_DATE() (same in BQ)

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_customer_lifetime_value` AS
WITH per_customer AS (
  SELECT
    c.customer_sk,
    c.customer_id,
    c.country,
    MIN(f.sale_date)              AS first_order_date,
    MAX(f.sale_date)              AS last_order_date,
    COUNT(DISTINCT f.invoice_no)  AS orders,
    SUM(f.line_total)             AS lifetime_revenue
  FROM `${PROJECT_US}.${DATASET_RETAIL}.dim_customer` c
  LEFT JOIN `${PROJECT_US}.${DATASET_RETAIL}.fact_sales` f ON f.customer_sk = c.customer_sk
  GROUP BY c.customer_sk, c.customer_id, c.country
)
SELECT
  customer_sk,
  customer_id,
  country,
  first_order_date,
  last_order_date,
  orders,
  lifetime_revenue,
  DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) AS recency_days,
  CASE
    WHEN orders = 0                                                    THEN 'never'
    WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) <= 30        THEN 'active'
    WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) <= 90        THEN 'warm'
    WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) <= 365       THEN 'cold'
    ELSE 'churned'
  END                                              AS rfm_bucket
FROM per_customer;
