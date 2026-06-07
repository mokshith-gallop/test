-- BigQuery View: raw.omniture
-- Source: Hive raw.omniture (acme-lake/hive/02-raw-external-tables.hql)
-- Thin projection view over omniture_logs (60-col STRING landing table).
-- Translation: direct mapping, fully-qualified table reference added.

CREATE OR REPLACE VIEW `${PROJECT_US}.${DATASET_RAW}.omniture` AS
SELECT
    col_2  AS event_ts,
    col_8  AS ip,
    col_13 AS url,
    col_14 AS user_id,
    col_50 AS city,
    col_51 AS country,
    col_53 AS state,
    date_ts
FROM `${PROJECT_US}.${DATASET_RAW}.omniture_logs`;
