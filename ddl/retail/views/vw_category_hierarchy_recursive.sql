-- BigQuery View: retail.vw_category_hierarchy_recursive
-- Source: Hive retail.vw_category_hierarchy_recursive (acme-analytics/hive/16-additional-views.hql)
-- Trap T3: WITH RECURSIVE — BigQuery supports WITH RECURSIVE natively.
-- Translation: direct mapping with fully-qualified table references.

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RETAIL}.vw_category_hierarchy_recursive` AS
WITH RECURSIVE cat_tree AS (
    SELECT
        category_id,
        name,
        parent_id,
        CAST(name AS STRING) AS path,
        0 AS depth
    FROM `${PROJECT_US}.${DATASET_RETAIL}.dim_category`
    WHERE parent_id IS NULL OR parent_id = ''

    UNION ALL

    SELECT
        c.category_id,
        c.name,
        c.parent_id,
        CONCAT(t.path, ' > ', c.name) AS path,
        t.depth + 1                   AS depth
    FROM `${PROJECT_US}.${DATASET_RETAIL}.dim_category` c
    JOIN cat_tree t ON c.parent_id = t.category_id
    WHERE t.depth < 8
)
SELECT * FROM cat_tree;
