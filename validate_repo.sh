#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

quick_mode=0
for arg in "$@"; do
  case "$arg" in
    --quick) quick_mode=1 ;;
    -h|--help)
      cat <<'USAGE'
Usage: ./validate_repo.sh [--quick]

Validates repository structure, docs scaffolding, lab/ticket coverage, and syntax checks.
Does not require all intentionally failing labs/tests to pass.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

failures=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; failures=$((failures+1)); }
warn() { echo "WARN: $1"; }

check_file() { [[ -f "$1" ]] && pass "$1 present" || fail "$1 present"; }
check_dir() { [[ -d "$1" ]] && pass "$1 present" || fail "$1 present"; }

echo "Repository Validation"
check_file README.md
check_file AUTHOR.md
check_file LICENSE
check_file Makefile
check_file pyproject.toml
check_file requirements.in
check_file requirements.txt
check_file run_course.sh
check_file validate_repo.sh

check_dir docs
check_file docs/README.md
check_file docs/PROJECT_MANUAL.md
check_file docs/CORE_CONCEPTS.md
check_file docs/OFFLINE_INDEX.md
check_file docs/LESSON_EXECUTION_COMPANION.md
check_file docs/LESSON_RESEARCH_ANALYSIS_COMPANION.md
check_file docs/REPOSITORY_STATUS_REPORT.md
check_file docs/CV_READY_SUMMARY.md
check_file docs/PORTFOLIO_SKILL_MAPPING.md

check_dir labs
check_dir incidents
check_dir src
check_dir tests
check_dir theory
check_dir cheatsheets
check_dir .github/workflows

if python3 - <<'PY'
from pathlib import Path
import sys

labs = sorted([p for p in Path("labs").glob("lab*") if p.is_dir()])
if len(labs) < 6:
    print(f"Expected >=6 labs, found {len(labs)}")
    sys.exit(1)
for lab in labs:
    for name in ("README.md", "ticket.md"):
        if not (lab / name).exists():
            print(f"Missing {name} in {lab}")
            sys.exit(1)
print(f"Validated {len(labs)} labs with README.md and ticket.md")
PY
then
  pass "Lab documentation structure"
else
  fail "Lab documentation structure"
fi

if python3 - <<'PY'
from pathlib import Path
import sys

tests = sorted(Path("tests/failing_tests").glob("test_*.py"))
if len(tests) < 6:
    print(f"Expected >=6 failing test scenarios, found {len(tests)}")
    sys.exit(1)
print(f"Failing test scenarios present: {len(tests)}")
PY
then
  pass "Failing test scenario coverage"
else
  fail "Failing test scenario coverage"
fi

if command -v rg >/dev/null 2>&1; then
  if rg -n "TODO|TBD|FIXME|PLACEHOLDER|REPLACE_WITH_|lorem ipsum" . \
    --glob '!**/.git/**' \
    --glob '!**/.venv/**' \
    --glob '!**/.pytest_cache/**' \
    --glob '!validate_repo.sh' \
    --glob '!.github/workflows/**' >/tmp/geneva_debug_placeholders.out; then
    cat /tmp/geneva_debug_placeholders.out
    fail "No placeholder/template markers remain"
  else
    pass "No placeholder/template markers remain"
  fi
else
  warn "Placeholder scan skipped (rg not installed)"
fi
rm -f /tmp/geneva_debug_placeholders.out

shell_failed=0
while IFS= read -r -d '' f; do
  if ! bash -n "$f"; then
    echo "Syntax error: $f"
    shell_failed=1
  fi
done < <(find . -type f -name '*.sh' \
  -not -path './.git/*' \
  -not -path './.venv/*' -print0)
bash -n validate_repo.sh || shell_failed=1
[[ $shell_failed -eq 0 ]] && pass "Shell syntax checks" || fail "Shell syntax checks"

py_failed=0
pycache_tmp=""
cleanup_pycache_tmp() {
  if [[ -n "${pycache_tmp:-}" && -d "${pycache_tmp:-}" ]]; then
    rm -rf "$pycache_tmp"
  fi
}
trap cleanup_pycache_tmp EXIT
while IFS= read -r -d '' pyf; do
  pycache_tmp="$(mktemp -d)"
  if ! PYTHONPYCACHEPREFIX="$pycache_tmp" python3 -m py_compile "$pyf" >/dev/null 2>&1; then
    echo "Python syntax error: $pyf"
    py_failed=1
  fi
  rm -rf "$pycache_tmp"
  pycache_tmp=""
done < <(find src tests labs -type f -name '*.py' -print0 2>/dev/null)
[[ $py_failed -eq 0 ]] && pass "Python syntax checks" || fail "Python syntax checks"

if python3 -m pytest --collect-only -q >/tmp/geneva_debug_pytest_collect.out 2>&1; then
  pass "Pytest collection (expected failing scenarios collected)"
else
  cat /tmp/geneva_debug_pytest_collect.out
  warn "Pytest collection failed (environment/deps issue) - not blocking"
fi
rm -f /tmp/geneva_debug_pytest_collect.out

warn "Intentional failing tests are not executed as a pass/fail gate in this validator"

if [[ $quick_mode -eq 0 ]]; then
  echo
  echo "Repository Metrics"
  python3 - <<'PY'
from pathlib import Path
repo = Path(".")
print(f"labs={sum(1 for p in (repo/'labs').glob('lab*') if p.is_dir())}")
print(f"incidents={sum(1 for _ in (repo/'incidents').rglob('*.md'))}")
print(f"theory_docs={sum(1 for _ in (repo/'theory').glob('*.md'))}")
print(f"failing_tests={sum(1 for _ in (repo/'tests'/'failing_tests').glob('test_*.py'))}")
PY
fi

if [[ $failures -ne 0 ]]; then
  echo "Validation failed with $failures issue(s)." >&2
  exit 1
fi

echo "Validation passed."
