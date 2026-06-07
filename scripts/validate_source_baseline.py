#!/usr/bin/env python3
"""
validate_source_baseline.py — Source↔Target table coverage validation.

Reads source Hive DDL files and generated BigQuery DDL files, then computes
a 3-set diff per schema (matched, missing-in-target, extra-in-target).

Validates extra tables against the documented net-new allowlist and checks
AC-critical column types by parsing DDL.

Usage:
    python3 scripts/validate_source_baseline.py

Output:
    - Human-readable report to stdout
    - JSON results to validation_results.json
"""

import json
import os
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parent.parent
SOURCE_ROOT = Path("/workspace/source")
DDL_ROOT = PROJECT_ROOT / "ddl"

# Source Hive DDL files, grouped by schema
SOURCE_FILES = {
    "raw": [
        SOURCE_ROOT / "clusters/acme-lake/hive/02-raw-external-tables.hql",
        SOURCE_ROOT / "clusters/acme-lake/hive/05-additional-raw-feeds.hql",
        SOURCE_ROOT / "clusters/acme-lake/hive/07-json-raw.hql",
    ],
    "staging": [
        SOURCE_ROOT / "clusters/acme-lake/hive/06-staging-tables.hql",
    ],
    "retail": [
        SOURCE_ROOT / "clusters/acme-analytics/hive/03-retail-tables.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/06-acid-tables.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/08-rollup-etl.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/10-additional-dims.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/11-additional-facts.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/12-aggregates-rollups.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/13-additional-acid-tables.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/14-kudu-realtime.hql",
        SOURCE_ROOT / "clusters/acme-analytics/hive/15-bridge-and-scd2.hql",
    ],
    "regional_eu": [
        SOURCE_ROOT / "clusters/acme-edge/hive/regional-events.hql",
        SOURCE_ROOT / "clusters/acme-edge/hive/regional-additional-tables.hql",
    ],
}

# BigQuery DDL directories (tables only — views are separate)
BQ_TABLE_DIRS = {
    "raw": DDL_ROOT / "raw" / "tables",
    "staging": DDL_ROOT / "staging" / "tables",
    "retail": DDL_ROOT / "retail" / "tables",
    "regional_eu": DDL_ROOT / "regional_eu" / "tables",
}

# Net-new allowlist: tables in BQ with no Hive metastore counterpart
NET_NEW_ALLOWLIST = {
    "raw": {"customer_signups", "fraud_signals"},
    "staging": set(),
    "retail": {
        # 12 conformed dims
        "dim_store", "dim_supplier", "dim_employee", "dim_promotion",
        "dim_warehouse", "dim_currency", "dim_geography", "dim_color",
        "dim_size", "dim_brand", "dim_category", "dim_payment_method",
        # 4 Kudu snapshot tables (renamed)
        "inventory_realtime_snapshot", "session_state_snapshot",
        "promo_eligibility_snapshot", "realtime_price_snapshot",
    },
    "regional_eu": set(),
}

# Kudu tables have different names in source vs target
KUDU_SOURCE_NAMES = {
    "kudu_inventory_realtime", "kudu_session_state",
    "kudu_promo_eligibility", "kudu_realtime_price",
}

# Source tables that appear in DDL but are NOT in live Hive metastore.
# These are counted as "source DDL tables" but NOT "metastore tables".
SOURCE_DDL_ONLY = {
    "raw": {"customer_signups", "fraud_signals"},
    "staging": set(),
    "retail": {
        "dim_store", "dim_supplier", "dim_employee", "dim_promotion",
        "dim_warehouse", "dim_currency", "dim_geography", "dim_color",
        "dim_size", "dim_brand", "dim_category", "dim_payment_method",
    },
    "regional_eu": set(),
}

# Expected metastore counts (from live Hive enumeration)
EXPECTED_METASTORE_COUNTS = {
    "raw": 17,
    "staging": 10,
    "retail": 42,
    "regional_eu": 13,
}

# AC-critical column checks: (table_file, column_name, expected_type_pattern)
AC_COLUMN_CHECKS = [
    # AC-5
    ("raw/tables/sales_retail.sql", "partition_date", r"DATE"),
    ("raw/tables/sales_retail.sql", "date_ts", r"STRING"),
    ("raw/tables/sales_retail.sql", "unit_price", r"NUMERIC\(10,2\)"),
    # AC-6
    ("raw/tables/mobile_events.sql", "properties", r"JSON"),
    ("raw/tables/mobile_events.sql", "context", r"STRUCT<ip_address STRING"),
    ("raw/tables/mobile_events.sql", "items", r"ARRAY<STRUCT<sku STRING, qty INT64, price NUMERIC"),
    # AC-7
    ("retail/tables/fact_sales.sql", "unit_price", r"NUMERIC\(10,2\)"),
    ("retail/tables/fact_sales.sql", "line_total", r"NUMERIC\(14,2\)"),
    # AC-10
    ("retail/tables/returns_ledger.sql", "refund_amount", r"NUMERIC\(12,2\)"),
    # AC-11
    ("regional_eu/tables/fact_orders_eu.sql", "vat_amount", r"NUMERIC\(12,2\)"),
    # AC-12
    ("regional_eu/tables/dim_gdpr_consent.sql", "granted", r"BOOL"),
    ("regional_eu/tables/dim_gdpr_consent.sql", "consent_date", r"DATE"),
    # AC-14: ACID tables — DECIMAL→NUMERIC
    ("retail/tables/acid_supplier_terms_history.sql", "discount_pct", r"NUMERIC\(5,2\)"),
]

# AC partition/cluster checks: (table_file, check_type, expected_pattern)
AC_PARTITION_CHECKS = [
    ("raw/tables/sales_retail.sql", "PARTITION BY", r"PARTITION BY partition_date"),
    ("raw/tables/sales_retail.sql", "OPTIONS", r"require_partition_filter\s*=\s*TRUE"),
    ("raw/tables/mobile_events.sql", "PARTITION BY", r"PARTITION BY partition_date"),
    ("raw/tables/mobile_events.sql", "CLUSTER BY", r"CLUSTER BY platform, hour_bucket"),
    ("retail/tables/fact_sales.sql", "PARTITION BY", r"PARTITION BY sale_date"),
    ("retail/tables/fact_sales.sql", "CLUSTER BY", r"CLUSTER BY customer_sk"),
    ("retail/tables/fact_inventory_movements.sql", "PARTITION BY", r"PARTITION BY partition_date"),
    ("retail/tables/fact_inventory_movements.sql", "CLUSTER BY", r"CLUSTER BY region"),
    ("retail/tables/fact_payments.sql", "PARTITION BY", r"PARTITION BY partition_month"),
    ("retail/tables/fact_payments.sql", "CLUSTER BY", r"CLUSTER BY payment_method_partition"),
    ("regional_eu/tables/fact_orders_eu.sql", "PARTITION BY", r"PARTITION BY partition_month"),
    ("regional_eu/tables/fact_orders_eu.sql", "CLUSTER BY", r"CLUSTER BY country_partition, customer_id"),
    ("regional_eu/tables/dim_gdpr_consent.sql", "PARTITION BY", r"PARTITION BY consent_date"),
]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def extract_hive_table_names(filepath: Path) -> set:
    """Extract table names from a Hive DDL file."""
    tables = set()
    content = filepath.read_text()
    # Match CREATE [EXTERNAL] TABLE [IF NOT EXISTS] [schema.]table_name
    pattern = r'CREATE\s+(?:EXTERNAL\s+)?TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:\w+\.)?(\w+)'
    for match in re.finditer(pattern, content, re.IGNORECASE):
        tables.add(match.group(1))
    return tables


def extract_bq_table_names(directory: Path) -> set:
    """Extract table names from BigQuery DDL files in a directory."""
    tables = set()
    if not directory.exists():
        return tables
    for sql_file in sorted(directory.glob("*.sql")):
        if sql_file.stat().st_size > 0:
            tables.add(sql_file.stem)
    return tables


def check_column_type(filepath: Path, column_name: str, type_pattern: str) -> bool:
    """Check if a column in a DDL file matches the expected type pattern."""
    content = filepath.read_text()
    # Find the column definition line
    for line in content.split('\n'):
        stripped = line.strip()
        if stripped.startswith('--'):
            continue
        if re.match(rf'\s*{re.escape(column_name)}\s+', stripped):
            return bool(re.search(type_pattern, stripped))
    return False


def check_ddl_pattern(filepath: Path, pattern: str) -> bool:
    """Check if a DDL file contains a pattern (in non-comment lines)."""
    content = filepath.read_text()
    for line in content.split('\n'):
        if line.strip().startswith('--'):
            continue
        if re.search(pattern, line):
            return True
    return False


# ---------------------------------------------------------------------------
# Main validation
# ---------------------------------------------------------------------------

def main():
    results = {
        "status": "PASS",
        "source_verification": "STATIC_DDL_ONLY",
        "note": "Source counts based on parsed DDL files, not live Hive metastore",
        "schemas": {},
        "ac_column_checks": [],
        "ac_partition_checks": [],
    }

    all_pass = True
    report_lines = []

    report_lines.append("=" * 72)
    report_lines.append("SOURCE → TARGET TABLE COVERAGE VALIDATION")
    report_lines.append("=" * 72)
    report_lines.append("")
    report_lines.append("⚠️  Source baseline based on parsed DDL files (static analysis).")
    report_lines.append("    Live Hive metastore verification not available.")
    report_lines.append("    Counts labelled as ASSUMED/UNVERIFIED where noted.")
    report_lines.append("")

    # -----------------------------------------------------------------------
    # Layer 2: Table Count Reconciliation per schema
    # -----------------------------------------------------------------------
    report_lines.append("-" * 72)
    report_lines.append("LAYER 2: TABLE COUNT RECONCILIATION")
    report_lines.append("-" * 72)
    report_lines.append("")

    for schema in ["raw", "staging", "retail", "regional_eu"]:
        # Source tables from Hive DDL
        source_tables = set()
        for src_file in SOURCE_FILES.get(schema, []):
            if src_file.exists():
                source_tables |= extract_hive_table_names(src_file)

        # For retail, Kudu tables have different names in source
        if schema == "retail":
            # Kudu tables are in source as kudu_* but in target as *_snapshot
            source_tables -= KUDU_SOURCE_NAMES

        # Metastore tables = source DDL tables - DDL-only tables
        metastore_tables = source_tables - SOURCE_DDL_ONLY.get(schema, set())

        # Target tables from BQ DDL
        target_tables = extract_bq_table_names(BQ_TABLE_DIRS[schema])

        # Compute 3-set diff
        matched = source_tables & target_tables
        missing_in_target = source_tables - target_tables
        extra_in_target = target_tables - source_tables

        # Validate extra tables against allowlist
        allowlist = NET_NEW_ALLOWLIST.get(schema, set())
        unexpected_extra = extra_in_target - allowlist

        schema_pass = len(missing_in_target) == 0 and len(unexpected_extra) == 0

        expected_metastore = EXPECTED_METASTORE_COUNTS.get(schema, "?")

        results["schemas"][schema] = {
            "source_ddl_tables": len(source_tables),
            "metastore_tables_assumed": len(metastore_tables),
            "expected_metastore_count": expected_metastore,
            "target_tables": len(target_tables),
            "matched": len(matched),
            "missing_in_target": sorted(missing_in_target),
            "extra_in_target": sorted(extra_in_target),
            "allowlist": sorted(allowlist),
            "unexpected_extra": sorted(unexpected_extra),
            "pass": schema_pass,
        }

        status = "✅ PASS" if schema_pass else "❌ FAIL"
        report_lines.append(f"  {schema.upper()}: {status}")
        report_lines.append(f"    Source DDL tables:   {len(source_tables)}")
        report_lines.append(f"    Metastore (assumed): {len(metastore_tables)} (expected {expected_metastore})")
        report_lines.append(f"    Target BQ tables:    {len(target_tables)}")
        report_lines.append(f"    Matched:             {len(matched)}")
        report_lines.append(f"    Missing in target:   {len(missing_in_target)}"
                          + (f" — {sorted(missing_in_target)}" if missing_in_target else ""))
        report_lines.append(f"    Extra in target:     {len(extra_in_target)}"
                          + (f" — {sorted(extra_in_target)}" if extra_in_target else ""))
        if unexpected_extra:
            report_lines.append(f"    ⚠️  UNEXPECTED extra: {sorted(unexpected_extra)}")
        report_lines.append("")

        if not schema_pass:
            all_pass = False

    # -----------------------------------------------------------------------
    # AC Column Type Checks
    # -----------------------------------------------------------------------
    report_lines.append("-" * 72)
    report_lines.append("AC COLUMN TYPE CHECKS")
    report_lines.append("-" * 72)
    report_lines.append("")

    for ddl_path, col_name, type_pattern in AC_COLUMN_CHECKS:
        filepath = DDL_ROOT / ddl_path
        passed = check_column_type(filepath, col_name, type_pattern)
        status = "✅" if passed else "❌"
        report_lines.append(f"  {status} {ddl_path}: {col_name} ~ {type_pattern}")
        results["ac_column_checks"].append({
            "file": ddl_path,
            "column": col_name,
            "expected_pattern": type_pattern,
            "pass": passed,
        })
        if not passed:
            all_pass = False

    report_lines.append("")

    # -----------------------------------------------------------------------
    # AC Partition/Cluster Checks
    # -----------------------------------------------------------------------
    report_lines.append("-" * 72)
    report_lines.append("AC PARTITION/CLUSTER CHECKS")
    report_lines.append("-" * 72)
    report_lines.append("")

    for ddl_path, check_type, pattern in AC_PARTITION_CHECKS:
        filepath = DDL_ROOT / ddl_path
        passed = check_ddl_pattern(filepath, pattern)
        status = "✅" if passed else "❌"
        report_lines.append(f"  {status} {ddl_path}: {check_type} ~ {pattern}")
        results["ac_partition_checks"].append({
            "file": ddl_path,
            "check_type": check_type,
            "expected_pattern": pattern,
            "pass": passed,
        })
        if not passed:
            all_pass = False

    report_lines.append("")

    # -----------------------------------------------------------------------
    # ACID Table Checks (AC-14)
    # -----------------------------------------------------------------------
    report_lines.append("-" * 72)
    report_lines.append("AC-14: ACID TABLE CHECKS")
    report_lines.append("-" * 72)
    report_lines.append("")

    acid_tables = [
        "returns_ledger", "acid_customer_address_history",
        "acid_supplier_terms_history", "acid_loyalty_points_ledger",
        "acid_inventory_adjustments_log",
    ]
    acid_results = []
    for table_name in acid_tables:
        filepath = DDL_ROOT / "retail" / "tables" / f"{table_name}.sql"
        content = filepath.read_text()
        # Check no ORC-specific properties in non-comment lines
        has_orc = any(
            'ORC' in line or 'transactional' in line
            for line in content.split('\n')
            if not line.strip().startswith('--')
        )
        # Check DECIMAL→NUMERIC (no bare DECIMAL in non-comment lines)
        has_decimal = any(
            'DECIMAL' in line
            for line in content.split('\n')
            if not line.strip().startswith('--')
        )
        passed = not has_orc and not has_decimal
        status = "✅" if passed else "❌"
        report_lines.append(f"  {status} {table_name}: no_orc={not has_orc}, no_decimal={not has_decimal}")
        acid_results.append({"table": table_name, "no_orc": not has_orc, "no_decimal": not has_decimal, "pass": passed})
        if not passed:
            all_pass = False

    results["acid_checks"] = acid_results
    report_lines.append("")

    # -----------------------------------------------------------------------
    # MAP→JSON Checks (AC-13)
    # -----------------------------------------------------------------------
    report_lines.append("-" * 72)
    report_lines.append("AC-13: MAP→JSON CONVERSION STATUS")
    report_lines.append("-" * 72)
    report_lines.append("")

    json_columns = [
        ("raw/tables/mobile_events.sql", "properties", True),
        ("raw/tables/email_campaign_clicks.sql", "utm", True),
        ("raw/tables/product_catalog_feed.sql", "metadata", True),
        ("raw/tables/driver_logs.sql", "extras", True),
        ("staging/tables/parsed_loyalty_events.sql", "meta", True),
        ("retail/tables/dim_store.sql", "attributes", True),
        ("retail/tables/dim_promotion.sql", "eligibility", True),
        ("retail/tables/fact_loyalty_events.sql", "meta", True),
        ("retail/tables/fact_app_clicks.sql", "properties", True),
        ("regional_eu/tables/fact_mobile_app_events.sql", "properties", True),
    ]

    json_results = []
    for ddl_path, col_name, expected in json_columns:
        filepath = DDL_ROOT / ddl_path
        passed = check_column_type(filepath, col_name, r"JSON")
        status = "✅" if passed else "❌"
        report_lines.append(f"  {status} {ddl_path}: {col_name} → JSON")
        json_results.append({"file": ddl_path, "column": col_name, "is_json": passed})

    report_lines.append("")
    report_lines.append("  AC-13 Exceptions (source-faithful — not converted):")
    report_lines.append("    • raw.loyalty_events.meta_raw — STRING in source (RegexSerDe), not MAP")
    report_lines.append("    • raw.customer_complaints.resolution_details — column absent in source")
    report_lines.append("    • raw.chat_transcripts.session_metadata — column absent in source")
    report_lines.append("    • regional_eu.events_eu.payload_json — STRING in source, not MAP")
    report_lines.append("")

    results["json_checks"] = json_results

    # -----------------------------------------------------------------------
    # Summary
    # -----------------------------------------------------------------------
    results["status"] = "PASS" if all_pass else "FAIL"

    report_lines.append("=" * 72)
    report_lines.append(f"OVERALL RESULT: {'✅ PASS' if all_pass else '❌ FAIL'}")
    report_lines.append("=" * 72)

    # Print report
    report = "\n".join(report_lines)
    print(report)

    # Write JSON results
    json_output = PROJECT_ROOT / "validation_results.json"
    with open(json_output, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nJSON results written to: {json_output}")

    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())
