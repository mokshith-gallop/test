# Implementation Approach

## Implementation Approach: DDL Fix-Up + Concat Generation + Source Baseline Script

### Current State Assessment

The existing codebase (from prior task execution, to be restored/verified) is **95% complete**. 100 table DDLs + 15 view DDLs + deploy script + validation report + YAML manifests were all in place. The work remaining is surgical:

1. **2 DDL fixes** to an existing file (`mobile_events.sql`)
2. **1 new script** to generate the concatenated SQL file (AC-15)
3. **1 new script** for Layer 0 live source baseline validation
4. **1 new artifact** (`all_tables.sql`)
5. **Update validation report** to reflect fixes, document AC exceptions, and include Layer 0 results

### Task Breakdown

#### Task 1: Fix `raw.mobile_events` DDL (AC-6 compliance)

File: `ddl/raw/tables/mobile_events.sql`

Two changes:
1. Rename `context` STRUCT field `ip` → `ip_address`
2. Change `CLUSTER BY hour_bucket` → `CLUSTER BY platform, hour_bucket`

Also update `config/tables/raw/mobile_events.yaml` if it references STRUCT field names or cluster columns.

#### Task 2: Create `scripts/generate_concat_ddl.sh` (AC-15)

New script that:
1. Reads `ddl/deploy_order.txt` line by line (skipping comments and blanks)
2. Loads variables from `ddl/variables.env`
3. For each `.sql` file, reads content, applies `envsubst` for `${VAR}` substitution
4. Writes all substituted DDL to `ddl/all_tables.sql` with section headers
5. Appends a trailing newline after each statement's `;`

Output: valid BigQuery SQL script with all project/dataset references resolved.

#### Task 3: Create `scripts/validate_source_baseline.py` (Layer 0)

New script that connects to the Hive metastore (via MCP SQL schema tools or direct JDBC) and:

1. **Captures live table lists** per schema (`db_raw`, `db_staging`, `db_retail`, `db_regional`)
2. **Captures AC-critical column types** (partition keys, DECIMAL columns, MAP/STRUCT/ARRAY columns)
3. **Computes the 3-set diff** per schema:
   - `matched = source ∩ target`
   - `missing_in_target = source − target` (must be empty)
   - `extra_in_target = target − source` (must equal net-new allowlist)
4. **Validates extra tables against the net-new allowlist**:
   - raw: `customer_signups`, `fraud_signals`
   - staging: (none)
   - retail: `dim_store`, `dim_supplier`, `dim_employee`, `dim_promotion`, `dim_warehouse`, `dim_currency`, `dim_geography`, `dim_color`, `dim_size`, `dim_brand`, `dim_category`, `dim_payment_method`, `inventory_realtime_snapshot`, `session_state_snapshot`, `promo_eligibility_snapshot`, `realtime_price_snapshot`
   - regional_eu: (none)
5. **Outputs structured results** (JSON + human-readable report)
6. **Graceful degradation**: if Hive connection fails, outputs all counts as `"UNVERIFIED / ASSUMED"` with a clear banner. Does not block DDL deployment but blocks AC-1 through AC-4 and AC-13/AC-14 sign-off.

#### Task 4: Generate `ddl/all_tables.sql`

Run the script from Task 2 to produce the artifact. This file goes into the repo so it can be verified by `bq query --use_legacy_sql=false --dry_run < ddl/all_tables.sql`.

#### Task 5: Update `ddl/VALIDATION_REPORT.md`

Update the report to:
1. Reflect the `mobile_events` fixes (context field, CLUSTER BY)
2. Add new §0 with Layer 0 live source baseline results (table lists, column types, 3-set diffs)
3. Add §8 documenting AC-13 exceptions with the source-faithful rationale
4. Replace the old table-count section with the resolved live-diff reconciliation (17+2, 10+0, 42+16, 13+0)
5. Note the `all_tables.sql` artifact for AC-15
6. If Layer 0 ran without live Hive, mark source counts as "UNVERIFIED / ASSUMED"

### What NOT to Change

- **No other DDL files need modification** — the remaining 99 table files and 15 view files pass all checks
- **No type mapping changes** — `NUMERIC(p,s)` is the correct form and AC-compliant
- **No partition/cluster changes** beyond `mobile_events` — all others match the locked conversion table
- **Do not add missing AC-13 columns** (per source-faithful decision) — document as exceptions only
- **Do not modify `deploy_ddl.py`** — it already works correctly for production deployment
- **Do not modify `deploy_order.txt`** — the ordering is correct

### Net-New Allowlist (Definitive)

| Dataset | Net-New Table | Rationale | Confirmed Absent from Hive |
|---|---|---|---|
| raw | `customer_signups` | Direct GCS landing target, no Hive source | ✅ `list_tables(db_raw)` = 17, table absent |
| raw | `fraud_signals` | Fraud model output landing, no Hive source | ✅ `list_tables(db_raw)` = 17, table absent |
| retail | `dim_store` | Conformed dim, embedded in Hive views | ✅ `search_tables(db_retail, "dim_store")` → only `dim_store_history` |
| retail | `dim_supplier` | Conformed dim | ✅ absent from `db_retail` 42-table list |
| retail | `dim_employee` | Conformed dim | ✅ absent (only `dim_employee_history` exists) |
| retail | `dim_promotion` | Conformed dim | ✅ absent |
| retail | `dim_warehouse` | Conformed dim | ✅ absent |
| retail | `dim_currency` | Conformed dim | ✅ absent |
| retail | `dim_geography` | Conformed dim | ✅ absent |
| retail | `dim_color` | Conformed dim | ✅ absent |
| retail | `dim_size` | Conformed dim | ✅ absent |
| retail | `dim_brand` | Conformed dim | ✅ absent |
| retail | `dim_category` | Conformed dim | ✅ absent |
| retail | `dim_payment_method` | Conformed dim | ✅ absent |
| retail | `inventory_realtime_snapshot` | Kudu→Bigtable BQ snapshot | ✅ absent (Kudu tables not in Hive metastore) |
| retail | `session_state_snapshot` | Kudu→Bigtable BQ snapshot | ✅ absent |
| retail | `promo_eligibility_snapshot` | Kudu→Bigtable BQ snapshot | ✅ absent |
| retail | `realtime_price_snapshot` | Kudu→Bigtable BQ snapshot | ✅ absent |

### Integration Points

| Component | Relationship |
|---|---|
| `ddl/variables.env` | Read by concat script for variable substitution |
| `ddl/deploy_order.txt` | Defines file ordering for concatenation; provides target table list for Layer 0 diff |
| `scripts/deploy_ddl.py` | Unmodified — remains the production deployment tool |
| `config/tables/raw/mobile_events.yaml` | May need CLUSTER BY column update to match DDL fix |
| MCP SQL schema tools | Used by `validate_source_baseline.py` for live Hive queries |

### Execution Order

1. Fix `mobile_events.sql` + update YAML manifest (Task 1)
2. Create `generate_concat_ddl.sh` (Task 2)
3. Create `validate_source_baseline.py` (Task 3)
4. Run source baseline validation (Task 3 execution)
5. Run concat generator to produce `all_tables.sql` (Task 4)
6. Update `VALIDATION_REPORT.md` with Layer 0 results + fixes + AC exceptions (Task 5)
7. Verify: grep `all_tables.sql` for remaining `${` tokens (should be 0)
8. Verify: count `CREATE TABLE` in `all_tables.sql` (should be 100)
9. Verify: count `CREATE OR REPLACE VIEW` (should be 15)
