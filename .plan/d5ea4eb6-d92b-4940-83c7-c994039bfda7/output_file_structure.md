# Output File Structure

## Output File Structure

### Directory Layout
All generated DDL files are written to `/workspace/project/bigquery/` with the following structure:

```
bigquery/
├── raw/
│   ├── tables/
│   │   ├── sales_retail.sql
│   │   ├── omniture_logs.sql
│   │   ├── returns_cdc.sql
│   │   ├── pos_transactions.sql
│   │   ├── inventory_movements.sql
│   │   ├── mobile_events.sql
│   │   ├── loyalty_events.sql
│   │   ├── product_catalog_feed.sql
│   │   ├── supplier_invoices.sql
│   │   ├── email_campaign_clicks.sql
│   │   ├── shipment_tracking.sql
│   │   ├── return_authorizations.sql
│   │   ├── warehouse_picks.sql
│   │   ├── delivery_routes.sql
│   │   ├── driver_logs.sql
│   │   ├── customer_complaints.sql
│   │   └── chat_transcripts.sql
│   ├── external/
│   │   ├── customer_signups.sql
│   │   └── fraud_signals.sql
│   └── views/
│       ├── omniture.sql
│       └── v_fraud_signals_recent.sql
├── staging/
│   ├── tables/
│   │   ├── cleansed_orders.sql
│   │   ├── cleansed_customers.sql
│   │   ├── cleansed_products.sql
│   │   ├── dedup_clickstream.sql
│   │   ├── geocoded_addresses.sql
│   │   ├── parsed_loyalty_events.sql
│   │   ├── merged_returns_cdc.sql
│   │   ├── normalized_carrier_events.sql
│   │   ├── fraud_scored.sql
│   │   └── warehouse_kpi_snapshot.sql
│   └── views/
│       └── v_returns_pending.sql
├── datasets/
│   ├── create_raw_dataset.sql
│   └── create_staging_dataset.sql
└── scripts/
    └── validate_all_ddl.sh
```

### File Naming Convention
- One `.sql` file per database object, named exactly matching the Hive table/view name (lowercase, underscores)
- Subdirectories separate `tables/`, `external/` (for Parquet external tables), and `views/`
- Dataset creation DDL in `datasets/` — creates `acme-lake-project.raw` and `acme-lake-project.staging` BigQuery datasets

### DDL File Format
Each `.sql` file contains:
1. A header comment block with source table name, source file reference, and any migration notes
2. A single `CREATE OR REPLACE TABLE` (or `CREATE EXTERNAL TABLE` or `CREATE OR REPLACE VIEW`) statement
3. Fully qualified table references using backtick notation: `` `acme-lake-project.raw.table_name` ``

Example header:
```sql
-- Source: raw.sales_retail
-- Origin: clusters/acme-lake/hive/02-raw-external-tables.hql
-- Partition: date_ts STRING -> ingest_ts TIMESTAMP (HOUR granularity)
-- Storage: TEXTFILE -> BigQuery native (managed)
```

### Execution Order
The `validate_all_ddl.sh` script enforces dependency ordering:
1. **Phase 1**: Dataset creation (`datasets/*.sql`)
2. **Phase 2**: All tables — raw tables first, then staging tables (`raw/tables/*.sql`, `raw/external/*.sql`, `staging/tables/*.sql`)
3. **Phase 3**: All views — raw views first, then staging views (`raw/views/*.sql`, `staging/views/*.sql`) — since `staging.v_returns_pending` depends on `raw.return_authorizations`

### Total: 30 DDL files + 2 dataset files + 1 validation script = 33 files
