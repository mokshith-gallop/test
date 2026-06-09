-- Source: raw.omniture (VIEW)
-- Origin: clusters/acme-lake/hive/02-raw-external-tables.hql
-- References: acme-lake-project.raw.omniture_logs
-- Translation: date_ts -> ingest_ts (clean break, no aliasing)

CREATE OR REPLACE VIEW `acme-lake-project.raw.omniture` AS
SELECT
  `col_2`     AS `event_ts`,
  `col_8`     AS `ip`,
  `col_13`    AS `url`,
  `col_14`    AS `user_id`,
  `col_50`    AS `city`,
  `col_51`    AS `country`,
  `col_53`    AS `state`,
  `ingest_ts`
FROM `acme-lake-project.raw.omniture_logs`;
