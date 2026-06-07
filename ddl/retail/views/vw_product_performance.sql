-- BigQuery View: retail.vw_product_performance
-- Source: Hive retail.vw_product_performance (acme-analytics/hive/09-analytics-views.hql)
-- Translation: direct mapping — RANK/DENSE_RANK OVER are standard SQL.

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_product_performance` AS
WITH sold AS (
  SELECT
    p.product_sk,
    p.stock_code,
    p.description,
    f.country,
    SUM(f.line_total)                AS revenue,
    SUM(f.quantity)                  AS units,
    COUNT(DISTINCT f.invoice_no)     AS orders
  FROM `${PROJECT_US}.${DATASET_RETAIL}.dim_product` p
  JOIN `${PROJECT_US}.${DATASET_RETAIL}.fact_sales` f ON f.product_sk = p.product_sk
  GROUP BY p.product_sk, p.stock_code, p.description, f.country
),
ranked AS (
  SELECT
    s.*,
    RANK()       OVER (PARTITION BY s.country ORDER BY s.revenue DESC)  AS country_rank,
    DENSE_RANK() OVER (                       ORDER BY s.revenue DESC)  AS global_rank
  FROM sold s
)
SELECT * FROM ranked;
