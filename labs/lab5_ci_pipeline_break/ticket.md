# Ticket: GVA-REL-505 Hotfix Pipeline Blocked in GitHub Actions

- Severity: SEV-2 (can escalate if hotfix delayed)
- Expected SLA: Restore hotfix pipeline within 60 minutes
- Business Impact: Blocks deployment of API remediation
- System: GitHub Actions CI pipeline

## Reported Symptoms
- CI validation step fails immediately
- Local tests pass using defaults, CI fails with env override
