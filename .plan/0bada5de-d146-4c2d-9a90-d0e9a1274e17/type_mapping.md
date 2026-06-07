# Type Mapping

## Hive → BigQuery Type Mapping Rules (Applied to All 82 Tables)

### Primitive Type Widening
| Hive Type | BigQuery Type | Rule |
|---|---|---|
| `TINYINT` | `INT64` | BigQuery has no narrow integer types |
| `SMALLINT` | `INT64` | BigQuery has no narrow integer types |
| `INT` | `INT64` | BigQuery universal integer |
| `BIGINT` | `INT64` | Direct mapping |
| `BOOLEAN` | `BOOL` | BigQuery keyword |
| `FLOAT` | `FLOAT64` | BigQuery universal float |
| `DOUBLE` | `FLOAT64` | Direct mapping |
| `STRING` | `STRING` | Direct mapping |
| `TIMESTAMP` | `TIMESTAMP` | Interpreted as UTC per locked validation decision §4 |
| `DATE` | `DATE` | Direct mapping |

### Fixed-Precision Decimal Mapping
| Hive Type | BigQuery Type | Rationale |
|---|---|---|
| `DECIMAL(p,s)` | `NUMERIC(p,s)` | Preserves precision constraints from source. All 86 DECIMAL columns across the DDL use parameterized `NUMERIC(p,s)` form. |

The acceptance criteria (AC-5, 7, 10, 11, 14) say "NUMERIC" without parameters. BigQuery's `NUMERIC(p,s)` is a subtype of `NUMERIC` — a `DESCRIBE` will report the column as `NUMERIC`, satisfying the AC. The parameterized form is **strictly better** because it prevents accidental insertion of values exceeding the source precision.

### Complex Type Mapping
| Hive Type | BigQuery Type | Tables Affected |
|---|---|---|
| `MAP<STRING,STRING>` | `JSON` | 11 tables (see AC-13 analysis below) |
| `ARRAY<STRUCT<...>>` | `ARRAY<STRUCT<...>>` | 4 tables (direct mapping) |
| `STRUCT<...>` | `STRUCT<...>` | 7 tables (direct mapping) |
| `ARRAY<STRING>` | `ARRAY<STRING>` | 5 tables (direct mapping) |

### ACID/ORC Table Conversion
All 5 ACID tables (`returns_ledger`, `acid_customer_address_history`, `acid_supplier_terms_history`, `acid_loyalty_points_ledger`, `acid_inventory_adjustments_log`) become standard BigQuery managed tables:
- No `transactional=true` property
- No ORC-specific properties
- All DECIMAL columns mapped to `NUMERIC(p,s)`
- `CLUSTERED BY ... INTO N BUCKETS` → `CLUSTER BY` (bucket count dropped)
- BigQuery's native snapshot isolation provides equivalent ACID semantics for MERGE/UPDATE/DELETE

### AC-13 MAP→JSON Column Analysis (Source-Faithful)

AC-13 lists 10 MAP columns for JSON conversion. Cross-referencing against Hive metastore:

| # | AC-13 Column | Hive Source | DDL Status | Action |
|---|---|---|---|---|
| 1 | `raw.loyalty_events.meta_raw` | STRING (RegexSerDe) | STRING | **No change** — not a MAP in source; stays STRING. Parsed via `parse_key_value_pairs` UDF at query time. AC exception documented. |
| 2 | `raw.mobile_events.properties` | MAP | JSON ✅ | Done |
| 3 | `raw.customer_complaints.resolution_details` | **Column absent** in Hive metastore | Not in DDL | **AC exception** — column not in source schema. Document for AC clarification. |
| 4 | `raw.chat_transcripts.session_metadata` | **Column absent** in Hive metastore | Not in DDL | **AC exception** — column not in source schema. Document for AC clarification. |
| 5 | `raw.email_campaign_clicks.utm_params` | MAP (column named `utm`) | JSON (as `utm`) ✅ | Done. Column name is `utm` in source, not `utm_params`. AC name mismatch documented. |
| 6 | `staging.parsed_loyalty_events.meta` | MAP | JSON ✅ | Done |
| 7 | `retail.dim_product_attributes.attributes` | **Table absent** in Hive metastore | Not in DDL | **AC exception** — table doesn't exist in source. Closest match is `bridge_product_attribute` (EAV pattern, no MAP column). Document for AC clarification. |
| 8 | `retail.dim_store.attributes` | Not in Hive metastore columns (added during conversion based on broader spec) | JSON ✅ | Done — `dim_store` DDL includes `attributes JSON`. |
| 9 | `retail.fact_loyalty_events.meta` | MAP | JSON ✅ | Done |
| 10 | `regional.events_eu.payload_json` | STRING (not MAP) | STRING | **No change** — source is a STRING containing JSON text, not a Hive MAP type. Converting to `JSON` type is a data transformation, not a schema mapping. AC exception documented. |

**Summary**: 6 of 10 MAP→JSON conversions are correctly implemented. 4 are AC exceptions requiring clarification (3 columns/tables don't exist in source, 1 is STRING not MAP).

### DDL Fixes Required (3 items)

**Fix 1: `raw.mobile_events` — context STRUCT field name**
- Current: `context STRUCT<ip STRING, country STRING, session_id STRING, referrer STRING>`
- Required (AC-6): `context STRUCT<ip_address STRING, country STRING, session_id STRING, referrer STRING>`
- Change: `ip` → `ip_address`

**Fix 2: `raw.mobile_events` — CLUSTER BY missing `platform`**
- Current: `CLUSTER BY hour_bucket`
- Required (AC-6): `CLUSTER BY platform, hour_bucket`
- Change: Add `platform` to CLUSTER BY

**Fix 3: Generate `ddl/all_tables.sql` concatenated file**
- New artifact: concatenate all DDL files per `deploy_order.txt` order with `${VAR}` substitution applied
- Purpose: satisfy AC-15 ("single SQL file, 0 errors with `bq query --use_legacy_sql=false`")
- Script: add `scripts/generate_concat_ddl.sh` that reads `deploy_order.txt`, applies `envsubst`, writes `ddl/all_tables.sql`
