-- =============================================================================
-- Dataset: acme-lake-project.raw
-- Purpose: Landing zone for raw ingested data from Hive acme-lake cluster.
--          Contains 15 managed tables, 2 external (Parquet) tables, and 2 views.
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS `acme-lake-project.raw`
OPTIONS (
  description = 'Raw landing dataset – migrated from Hive raw database on acme-lake cluster. Contains retail, logistics, mobile, loyalty, and support event feeds.',
  location    = 'US'
);
