# Type Mapping

## Hive → BigQuery Type Mapping Rules

### Scalar Type Mappings
| Hive Type | BigQuery Type | Notes |
|---|---|---|
| `STRING` | `STRING` | Direct 1:1 |
| `INT` | `INT64` | Hive INT (32-bit) widens to BQ INT64 |
| `BIGINT` | `INT64` | Direct 1:1 |
| `TINYINT` | `INT64` | Hive TINYINT (8-bit) widens to BQ INT64 |
| `BOOLEAN` | `BOOL` | Direct 1:1 |
| `DOUBLE` | `FLOAT64` | Direct 1:1 |
| `DECIMAL(p,s)` | `NUMERIC` | All DECIMAL variants (10,2), (14,2), (12,2), (8,2), (4,3), (5,4), (18,2) map to NUMERIC. BigQuery NUMERIC supports 29 digits before decimal, 9 after — sufficient for all source precisions. |
| `DATE` | `DATE` | Direct 1:1 |
| `TIMESTAMP` | `DATETIME` | Per AC #10: Hive TIMESTAMP → BigQuery DATETIME (no timezone). Note: synthetic partition columns use TIMESTAMP with timezone for partitioning purposes. |

### Complex Type Mappings (per locked MAP/STRUCT/ARRAY decision)
| Hive Type | BigQuery Type | Affected Tables |
|---|---|---|
| `MAP<STRING,STRING>` | `JSON` | `raw.mobile_events.properties`, `raw.product_catalog_feed.metadata`, `raw.email_campaign_clicks.utm`, `raw.driver_logs.extras`, `staging.parsed_loyalty_events.meta` |
| `STRUCT<...>` | `STRUCT<...>` | `raw.mobile_events.context`, `raw.email_campaign_clicks.geo`, `raw.driver_logs.gps` — field types mapped using scalar rules above |
| `ARRAY<STRUCT<...>>` | `ARRAY<STRUCT<...>>` | `raw.mobile_events.items`, `raw.supplier_invoices.line_items` — nested field types mapped using scalar rules (INT→INT64, DECIMAL(10,2)→NUMERIC) |
| `ARRAY<STRING>` | `ARRAY<STRING>` | `staging.fraud_scored.signals` |

### Partition Column Transformations (per locked Partitioning Strategy)

#### Pattern A: Single `date_ts STRING` → `ingest_ts TIMESTAMP`
Applies to 12 tables. The `date_ts STRING` (format `yyyyMMdd_HH`) partition column is **replaced** by a synthetic `ingest_ts TIMESTAMP` column, partitioned at **HOUR** granularity.

**Affected tables:** `raw.sales_retail`, `raw.omniture_logs`, `raw.pos_transactions`, `raw.loyalty_events`, `raw.product_catalog_feed` (feed_date→ingest_ts), `raw.email_campaign_clicks`, `raw.return_authorizations`, `raw.delivery_routes`, `raw.driver_logs`, `raw.customer_complaints`, `raw.chat_transcripts`, `staging.parsed_loyalty_events`, `staging.normalized_carrier_events`, `staging.warehouse_kpi_snapshot`

#### Pattern B: Multi-column date partitions → single collapsed column
| Table | Hive Partitions | BQ Partition Column | BQ CLUSTER BY |
|---|---|---|---|
| `raw.mobile_events` | `event_date STRING, hour_bucket TINYINT` | `event_ts TIMESTAMP` (HOUR granularity) | `hour_bucket` |
| `raw.supplier_invoices` | `feed_year INT, feed_month INT` | `invoice_month DATE` (MONTH granularity) | _(none)_ |
| `raw.inventory_movements` | `year INT, month INT, day INT` | `movement_date DATE` (DAY granularity) | _(none)_ |
| `raw.shipment_tracking` | `date_ts STRING, carrier_partition STRING` | `ingest_ts TIMESTAMP` (HOUR granularity) | `carrier_partition` |
| `raw.warehouse_picks` | `date_ts STRING, warehouse_id_partition STRING` | `ingest_ts TIMESTAMP` (HOUR granularity) | `warehouse_id_partition` |
| `staging.dedup_clickstream` | `date_ts STRING, country_partition STRING` | `event_date DATE` (DAY granularity) | `country_partition, user_id` |

#### Pattern C: Already-native DATE partitions (no change needed)
These staging tables already partition by a DATE column — carried over as-is:
`staging.cleansed_orders` (order_date), `staging.cleansed_customers` (load_date), `staging.cleansed_products` (load_date), `staging.geocoded_addresses` (load_date), `staging.merged_returns_cdc` (snapshot_date), `staging.fraud_scored` (score_date)

Also: `raw.returns_cdc` (snapshot_date DATE) — native, no change.

### Avro Tables → External Parquet Tables
`raw.customer_signups` and `raw.fraud_signals` are created as **BigQuery external tables** over GCS Parquet files (converted from Avro). Schema is auto-detected from Parquet footers. Partition columns (`signup_date`, `signal_date`) use hive-partitioned GCS paths.

### Legacy SerDe Tables → Native Tables via Parquet Transit
`raw.product_catalog_feed` (RCFile), `raw.supplier_invoices` (SequenceFile), `raw.loyalty_events` (RegexSerDe) are created as **native BigQuery managed tables** loaded via `bq load` from GCS Parquet transit output. Each DDL includes an `OPTIONS(description="...")` comment noting the Parquet transit load requirement.

### View SQL Translations
| Hive Function/Syntax | BigQuery GoogleSQL |
|---|---|
| `DATEDIFF(current_date(), to_date(col))` | `DATE_DIFF(CURRENT_DATE(), DATE(col), DAY)` |
| `date_format(date_sub(current_date(), 1), 'yyyyMMdd')` | `FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))` |
| `date_ts` column reference in views | Replaced with `ingest_ts` (clean break, no aliasing) |
| Cross-database `raw.table` reference in staging view | Fully qualified `\`acme-lake-project.raw.table\`` |
