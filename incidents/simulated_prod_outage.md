# Simulated Production Outage: Reconciliation API Timeout Storm

## Scenario
A Geneva-based travel operations platform reports repeated callback failures and hotfix deployment delays.

## Business Impact
- Delayed financial reconciliation reports
- Manual operations workload increases
- SLA breach risk if outage exceeds two hours

## Investigation Goals
1. Separate code defects from config drift and runtime issues
2. Reproduce failures locally
3. Produce an RCA with corrective and preventive actions

## Evidence Sources
- `incidents/log_archive/api_error.log`
- `incidents/log_archive/system_journal_excerpt.log`
- `incidents/log_archive/ci_runner.log`
