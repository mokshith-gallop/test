-- BigQuery View: retail.vw_sales_rollup_by_region
-- Source: Hive retail.vw_sales_rollup_by_region (acme-analytics/hive/16-additional-views.hql)
-- Trap T2: WITH ROLLUP → GROUP BY ROLLUP(...)
-- Translation:
--   GROUP BY s.region, s.store_sk WITH ROLLUP → GROUP BY ROLLUP(s.region, s.store_sk)
--   GROUPING__ID → GROUPING(s.region) + GROUPING(s.store_sk) expression
--   date_sub(current_date(), 7) → DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_sales_rollup_by_region` AS
SELECT
    s.region,
    s.store_sk,
    SUM(f.line_total)              AS total_revenue,
    COUNT(*)                       AS line_count,
    GROUPING(s.region) * 2 + GROUPING(s.store_sk) AS grouping_level
FROM `${PROJECT_US}.${DATASET_RETAIL}.fact_sales` f
JOIN `${PROJECT_US}.${DATASET_RETAIL}.dim_store` s ON s.store_sk = f.customer_sk
WHERE f.sale_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY ROLLUP(s.region, s.store_sk);
