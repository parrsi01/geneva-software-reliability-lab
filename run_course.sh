#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="interactive"
RESET=0
START_LAB=""
AUTO_YES=0

STATE_DIR="$SCRIPT_DIR/.course_state"
STATE_FILE="$STATE_DIR/state.env"
PROGRESS_LOG="$SCRIPT_DIR/progress.log"
ARTIFACT_DIR="$SCRIPT_DIR/artifacts"
CERT_FILE=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LAB_IDS=(
  "lab1_runtime_crash"
  "lab2_memory_leak"
  "lab3_race_condition"
  "lab4_api_failure"
  "lab5_ci_pipeline_break"
  "lab6_container_crashloop"
)

log() {
  local level="$1"
  shift
  printf "%b[%s]%b %s\n" "$CYAN" "$level" "$NC" "$*"
}

log_file() {
  mkdir -p "$STATE_DIR"
  printf "%s | %s | %s\n" "$(date -Is)" "$1" "$2" >> "$PROGRESS_LOG"
}

die() {
  printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$1" >&2
  log_file "ERROR" "$1"
  exit 1
}

on_err() {
  local ec=$?
  local line=${BASH_LINENO[0]:-unknown}
  printf "%b[ERROR]%b Command failed at line %s (exit=%s)\n" "$RED" "$NC" "$line" "$ec" >&2
  log_file "ERROR" "command failed at line $line exit=$ec"
}
trap on_err ERR

usage() {
  cat <<USAGE
Usage: ./run_course.sh [--interactive] [--auto] [--reset] [--start-at <lab_id>]
USAGE
}

confirm() {
  local prompt="$1"
  if [[ "$MODE" == "auto" ]] || [[ "$AUTO_YES" -eq 1 ]]; then
    log "AUTO" "$prompt -> y"
    log_file "PROMPT" "$prompt -> y"
    return 0
  fi
  while true; do
    read -r -p "$prompt " ans
    case "${ans,,}" in
      y|yes) log_file "PROMPT" "$prompt -> y"; return 0 ;;
      n|no) log_file "PROMPT" "$prompt -> n"; return 1 ;;
      *) printf "%bPlease answer y or n.%b\n" "$YELLOW" "$NC" ;;
    esac
  done
}

save_state() {
  mkdir -p "$STATE_DIR"
  cat > "$STATE_FILE" <<STATE
LAST_COMPLETED=${1:-none}
NEXT_LAB=${2:-${LAB_IDS[0]}}
MODE=$MODE
UPDATED_AT=$(date -Is)
STATE
}

load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
  fi
}

reset_state() {
  rm -rf "$STATE_DIR" "$ARTIFACT_DIR"
  rm -f "$PROGRESS_LOG" completion_certificate_*.md
  printf "%b[RESET]%b Cleared state, artifacts, and progress logs.\n" "$YELLOW" "$NC"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --interactive) MODE="interactive"; shift ;;
      --auto) MODE="auto"; AUTO_YES=1; shift ;;
      --reset) RESET=1; shift ;;
      --start-at)
        [[ $# -ge 2 ]] || die "--start-at requires a lab id"
        START_LAB="$2"
        shift 2
        ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown argument: $1" ;;
    esac
  done
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

check_debug_tools() {
  local missing=()
  local tool
  for tool in gdb strace lsof tcpdump htop; do
    if ! require_cmd "$tool"; then
      missing+=("$tool")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    log "OK" "Debugging tools present"
    return 0
  fi
  log "WARN" "Missing debugging tools: ${missing[*]}"
  log_file "WARN" "missing debug tools: ${missing[*]}"
  if [[ "$MODE" == "interactive" ]] && ! confirm "Attempt to install missing debugging tools via package manager? (y/n)"; then
    return 0
  fi
  local installer=""
  if require_cmd apt-get; then
    installer="sudo apt-get update && sudo apt-get install -y ${missing[*]}"
  elif require_cmd dnf; then
    installer="sudo dnf install -y ${missing[*]}"
  elif require_cmd yum; then
    installer="sudo yum install -y ${missing[*]}"
  elif require_cmd pacman; then
    installer="sudo pacman -Sy --noconfirm ${missing[*]}"
  fi
  if [[ -z "$installer" ]]; then
    log "WARN" "No supported package manager detected. Install manually: ${missing[*]}"
    return 0
  fi
  log "INFO" "Install command: $installer"
  [[ "$MODE" == "auto" ]] && return 0
  bash -lc "$installer" || log "WARN" "Install attempt failed; continuing"
}

setup_python() {
  require_cmd python3 || die "python3 is required"
  if [[ ! -d .venv ]]; then
    log "SETUP" "Creating .venv"
    python3 -m venv .venv
  else
    log "SETUP" "Reusing .venv"
  fi
  # shellcheck disable=SC1091
  source .venv/bin/activate
  python -m pip install --upgrade pip >/dev/null
  pip install -r requirements.txt >/dev/null
  log_file "SETUP" "python deps installed"
}

setup_node() {
  if ! require_cmd npm; then
    log "WARN" "npm not found; Node labs may be limited"
    log_file "WARN" "npm not found"
    return 0
  fi
  log "SETUP" "Installing Node tools (npm install)"
  npm install --silent >/dev/null 2>&1 || log "WARN" "npm install failed (continuing)"
  log_file "SETUP" "npm install attempted"
}

build_samples() {
  mkdir -p "$ARTIFACT_DIR"
  log "BUILD" "Validating Python samples"
  .venv/bin/python -m py_compile \
    src/broken_python_service/service.py \
    labs/lab1_runtime_crash/app/crashy_service.py \
    labs/lab2_memory_leak/app/memory_leak_worker.py \
    labs/lab3_race_condition/app/faulty_threading_app.py \
    labs/lab6_container_crashloop/app/crash_app.py
  if require_cmd node; then
    log "BUILD" "Validating Node samples"
    node --check src/broken_node_api/server.js >/dev/null
    node --check labs/lab4_api_failure/app/broken_node_api.js >/dev/null
  fi
  log_file "BUILD" "sample validation complete"
}

print_lab_header() {
  printf "\n%b=== %s ===%b\n" "$BLUE" "$1" "$NC"
  log_file "LAB" "starting $1"
}

show_ticket_summary() {
  local ticket="labs/$1/ticket.md"
  printf "%bTicket:%b %s\n" "$YELLOW" "$NC" "$ticket"
  sed -n '1,12p' "$ticket"
}

progress_hint() {
  case "$1:$2" in
    lab1_runtime_crash:1) echo "Hint 1: Compare failing payload shape to nested dict access in the service." ;;
    lab1_runtime_crash:2) echo "Hint 2: Convert KeyError into controlled validation response + log." ;;
    lab2_memory_leak:1) echo "Hint 1: Capture tracemalloc snapshots around repeated batch processing." ;;
    lab2_memory_leak:2) echo "Hint 2: Look for retained list growth in worker state." ;;
    lab3_race_condition:1) echo "Hint 1: Inspect lock acquisition order across both thread paths." ;;
    lab3_race_condition:2) echo "Hint 2: Circular wait is reproducible after synchronization barrier." ;;
    lab4_api_failure:1) echo "Hint 1: Validate SERVICE_TIMEOUT_MS before serving traffic." ;;
    lab4_api_failure:2) echo "Hint 2: Payload.invoice.amount is assumed to exist." ;;
    lab5_ci_pipeline_break:1) echo "Hint 1: Read `.github/workflows/ci.yml` env values first." ;;
    lab5_ci_pipeline_break:2) echo "Hint 2: CI env differs from local defaults." ;;
    lab6_container_crashloop:1) echo "Hint 1: Check startup logs before changing the image." ;;
    lab6_container_crashloop:2) echo "Hint 2: REQUIRED_BOOT_TOKEN is mandatory." ;;
    *) echo "Hint: Reproduce, inspect logs, isolate assumptions, confirm with a test." ;;
  esac
}

reveal_solution() {
  printf "%bGuided solution for %s%b\n" "$GREEN" "$1" "$NC"
  case "$1" in
    lab1_runtime_crash)
      cat <<TEXT
- Root cause: missing `metadata` causes KeyError in nested access.
- Fix: schema validation and controlled error response instead of crash path.
- Add regression coverage for malformed partner payloads.
TEXT
      ;;
    lab2_memory_leak)
      cat <<TEXT
- Root cause: unbounded retention of full batch payloads.
- Fix: bounded cache / summaries-only retention / explicit cleanup.
- Verify with tracemalloc snapshot comparison.
TEXT
      ;;
    lab3_race_condition)
      cat <<TEXT
- Root cause: inconsistent lock order (`primary->secondary` vs `secondary->primary`).
- Fix: enforce lock ordering or use a higher-level coordination primitive.
- Add timeout-based tests and thread diagnostics logging.
TEXT
      ;;
    lab4_api_failure)
      cat <<TEXT
- Root cause 1: corrupted `SERVICE_TIMEOUT_MS` value.
- Root cause 2: missing `payload.invoice` causes unhandled path.
- Fix: startup config validation + request schema validation with 400 responses.
TEXT
      ;;
    lab5_ci_pipeline_break)
      cat <<TEXT
- Root cause: `.github/workflows/ci.yml` exports `SERVICE_TIMEOUT_MS=not_a_number`.
- Fix: correct env value and add config validation/guardrail checks.
TEXT
      ;;
    lab6_container_crashloop)
      cat <<TEXT
- Root cause: missing `REQUIRED_BOOT_TOKEN` causes immediate exit code 1.
- Fix: inject token via environment/secret and verify startup contract in deployment config.
TEXT
      ;;
  esac
  log_file "SOLUTION" "revealed $1"
}

run_pytest_fail() {
  local test_path="$1"
  local out_file="$2"
  set +e
  .venv/bin/pytest -q "$test_path" >"$out_file" 2>&1
  local ec=$?
  set -e
  return "$ec"
}

run_node_test_fail() {
  local test_path="$1"
  local out_file="$2"
  if ! require_cmd node; then
    echo "node is not installed" > "$out_file"
    return 127
  fi
  set +e
  node --test "$test_path" >"$out_file" 2>&1
  local ec=$?
  set -e
  return "$ec"
}

offer_investigation_prompts() {
  local id="$1"
  local logfile="$2"
  if confirm "Do you want to investigate logs? (y/n)"; then
    printf "%b--- log excerpt (%s) ---%b\n" "$CYAN" "$logfile" "$NC"
    tail -n 20 "$logfile" || true
    log_file "ACTION" "$id investigated logs"
  fi
  if confirm "Run debugger? (y/n)"; then
    case "$id" in
      lab4_api_failure) echo "Suggested: node --inspect-brk labs/lab4_api_failure/app/broken_node_api.js" ;;
      *) echo "Suggested: .venv/bin/python -m pdb <script_or_test>" ;;
    esac
    log_file "ACTION" "$id debugger prompt accepted"
  fi
  progress_hint "$id" 1
  progress_hint "$id" 2
  if confirm "Reveal guided solution? (y/n)"; then
    reveal_solution "$id"
  fi
}

run_lab1_runtime_crash() {
  local id="lab1_runtime_crash"
  local out="$ARTIFACT_DIR/${id}_pytest.log"
  print_lab_header "$id"
  show_ticket_summary "$id"
  run_pytest_fail "labs/lab1_runtime_crash/tests/test_runtime_crash.py" "$out" || true
  log "FAIL" "Triggered failing pytest for $id"
  offer_investigation_prompts "$id" "$out"
}

run_lab2_memory_leak() {
  local id="lab2_memory_leak"
  local out="$ARTIFACT_DIR/${id}_pytest.log"
  print_lab_header "$id"
  show_ticket_summary "$id"
  run_pytest_fail "labs/lab2_memory_leak/tests/test_memory_leak.py" "$out" || true
  LAB2_TRACE_FILE="$ARTIFACT_DIR/${id}_tracemalloc.log" .venv/bin/python - <<'PY'
import os
from labs.lab2_memory_leak.app.memory_leak_worker import leak_profile
current, peak = leak_profile(iterations=30)
with open(os.environ['LAB2_TRACE_FILE'], 'w', encoding='utf-8') as fh:
    fh.write(f"tracemalloc current={current} peak={peak}\n")
PY
  log "FAIL" "Triggered failing pytest and tracemalloc capture for $id"
  offer_investigation_prompts "$id" "$out"
}

run_lab3_race_condition() {
  local id="lab3_race_condition"
  local out="$ARTIFACT_DIR/${id}_pytest.log"
  print_lab_header "$id"
  show_ticket_summary "$id"
  run_pytest_fail "labs/lab3_race_condition/tests/test_threading_failures.py" "$out" || true
  .venv/bin/python src/faulty_threading_app/deadlock_demo.py >"$ARTIFACT_DIR/${id}_deadlock.log" 2>&1 || true
  log "FAIL" "Triggered deadlock reproduction for $id"
  offer_investigation_prompts "$id" "$out"
}

run_lab4_api_failure() {
  local id="lab4_api_failure"
  local out="$ARTIFACT_DIR/${id}_node_test.log"
  print_lab_header "$id"
  show_ticket_summary "$id"
  export SERVICE_TIMEOUT_MS="not_a_number"
  run_node_test_fail "labs/lab4_api_failure/tests/test_api_failure.js" "$out" || true
  log "FAIL" "Triggered Node API failure simulation for $id"
  offer_investigation_prompts "$id" "$out"
  unset SERVICE_TIMEOUT_MS || true
}

run_lab5_ci_pipeline_break() {
  local id="lab5_ci_pipeline_break"
  local out="$ARTIFACT_DIR/${id}_pytest.log"
  print_lab_header "$id"
  show_ticket_summary "$id"
  export SERVICE_TIMEOUT_MS="not_a_number"
  run_pytest_fail "labs/lab5_ci_pipeline_break/tests/test_ci_failure.py" "$out" || true
  log "FAIL" "Triggered CI simulation failure for $id"
  offer_investigation_prompts "$id" "$out"
  unset SERVICE_TIMEOUT_MS || true
}

run_lab6_container_crashloop() {
  local id="lab6_container_crashloop"
  local out="$ARTIFACT_DIR/${id}_pytest.log"
  print_lab_header "$id"
  show_ticket_summary "$id"
  run_pytest_fail "labs/lab6_container_crashloop/tests/test_container_crashloop.py" "$out" || true
  if require_cmd docker; then
    (cd labs/lab6_container_crashloop && docker build -t geneva-rel-lab6:local . >"$ARTIFACT_DIR/${id}_docker_build.log" 2>&1 || true)
    docker run --rm geneva-rel-lab6:local >"$ARTIFACT_DIR/${id}_docker_run.log" 2>&1 || true
  else
    echo "docker not installed; run manually: docker build -t geneva-rel-lab6 labs/lab6_container_crashloop && docker run --rm geneva-rel-lab6" >"$ARTIFACT_DIR/${id}_docker_run.log"
    log "WARN" "Docker not available; wrote manual reproduction command"
  fi
  log "FAIL" "Triggered container crash loop simulation for $id"
  offer_investigation_prompts "$id" "$out"
}

run_lab_by_id() {
  case "$1" in
    lab1_runtime_crash) run_lab1_runtime_crash ;;
    lab2_memory_leak) run_lab2_memory_leak ;;
    lab3_race_condition) run_lab3_race_condition ;;
    lab4_api_failure) run_lab4_api_failure ;;
    lab5_ci_pipeline_break) run_lab5_ci_pipeline_break ;;
    lab6_container_crashloop) run_lab6_container_crashloop ;;
    *) die "Unknown lab id: $1" ;;
  esac
}

generate_certificate() {
  CERT_FILE="completion_certificate_$(date +%Y%m%d_%H%M%S).md"
  cat > "$CERT_FILE" <<CERT
# Geneva Software Reliability Lab - Completion Certificate

- Candidate: ${USER:-unknown}
- Host: $(hostname)
- Date: $(date -Is)
- Mode: $MODE
- Completed Labs: ${LAB_IDS[*]}

## Skills Demonstrated
- Systematic debugging and failure reproduction
- Log forensics and RCA-oriented investigation
- Memory leak detection with tracemalloc
- Concurrency/deadlock diagnostics
- CI pipeline failure analysis (GitHub Actions)
- Container startup and crash loop investigation

## Signature
Automated by `run_course.sh` in `geneva-software-reliability-lab`.
CERT
  log_file "CERT" "generated $CERT_FILE"
  log "DONE" "Completion certificate written to $CERT_FILE"
}

main() {
  local original_argc=$#
  parse_args "$@"

  if [[ "$RESET" -eq 1 ]]; then
    reset_state
    if [[ $original_argc -eq 1 ]]; then
      exit 0
    fi
  fi

  load_state
  setup_python
  setup_node
  check_debug_tools
  build_samples

  local next_lab="${LAB_IDS[0]}"
  if [[ -n "$START_LAB" ]]; then
    next_lab="$START_LAB"
  elif [[ -n "${NEXT_LAB:-}" ]]; then
    next_lab="$NEXT_LAB"
  fi

  local start_found=0
  local lab
  for lab in "${LAB_IDS[@]}"; do
    if [[ "$lab" == "$next_lab" ]]; then
      start_found=1
    fi
    [[ $start_found -eq 0 ]] && continue

    run_lab_by_id "$lab"

    local next="done"
    local seen=0
    local candidate
    for candidate in "${LAB_IDS[@]}"; do
      if [[ $seen -eq 1 ]]; then
        next="$candidate"
        break
      fi
      [[ "$candidate" == "$lab" ]] && seen=1
    done

    save_state "$lab" "$next"
    log_file "LAB" "completed $lab next=$next"
  done

  generate_certificate
  save_state "all" "done"
  log "DONE" "Course orchestration finished. Resume state saved in $STATE_FILE"
}

main "$@"
