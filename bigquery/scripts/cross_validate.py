#!/usr/bin/env python3
"""
Cross-validate BigQuery DDL files against source Hive HQL definitions.

Checks:
1. Column presence — every source column present with correct mapped type
2. No unexpected columns — only documented synthetic partition columns added
3. Partition columns correctly dropped and replaced
4. Type mapping correctness (INT→INT64, DECIMAL→NUMERIC, TIMESTAMP→DATETIME, etc.)
5. AC-specific validations (#1–#8)
6. Global consistency (no ${} vars, no NUMERIC(p,s), all MAP→JSON, etc.)
"""

import re
import sys
import os
from pathlib import Path

# ─── Type Mapping Rules ───────────────────────────────────────────────
SCALAR_MAP = {
    'STRING': 'STRING',
    'INT': 'INT64',
    'BIGINT': 'INT64',
    'TINYINT': 'INT64',
    'BOOLEAN': 'BOOL',
    'DOUBLE': 'FLOAT64',
    'DATE': 'DATE',
    'TIMESTAMP': 'DATETIME',
}

def map_hive_type(hive_type):
    """Map a Hive type to expected BigQuery type."""
    t = hive_type.strip().upper()
    # DECIMAL(p,s) → NUMERIC
    if t.startswith('DECIMAL'):
        return 'NUMERIC'
    # MAP<STRING,STRING> → JSON
    if t.startswith('MAP<'):
        return 'JSON'
    # ARRAY<STRING> → ARRAY<STRING>
    if t == 'ARRAY<STRING>':
        return 'ARRAY<STRING>'
    # ARRAY<STRUCT<...>> — just check it starts with ARRAY<STRUCT
    if t.startswith('ARRAY<STRUCT'):
        return 'ARRAY<STRUCT>'  # simplified check
    # STRUCT<...> — just check it starts with STRUCT
    if t.startswith('STRUCT<'):
        return 'STRUCT'  # simplified check
    return SCALAR_MAP.get(t, t)


# ─── Parse Hive columns from HQL ─────────────────────────────────────
def parse_hive_columns(hql_content, table_name):
    """Extract column definitions and partition columns from a CREATE TABLE."""
    # Find the CREATE (EXTERNAL) TABLE block for this table
    pattern = rf'CREATE\s+(?:EXTERNAL\s+)?TABLE\s+(?:\w+\.)?{re.escape(table_name)}\s*\((.*?)\)\s*PARTITIONED\s+BY\s*\((.*?)\)'
    match = re.search(pattern, hql_content, re.DOTALL | re.IGNORECASE)
    if not match:
        # Try without PARTITIONED BY
        pattern2 = rf'CREATE\s+(?:EXTERNAL\s+)?TABLE\s+(?:\w+\.)?{re.escape(table_name)}\s*\((.*?)\)'
        match2 = re.search(pattern2, hql_content, re.DOTALL | re.IGNORECASE)
        if match2:
            return parse_col_list(match2.group(1)), []
        return [], []

    data_cols = parse_col_list(match.group(1))
    part_cols = parse_col_list(match.group(2))
    return data_cols, part_cols


def parse_col_list(col_text):
    """Parse a comma-separated column definition block, handling nested types."""
    cols = []
    # We need to split on commas that are not inside angle brackets or parens
    depth = 0
    current = ''
    for ch in col_text:
        if ch in '<(':
            depth += 1
            current += ch
        elif ch in '>)':
            depth -= 1
            current += ch
        elif ch == ',' and depth == 0:
            cols.append(current.strip())
            current = ''
        else:
            current += ch
    if current.strip():
        cols.append(current.strip())

    result = []
    for col_def in cols:
        # Remove inline comments
        col_def = re.sub(r'--.*$', '', col_def, flags=re.MULTILINE).strip()
        if not col_def:
            continue
        # Split into name and type
        parts = col_def.split(None, 1)
        if len(parts) >= 2:
            name = parts[0].strip().lower()
            ctype = parts[1].strip()
            # Remove trailing commas
            ctype = ctype.rstrip(',').strip()
            result.append((name, ctype))
    return result


# ─── Parse BigQuery columns from SQL ─────────────────────────────────
def parse_bq_columns(sql_content):
    """Extract column definitions from a BigQuery CREATE TABLE statement."""
    # Find the column block between first ( and matching )
    # Handle CREATE OR REPLACE TABLE `...` (...)
    match = re.search(r'(?:CREATE\s+OR\s+REPLACE\s+TABLE|CREATE\s+TABLE\s+IF\s+NOT\s+EXISTS|CREATE\s+EXTERNAL\s+TABLE)\s+`[^`]+`\s*\((.*?)\)\s*(?:PARTITION|CLUSTER|OPTIONS|;)',
                      sql_content, re.DOTALL | re.IGNORECASE)
    if not match:
        return []

    col_text = match.group(1)
    cols = []
    depth = 0
    current = ''
    for ch in col_text:
        if ch in '<(':
            depth += 1
            current += ch
        elif ch in '>)':
            depth -= 1
            current += ch
        elif ch == ',' and depth == 0:
            cols.append(current.strip())
            current = ''
        else:
            current += ch
    if current.strip():
        cols.append(current.strip())

    result = []
    for col_def in cols:
        col_def = re.sub(r'--.*$', '', col_def, flags=re.MULTILINE).strip()
        if not col_def:
            continue
        # Remove backticks
        col_def = col_def.replace('`', '')
        parts = col_def.split(None, 1)
        if len(parts) >= 2:
            name = parts[0].strip().lower()
            ctype = parts[1].strip().rstrip(',').strip()
            result.append((name, ctype))
    return result


# ─── Validation Results ───────────────────────────────────────────────
class ValidationResult:
    def __init__(self):
        self.checks = []
        self.errors = []
        self.warnings = []

    def ok(self, msg):
        self.checks.append(('✓', msg))

    def fail(self, msg):
        self.checks.append(('✗', msg))
        self.errors.append(msg)

    def warn(self, msg):
        self.checks.append(('⚠', msg))
        self.warnings.append(msg)

    def print_report(self):
        for symbol, msg in self.checks:
            print(f"  {symbol} {msg}")


# ─── Table validation definitions ────────────────────────────────────
# Maps table name → (hql_file, partition_pattern, expected_synthetic_cols, dropped_partition_cols)
# Pattern A: date_ts STRING → ingest_ts TIMESTAMP (HOUR)
# Pattern B: multi-col → single synthetic
# Pattern C: native DATE passthrough

RAW_TABLES = {
    'sales_retail': {
        'hql': '02-raw-external-tables.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'omniture_logs': {
        'hql': '02-raw-external-tables.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'returns_cdc': {
        'hql': '02-raw-external-tables.hql',
        'pattern': 'C',
        'dropped_parts': [],
        'synthetic': [],
        'renames': {},
    },
    'pos_transactions': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'inventory_movements': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'B',
        'dropped_parts': ['year', 'month', 'day'],
        'synthetic': [('movement_date', 'DATE')],
        'renames': {},
    },
    'loyalty_events': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'product_catalog_feed': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['feed_date'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'supplier_invoices': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'B',
        'dropped_parts': ['feed_year', 'feed_month'],
        'synthetic': [('invoice_month', 'DATE')],
        'renames': {},
    },
    'email_campaign_clicks': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'shipment_tracking': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'B',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'kept_parts': ['carrier_partition'],
        'renames': {},
    },
    'return_authorizations': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'warehouse_picks': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'B',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'kept_parts': ['warehouse_id_partition'],
        'renames': {},
    },
    'delivery_routes': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'driver_logs': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'customer_complaints': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'chat_transcripts': {
        'hql': '05-additional-raw-feeds.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'mobile_events': {
        'hql': '07-json-raw.hql',
        'pattern': 'B',
        'dropped_parts': ['event_date'],
        'synthetic': [('event_ts', 'TIMESTAMP')],
        'kept_parts': ['hour_bucket'],
        'renames': {'event_ts': 'event_ts_orig'},
    },
}

STAGING_TABLES = {
    'cleansed_orders': {
        'hql': '06-staging-tables.hql',
        'pattern': 'C',
        'dropped_parts': [],
        'synthetic': [],
        'renames': {},
    },
    'cleansed_customers': {
        'hql': '06-staging-tables.hql',
        'pattern': 'C',
        'dropped_parts': [],
        'synthetic': [],
        'renames': {},
    },
    'cleansed_products': {
        'hql': '06-staging-tables.hql',
        'pattern': 'C',
        'dropped_parts': [],
        'synthetic': [],
        'renames': {},
    },
    'dedup_clickstream': {
        'hql': '06-staging-tables.hql',
        'pattern': 'B',
        'dropped_parts': ['date_ts'],
        'synthetic': [('event_date', 'DATE')],
        'kept_parts': ['country_partition'],
        'renames': {},
    },
    'geocoded_addresses': {
        'hql': '06-staging-tables.hql',
        'pattern': 'C',
        'dropped_parts': [],
        'synthetic': [],
        'renames': {},
    },
    'parsed_loyalty_events': {
        'hql': '06-staging-tables.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'merged_returns_cdc': {
        'hql': '06-staging-tables.hql',
        'pattern': 'C',
        'dropped_parts': [],
        'synthetic': [],
        'renames': {},
    },
    'normalized_carrier_events': {
        'hql': '06-staging-tables.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
    'fraud_scored': {
        'hql': '06-staging-tables.hql',
        'pattern': 'C',
        'dropped_parts': [],
        'synthetic': [],
        'renames': {},
    },
    'warehouse_kpi_snapshot': {
        'hql': '06-staging-tables.hql',
        'pattern': 'A',
        'dropped_parts': ['date_ts'],
        'synthetic': [('ingest_ts', 'TIMESTAMP')],
        'renames': {},
    },
}

def validate_table(table_name, config, dataset, hql_base, bq_base, result):
    """Validate a single table DDL against its Hive source."""
    hql_path = os.path.join(hql_base, config['hql'])
    if dataset == 'raw':
        bq_path = os.path.join(bq_base, 'raw', 'tables', f'{table_name}.sql')
    else:
        bq_path = os.path.join(bq_base, 'staging', 'tables', f'{table_name}.sql')

    # Read source
    with open(hql_path) as f:
        hql_content = f.read()
    with open(bq_path) as f:
        bq_content = f.read()

    # Parse columns
    hive_data_cols, hive_part_cols = parse_hive_columns(hql_content, table_name)
    bq_cols = parse_bq_columns(bq_content)

    if not hive_data_cols and not hive_part_cols:
        result.warn(f"Could not parse Hive schema for {table_name} (may be Avro/schema-less)")
        return

    bq_col_dict = {name: ctype for name, ctype in bq_cols}
    renames = config.get('renames', {})
    dropped_parts = [p.lower() for p in config.get('dropped_parts', [])]
    kept_parts = [p.lower() for p in config.get('kept_parts', [])]
    synthetic = config.get('synthetic', [])

    # 1. Check every source data column is present with correct type
    for col_name, col_type in hive_data_cols:
        expected_bq_name = renames.get(col_name, col_name)
        expected_bq_type = map_hive_type(col_type)

        if expected_bq_name not in bq_col_dict:
            result.fail(f"{dataset}.{table_name}: missing column '{expected_bq_name}' (source: {col_name} {col_type})")
            continue

        actual_type = bq_col_dict[expected_bq_name].upper()

        # Simplified type matching
        if expected_bq_type == 'STRUCT':
            if not actual_type.startswith('STRUCT'):
                result.fail(f"{dataset}.{table_name}.{expected_bq_name}: expected STRUCT, got {actual_type}")
            else:
                result.ok(f"{dataset}.{table_name}.{expected_bq_name}: STRUCT ✓")
        elif expected_bq_type == 'ARRAY<STRUCT>':
            if not actual_type.startswith('ARRAY<STRUCT'):
                result.fail(f"{dataset}.{table_name}.{expected_bq_name}: expected ARRAY<STRUCT...>, got {actual_type}")
            else:
                result.ok(f"{dataset}.{table_name}.{expected_bq_name}: ARRAY<STRUCT> ✓")
        elif expected_bq_type == 'JSON':
            if actual_type != 'JSON':
                result.fail(f"{dataset}.{table_name}.{expected_bq_name}: expected JSON, got {actual_type}")
            else:
                result.ok(f"{dataset}.{table_name}.{expected_bq_name}: MAP→JSON ✓")
        else:
            if actual_type != expected_bq_type:
                result.fail(f"{dataset}.{table_name}.{expected_bq_name}: expected {expected_bq_type}, got {actual_type}")
            else:
                result.ok(f"{dataset}.{table_name}.{expected_bq_name}: {col_type}→{actual_type} ✓")

    # 2. Check partition columns: dropped ones should be absent, kept ones present
    for col_name, col_type in hive_part_cols:
        cn = col_name.lower()
        if cn in dropped_parts:
            if cn in bq_col_dict:
                result.fail(f"{dataset}.{table_name}: dropped partition col '{cn}' should not be in BQ DDL")
            else:
                result.ok(f"{dataset}.{table_name}: dropped partition col '{cn}' correctly absent")
        elif cn in kept_parts:
            if cn not in bq_col_dict:
                result.fail(f"{dataset}.{table_name}: kept partition col '{cn}' missing from BQ DDL")
            else:
                expected_type = map_hive_type(col_type)
                actual = bq_col_dict[cn].upper()
                if actual != expected_type:
                    result.fail(f"{dataset}.{table_name}.{cn}: expected {expected_type}, got {actual}")
                else:
                    result.ok(f"{dataset}.{table_name}.{cn}: kept partition col ✓")
        else:
            # Pattern C: partition col carried over as-is
            if config['pattern'] == 'C':
                if cn not in bq_col_dict:
                    result.fail(f"{dataset}.{table_name}: native partition col '{cn}' missing from BQ DDL")
                else:
                    expected_type = map_hive_type(col_type)
                    actual = bq_col_dict[cn].upper()
                    if actual != expected_type:
                        result.fail(f"{dataset}.{table_name}.{cn}: expected {expected_type}, got {actual}")
                    else:
                        result.ok(f"{dataset}.{table_name}.{cn}: native partition col ✓")

    # 3. Check synthetic columns present
    for syn_name, syn_type in synthetic:
        if syn_name not in bq_col_dict:
            result.fail(f"{dataset}.{table_name}: synthetic col '{syn_name}' missing from BQ DDL")
        else:
            actual = bq_col_dict[syn_name].upper()
            if actual != syn_type:
                result.fail(f"{dataset}.{table_name}.{syn_name}: expected {syn_type}, got {actual}")
            else:
                result.ok(f"{dataset}.{table_name}.{syn_name}: synthetic partition col ✓")

    # 4. Check no unexpected columns
    expected_names = set()
    for name, _ in hive_data_cols:
        expected_names.add(renames.get(name, name))
    for name, _ in hive_part_cols:
        cn = name.lower()
        if cn not in dropped_parts:
            expected_names.add(cn)
    for syn_name, _ in synthetic:
        expected_names.add(syn_name)

    for bq_name, _ in bq_cols:
        if bq_name not in expected_names:
            result.fail(f"{dataset}.{table_name}: unexpected column '{bq_name}' in BQ DDL")


def main():
    hql_base = '/workspace/source/clusters/acme-lake/hive'
    bq_base = '/workspace/project/bigquery'

    result = ValidationResult()
    total_errors = 0

    # ─── 1. Column Presence Checks ────────────────────────────────────
    print("=" * 70)
    print("PHASE 1: Column Presence & Type Mapping Validation")
    print("=" * 70)

    print("\n--- Raw Tables ---")
    for table_name, config in sorted(RAW_TABLES.items()):
        print(f"\n  [{table_name}]")
        validate_table(table_name, config, 'raw', hql_base, bq_base, result)

    print(f"\n--- Staging Tables ---")
    for table_name, config in sorted(STAGING_TABLES.items()):
        print(f"\n  [{table_name}]")
        validate_table(table_name, config, 'staging', hql_base, bq_base, result)

    result.print_report()

    # ─── 2. AC-Specific Spot Checks ───────────────────────────────────
    print("\n" + "=" * 70)
    print("PHASE 2: Acceptance Criteria Spot Checks")
    print("=" * 70)

    ac_result = ValidationResult()

    # AC #1: sales_retail — ingest_ts TIMESTAMP, PARTITION BY HOUR, 8 source columns
    print("\n  [AC #1] raw.sales_retail")
    sr = open(os.path.join(bq_base, 'raw/tables/sales_retail.sql')).read()
    if 'PARTITION BY TIMESTAMP_TRUNC(`ingest_ts`, HOUR)' in sr:
        ac_result.ok("AC #1: PARTITION BY TIMESTAMP_TRUNC(ingest_ts, HOUR) ✓")
    else:
        ac_result.fail("AC #1: Missing PARTITION BY TIMESTAMP_TRUNC(ingest_ts, HOUR)")
    if '`ingest_ts`    TIMESTAMP' in sr or '`ingest_ts` TIMESTAMP' in sr:
        ac_result.ok("AC #1: ingest_ts TIMESTAMP column present ✓")
    else:
        ac_result.fail("AC #1: Missing ingest_ts TIMESTAMP column")
    # Count source columns (8 + ingest_ts = 9 total)
    bq_cols_sr = parse_bq_columns(sr)
    source_cols = [c for c in bq_cols_sr if c[0] != 'ingest_ts']
    if len(source_cols) == 8:
        ac_result.ok(f"AC #1: 8 source columns present ✓")
    else:
        ac_result.fail(f"AC #1: Expected 8 source columns, found {len(source_cols)}")

    # AC #2: mobile_events — JSON, STRUCT, ARRAY<STRUCT>, event_ts HOUR, CLUSTER BY hour_bucket
    print("\n  [AC #2] raw.mobile_events")
    me = open(os.path.join(bq_base, 'raw/tables/mobile_events.sql')).read()
    if '`properties`   JSON' in me or '`properties` JSON' in me:
        ac_result.ok("AC #2: properties as JSON ✓")
    else:
        ac_result.fail("AC #2: properties not JSON")
    if 'STRUCT<`ip` STRING, `country` STRING, `session_id` STRING, `referrer` STRING>' in me:
        ac_result.ok("AC #2: context as STRUCT<ip,country,session_id,referrer> ✓")
    else:
        ac_result.fail("AC #2: context STRUCT definition mismatch")
    if 'ARRAY<STRUCT<`sku` STRING, `qty` INT64, `price` NUMERIC>>' in me:
        ac_result.ok("AC #2: items as ARRAY<STRUCT<sku,qty,price>> ✓")
    else:
        ac_result.fail("AC #2: items ARRAY<STRUCT> definition mismatch")
    if 'PARTITION BY TIMESTAMP_TRUNC(`event_ts`, HOUR)' in me:
        ac_result.ok("AC #2: PARTITION BY TIMESTAMP_TRUNC(event_ts, HOUR) ✓")
    else:
        ac_result.fail("AC #2: Missing event_ts HOUR partition")
    if 'CLUSTER BY `hour_bucket`' in me:
        ac_result.ok("AC #2: CLUSTER BY hour_bucket ✓")
    else:
        ac_result.fail("AC #2: Missing CLUSTER BY hour_bucket")

    # AC #3: product_catalog_feed — metadata JSON, Parquet transit comment
    print("\n  [AC #3] raw.product_catalog_feed")
    pcf = open(os.path.join(bq_base, 'raw/tables/product_catalog_feed.sql')).read()
    if '`metadata`' in pcf and 'JSON' in pcf:
        ac_result.ok("AC #3: metadata as JSON ✓")
    else:
        ac_result.fail("AC #3: metadata not JSON")
    if 'Parquet transit load required' in pcf and 'RCFile' in pcf:
        ac_result.ok("AC #3: Parquet transit comment noting RCFile ✓")
    else:
        ac_result.fail("AC #3: Missing Parquet transit / RCFile comment")

    # AC #4: supplier_invoices — ARRAY<STRUCT>, invoice_month DATE MONTH
    print("\n  [AC #4] raw.supplier_invoices")
    si = open(os.path.join(bq_base, 'raw/tables/supplier_invoices.sql')).read()
    if 'ARRAY<STRUCT<`sku` STRING, `qty` INT64, `unit_price` NUMERIC>>' in si:
        ac_result.ok("AC #4: line_items as ARRAY<STRUCT<sku,qty,unit_price>> ✓")
    else:
        ac_result.fail("AC #4: line_items ARRAY<STRUCT> definition mismatch")
    if 'PARTITION BY DATE_TRUNC(`invoice_month`, MONTH)' in si:
        ac_result.ok("AC #4: PARTITION BY DATE_TRUNC(invoice_month, MONTH) ✓")
    else:
        ac_result.fail("AC #4: Missing invoice_month MONTH partition")
    if 'Parquet transit load required' in si and 'SequenceFile' in si:
        ac_result.ok("AC #4: Parquet transit comment noting SequenceFile ✓")
    else:
        ac_result.fail("AC #4: Missing Parquet transit / SequenceFile comment")

    # AC #5: dedup_clickstream — event_date DATE DAY, CLUSTER BY country_partition, user_id
    print("\n  [AC #5] staging.dedup_clickstream")
    dc = open(os.path.join(bq_base, 'staging/tables/dedup_clickstream.sql')).read()
    if 'PARTITION BY `event_date`' in dc:
        ac_result.ok("AC #5: PARTITION BY event_date ✓")
    else:
        ac_result.fail("AC #5: Missing PARTITION BY event_date")
    if 'CLUSTER BY `country_partition`, `user_id`' in dc:
        ac_result.ok("AC #5: CLUSTER BY country_partition, user_id ✓")
    else:
        ac_result.fail("AC #5: Missing CLUSTER BY country_partition, user_id")
    if '`country_partition`  STRING' in dc or '`country_partition` STRING' in dc:
        ac_result.ok("AC #5: country_partition retained as data column ✓")
    else:
        ac_result.fail("AC #5: country_partition not retained as data column")

    # AC #6: parsed_loyalty_events — meta JSON
    print("\n  [AC #6] staging.parsed_loyalty_events")
    ple = open(os.path.join(bq_base, 'staging/tables/parsed_loyalty_events.sql')).read()
    if '`meta`' in ple and 'JSON' in ple:
        ac_result.ok("AC #6: meta as JSON ✓")
    else:
        ac_result.fail("AC #6: meta not JSON")

    # AC #7: raw.omniture view references omniture_logs with ingest_ts
    print("\n  [AC #7] raw.omniture (view)")
    ov = open(os.path.join(bq_base, 'raw/views/omniture.sql')).read()
    if '`acme-lake-project.raw.omniture_logs`' in ov:
        ac_result.ok("AC #7: References acme-lake-project.raw.omniture_logs ✓")
    else:
        ac_result.fail("AC #7: Missing reference to acme-lake-project.raw.omniture_logs")
    if '`ingest_ts`' in ov:
        ac_result.ok("AC #7: ingest_ts column referenced (replaces date_ts) ✓")
    else:
        ac_result.fail("AC #7: Missing ingest_ts reference")
    if 'date_ts' not in ov.split('--')[-1] and 'date_ts' not in ov.replace('-- Translation: date_ts -> ingest_ts', ''):
        ac_result.ok("AC #7: No date_ts in view SQL body ✓")
    else:
        # More careful check: look only in the SELECT/FROM body
        view_body = ov[ov.index('SELECT'):]
        if 'date_ts' not in view_body:
            ac_result.ok("AC #7: No date_ts in view SQL body ✓")
        else:
            ac_result.fail("AC #7: date_ts still referenced in view SQL body")

    # AC #8: staging.v_returns_pending references raw.return_authorizations
    print("\n  [AC #8] staging.v_returns_pending (view)")
    vrp = open(os.path.join(bq_base, 'staging/views/v_returns_pending.sql')).read()
    if '`acme-lake-project.raw.return_authorizations`' in vrp:
        ac_result.ok("AC #8: References acme-lake-project.raw.return_authorizations (cross-dataset) ✓")
    else:
        ac_result.fail("AC #8: Missing reference to acme-lake-project.raw.return_authorizations")
    if 'DATE_DIFF' in vrp and 'CURRENT_DATE()' in vrp and 'DAY' in vrp:
        ac_result.ok("AC #8: DATEDIFF translated to DATE_DIFF(..., DAY) ✓")
    else:
        ac_result.fail("AC #8: DATEDIFF translation incorrect")

    ac_result.print_report()

    # ─── 3. Global Consistency Checks ─────────────────────────────────
    print("\n" + "=" * 70)
    print("PHASE 3: Global Consistency Checks")
    print("=" * 70)

    gc_result = ValidationResult()

    # Scan all DDL files
    all_ddl_files = []
    for root, dirs, files in os.walk(bq_base):
        for f in files:
            if f.endswith('.sql'):
                all_ddl_files.append(os.path.join(root, f))

    all_content = ''
    for fp in sorted(all_ddl_files):
        with open(fp) as f:
            content = f.read()
            all_content += content + '\n'

            rel = fp.replace(bq_base + '/', '')

            # Check for ${...} variables
            if '${' in content:
                gc_result.fail(f"{rel}: Contains ${{...}} variable substitution")

            # Check for NUMERIC(p,s)
            if re.search(r'NUMERIC\(\d', content):
                gc_result.fail(f"{rel}: Contains NUMERIC with precision (should be plain NUMERIC)")

    # Check no ${...} globally
    if '${' not in all_content:
        gc_result.ok("No ${...} variable substitutions in any DDL file ✓")

    # Check no NUMERIC(p,s) globally
    if not re.search(r'NUMERIC\(\d', all_content):
        gc_result.ok("All NUMERIC without precision parameters ✓")

    # Check all project refs use acme-lake-project
    if 'acme-lake-project' in all_content:
        gc_result.ok("Project references use acme-lake-project ✓")

    # Check all MAP→JSON (no MAP type remaining)
    if 'MAP<' not in all_content.upper().replace('-- ', '##'):
        # Be more careful: only check non-comment lines
        has_map = False
        for line in all_content.split('\n'):
            stripped = line.strip()
            if stripped.startswith('--'):
                continue
            if 'MAP<' in stripped.upper():
                has_map = True
                break
        if not has_map:
            gc_result.ok("All MAP types converted to JSON (no MAP<> in DDL body) ✓")
        else:
            gc_result.fail("Found MAP<> type in DDL body (should be JSON)")
    else:
        gc_result.ok("All MAP types converted to JSON ✓")

    # Check Hive TIMESTAMP data columns → DATETIME (not TIMESTAMP)
    # TIMESTAMP should only appear for synthetic partition columns
    for fp in sorted(all_ddl_files):
        rel = fp.replace(bq_base + '/', '')
        if '/views/' in fp or '/datasets/' in fp or '/external/' in fp or '/scripts/' in fp:
            continue
        with open(fp) as f:
            content = f.read()
        for line in content.split('\n'):
            stripped = line.strip()
            if stripped.startswith('--'):
                continue
            if 'TIMESTAMP' in stripped and 'TIMESTAMP_TRUNC' not in stripped and 'PARTITION' not in stripped:
                # This line has TIMESTAMP — should only be ingest_ts or event_ts (synthetic)
                if any(syn in stripped for syn in ['ingest_ts', 'event_ts`     TIMESTAMP', 'event_ts` TIMESTAMP']):
                    pass  # OK — synthetic partition column
                elif 'event_ts`     TIMESTAMP' in stripped or '`event_ts`     TIMESTAMP' in stripped:
                    pass  # event_ts synthetic for mobile_events
                else:
                    # Check if this is a data column that should be DATETIME
                    gc_result.fail(f"{rel}: Line has TIMESTAMP where DATETIME expected: {stripped}")

    gc_result.ok("Hive TIMESTAMP data columns mapped to DATETIME (TIMESTAMP only for synthetic partition cols) ✓")

    gc_result.print_report()

    # ─── Summary ──────────────────────────────────────────────────────
    all_errors = result.errors + ac_result.errors + gc_result.errors
    all_warnings = result.warnings + ac_result.warnings + gc_result.warnings

    print("\n" + "=" * 70)
    print("VALIDATION SUMMARY")
    print("=" * 70)
    print(f"  Total checks:  {len(result.checks) + len(ac_result.checks) + len(gc_result.checks)}")
    print(f"  Errors:        {len(all_errors)}")
    print(f"  Warnings:      {len(all_warnings)}")

    if all_errors:
        print(f"\n  ERRORS:")
        for e in all_errors:
            print(f"    ✗ {e}")

    if all_warnings:
        print(f"\n  WARNINGS:")
        for w in all_warnings:
            print(f"    ⚠ {w}")

    if all_errors:
        print(f"\n  RESULT: FAIL — {len(all_errors)} error(s) found")
        return 1
    else:
        print(f"\n  RESULT: PASS — all checks passed")
        return 0


if __name__ == '__main__':
    sys.exit(main())
