# Ticket: GVA-REL-404 Reconciliation API Returning 500s

- Severity: SEV-1
- Expected SLA: Mitigation within 30 minutes, full RCA within 24 hours
- Business Impact: Financial reconciliation callbacks fail; manual fallback required
- Service: `reconcile-api` (Node.js)

## Reported Symptoms
- `/health` is healthy but `/v1/reconcile` fails
- Config parse errors and payload errors both appear in logs
