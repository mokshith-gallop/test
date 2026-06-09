-- =============================================================================
-- Dataset: acme-lake-project.staging
-- Purpose: Staging / curated layer for cleansed, deduplicated, and enriched
--          data derived from acme-lake-project.raw tables.
--          Contains 10 managed tables and 1 view.
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS `acme-lake-project.staging`
OPTIONS (
  description = 'Staging dataset – migrated from Hive staging database on acme-lake cluster. Contains cleansed orders, customers, products, clickstream, loyalty, returns, carrier events, fraud scoring, and warehouse KPIs.',
  location    = 'US'
);
