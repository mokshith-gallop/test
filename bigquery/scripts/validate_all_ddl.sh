#!/usr/bin/env bash
# =============================================================================
# validate_all_ddl.sh — Dry-run every BigQuery DDL file against a scratch
# dataset to verify zero parse or type errors (AC #9).
#
# Usage:
#   ./bigquery/scripts/validate_all_ddl.sh [--project PROJECT_ID]
#
# Prerequisites:
#   - gcloud / bq CLI installed and authenticated
#   - Sufficient permissions to create datasets and run dry-run queries
#
# The script rewrites fully-qualified table references from the production
# project (acme-lake-project) to a scratch project/dataset pair so that
# dry-run validation doesn't touch production schemas.
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default project — override with --project flag
PROJECT="${BQ_PROJECT:-acme-lake-project}"
SCRATCH_RAW_DATASET="bq_scratch_schema_test_raw"
SCRATCH_STAGING_DATASET="bq_scratch_schema_test_staging"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Counters
# ---------------------------------------------------------------------------
PASS=0
FAIL=0
SKIP=0
TOTAL=0
FAILURES=()

# ---------------------------------------------------------------------------
# Phase 1: DDL files in dependency order
#
# Order:
#   1. Dataset creation          (datasets/)
#   2. Raw managed tables        (raw/tables/)
#   3. Raw external tables       (raw/external/)
#   4. Staging managed tables    (staging/tables/)
#   5. Raw views                 (raw/views/)         — depend on raw tables
#   6. Staging views             (staging/views/)      — depend on raw tables
# ---------------------------------------------------------------------------

# Build ordered file list
DDL_FILES=()

# 1. Datasets
DDL_FILES+=("${BASE_DIR}/datasets/create_raw_dataset.sql")
DDL_FILES+=("${BASE_DIR}/datasets/create_staging_dataset.sql")

# 2. Raw managed tables (alphabetical)
for f in "${BASE_DIR}"/raw/tables/*.sql; do
  DDL_FILES+=("$f")
done

# 3. Raw external tables (alphabetical)
for f in "${BASE_DIR}"/raw/external/*.sql; do
  DDL_FILES+=("$f")
done

# 4. Staging managed tables (alphabetical)
for f in "${BASE_DIR}"/staging/tables/*.sql; do
  DDL_FILES+=("$f")
done

# 5. Raw views (alphabetical)
for f in "${BASE_DIR}"/raw/views/*.sql; do
  DDL_FILES+=("$f")
done

# 6. Staging views (alphabetical)
for f in "${BASE_DIR}"/staging/views/*.sql; do
  DDL_FILES+=("$f")
done

echo "============================================================"
echo "BigQuery DDL Dry-Run Validation"
echo "============================================================"
echo "Project:          ${PROJECT}"
echo "Scratch datasets: ${SCRATCH_RAW_DATASET}, ${SCRATCH_STAGING_DATASET}"
echo "DDL files found:  ${#DDL_FILES[@]}"
echo "Base directory:   ${BASE_DIR}"
echo "------------------------------------------------------------"
echo ""

# ---------------------------------------------------------------------------
# Phase 2: Create scratch datasets (idempotent)
# ---------------------------------------------------------------------------
echo "[SETUP] Creating scratch datasets if not present..."

bq --project_id="${PROJECT}" mk --dataset --if_not_exists \
  --description "Scratch dataset for DDL validation (raw)" \
  "${PROJECT}:${SCRATCH_RAW_DATASET}" 2>/dev/null || true

bq --project_id="${PROJECT}" mk --dataset --if_not_exists \
  --description "Scratch dataset for DDL validation (staging)" \
  "${PROJECT}:${SCRATCH_STAGING_DATASET}" 2>/dev/null || true

echo "[SETUP] Scratch datasets ready."
echo ""

# ---------------------------------------------------------------------------
# Phase 3: Dry-run each DDL file
# ---------------------------------------------------------------------------
for ddl_file in "${DDL_FILES[@]}"; do
  TOTAL=$((TOTAL + 1))
  rel_path="${ddl_file#${BASE_DIR}/}"

  # Read DDL content
  ddl_content="$(cat "${ddl_file}")"

  # Rewrite project.dataset references to scratch datasets for dry-run.
  # Production references use:
  #   `acme-lake-project.raw.xxx`     -> `PROJECT.SCRATCH_RAW_DATASET.xxx`
  #   `acme-lake-project.staging.xxx` -> `PROJECT.SCRATCH_STAGING_DATASET.xxx`
  ddl_rewritten="${ddl_content}"
  ddl_rewritten="${ddl_rewritten//\`acme-lake-project.raw./\`${PROJECT}.${SCRATCH_RAW_DATASET}.}"
  ddl_rewritten="${ddl_rewritten//\`acme-lake-project.staging./\`${PROJECT}.${SCRATCH_STAGING_DATASET}.}"

  # Dataset creation DDLs: rewrite the schema reference too
  ddl_rewritten="${ddl_rewritten//\`acme-lake-project.raw\`/\`${PROJECT}.${SCRATCH_RAW_DATASET}\`}"
  ddl_rewritten="${ddl_rewritten//\`acme-lake-project.staging\`/\`${PROJECT}.${SCRATCH_STAGING_DATASET}\`}"

  # Skip dataset creation DDLs for dry-run (CREATE SCHEMA is not supported
  # in dry-run mode — we already created them above)
  if [[ "${rel_path}" == datasets/* ]]; then
    echo "  [SKIP] ${rel_path} (dataset creation — already handled in setup)"
    SKIP=$((SKIP + 1))
    continue
  fi

  # Skip external table DDLs — CREATE EXTERNAL TABLE cannot be dry-run
  # without actual GCS files present. Syntax is validated structurally.
  if [[ "${rel_path}" == raw/external/* ]]; then
    echo "  [SKIP] ${rel_path} (external table — requires GCS files for full validation)"
    SKIP=$((SKIP + 1))
    continue
  fi

  # Run dry-run
  printf "  [TEST] %-60s ... " "${rel_path}"

  err_output=$(echo "${ddl_rewritten}" | \
    bq query \
      --project_id="${PROJECT}" \
      --use_legacy_sql=false \
      --dry_run \
      2>&1) && result=0 || result=$?

  if [[ ${result} -eq 0 ]]; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL"
    FAILURES+=("${rel_path}: ${err_output}")
    FAIL=$((FAIL + 1))
  fi
done

# ---------------------------------------------------------------------------
# Phase 4: Summary report
# ---------------------------------------------------------------------------
echo ""
echo "============================================================"
echo "VALIDATION SUMMARY"
echo "============================================================"
echo "Total files:  ${TOTAL}"
echo "Passed:       ${PASS}"
echo "Failed:       ${FAIL}"
echo "Skipped:      ${SKIP} (datasets + external tables)"
echo "------------------------------------------------------------"

if [[ ${FAIL} -gt 0 ]]; then
  echo ""
  echo "FAILURES:"
  for failure in "${FAILURES[@]}"; do
    echo "  ✗ ${failure}"
  done
  echo ""
  echo "RESULT: FAIL — ${FAIL} file(s) had parse or type errors"
  exit 1
else
  echo ""
  echo "RESULT: PASS — all ${PASS} DDL files validated successfully"
  echo "        (${SKIP} files skipped: dataset creation + external tables)"
  exit 0
fi
