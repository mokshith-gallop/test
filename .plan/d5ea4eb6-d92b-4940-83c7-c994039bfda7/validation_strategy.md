# Validation Strategy

## DDL Validation Strategy

### 1. Dry-Run Validation (AC #9)
Every generated DDL file is validated via BigQuery dry-run against the scratch dataset `bq_scratch_schema_test`:

```bash
bq query --dry_run --use_legacy_sql=false < raw/sales_retail.sql
```

**Pass criteria**: Zero parse errors, zero type errors across all 30 DDL files.

**Automation**: A shell script (`validate_all_ddl.sh`) iterates over every `.sql` file in the output directory, runs the dry-run, and collects results into a pass/fail report. The script:
1. Creates datasets `bq_scratch_schema_test.raw` and `bq_scratch_schema_test.staging` if not present
2. Runs each table DDL as a dry-run (tables first, then views since views depend on tables)
3. Outputs a summary: `PASS: 30/30` or lists failures with error messages

### 2. Schema Parity Validation (AC #10, #11)
For each table, a comparison script runs:
- **Hive side**: `DESCRIBE FORMATTED <database>.<table>` on acme-lake
- **BigQuery side**: `bq show --schema <project>:<dataset>.<table>`

**Checks performed**:
1. **Column presence**: Every source column is present in target (except dropped partition columns replaced by synthetics)
2. **Type correctness**: Mapped types match the locked Type Mapping rules (STRING→STRING, INT→INT64, DECIMAL→NUMERIC, TIMESTAMP→DATETIME)
3. **No unexpected columns**: No columns added except documented synthetic partition columns (`ingest_ts`, `event_ts`, `invoice_month`, `movement_date`, `event_date`)
4. **Partition intent preserved**: Source partition semantics are preserved — hourly STRING partitions become TIMESTAMP HOUR partitions, multi-column partitions collapse correctly

### 3. Complex Type Spot-Checks (AC #2, #11)
Specific validation for the 5 MAP→JSON, 3 STRUCT, and 2 ARRAY columns:
- `raw.mobile_events`: Verify `properties` is JSON, `context` is STRUCT with 4 STRING fields, `items` is ARRAY<STRUCT> with correct nested types
- `raw.supplier_invoices`: Verify `line_items` is ARRAY<STRUCT<sku STRING, qty INT64, unit_price NUMERIC>>
- `raw.product_catalog_feed`: Verify `metadata` is JSON
- All MAP columns: Confirm JSON type (not STRING or ARRAY<STRUCT>)

### 4. View Dependency Validation
After table DDLs pass dry-run:
1. Run view DDLs and confirm they reference the correct fully-qualified table names
2. `raw.omniture` → references `acme-lake-project.raw.omniture_logs`
3. `raw.v_fraud_signals_recent` → references `acme-lake-project.raw.fraud_signals`
4. `staging.v_returns_pending` → references `acme-lake-project.raw.return_authorizations` (cross-dataset)

### 5. Edge Cases & Error Handling
- **Avro externals**: `customer_signups` and `fraud_signals` external table DDL is validated syntactically but cannot fully resolve schema until GCS Parquet files exist. The dry-run validates the `CREATE EXTERNAL TABLE ... OPTIONS(format='PARQUET', uris=[...])` syntax only.
- **Reserved words**: BigQuery column names are checked against GoogleSQL reserved words. Known safe: all source column names (`name`, `size`, `status`) are not reserved in GoogleSQL when unquoted, but the DDL generator will backtick-quote all column names defensively.
- **Table description comments**: Verify the 3 legacy-format tables include the `OPTIONS(description=...)` noting Parquet transit requirements.
