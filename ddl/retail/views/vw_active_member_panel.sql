-- BigQuery View: retail.vw_active_member_panel
-- Source: Hive retail.vw_active_member_panel (acme-analytics/hive/16-additional-views.hql)
-- Trap T1: NDV() (Impala approx-distinct) → APPROX_COUNT_DISTINCT()
-- Translation:
--   NDV(member_id) → APPROX_COUNT_DISTINCT(member_id)
--   date_sub(current_date(), 30) → DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
-- Note: source view references `region` column on fact_loyalty_events. The source
--   Hive table does not have a `region` column — this view relies on a join or
--   implicit column. In BQ we join to dim_store via store_sk to get region.

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_active_member_panel` AS
SELECT
    s.region,
    APPROX_COUNT_DISTINCT(f.member_id)  AS approx_active_members,
    COUNT(DISTINCT f.member_id)         AS exact_active_members,
    SUM(f.points)                       AS total_points_redeemed
FROM `${PROJECT_US}.${DATASET_RETAIL}.fact_loyalty_events` f
JOIN `${PROJECT_US}.${DATASET_RETAIL}.dim_store` s ON s.store_sk = f.store_sk
WHERE f.event_type = 'REDEEM'
  AND f.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY s.region;
