-- BigQuery View: retail.vw_panel_continuity_score
-- Source: Hive retail.vw_panel_continuity_score (acme-analytics/hive/16-additional-views.hql)
-- Trap T4: UDF inside JOIN ON clause.
-- Translation:
--   normalize_country(x) → `${PROJECT_US}.${DATASET_RETAIL}.normalize_country`(x)
--   BigQuery UDF must be deployed before this view is created.
--   date_sub(current_date(), 90) → DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_panel_continuity_score` AS
SELECT
    f.customer_sk,
    COUNT(DISTINCT f.sale_date)         AS active_days,
    COUNT(DISTINCT f.product_sk)        AS distinct_products,
    SUM(f.line_total)                   AS total_spend
FROM `${PROJECT_US}.${DATASET_RETAIL}.fact_sales` f
JOIN `${PROJECT_US}.${DATASET_RETAIL}.dim_customer` c
  ON c.customer_sk = f.customer_sk
 AND `${PROJECT_US}.${DATASET_RETAIL}.normalize_country`(c.country)
   = `${PROJECT_US}.${DATASET_RETAIL}.normalize_country`(f.country)
WHERE f.sale_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY f.customer_sk;
