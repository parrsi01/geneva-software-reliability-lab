# Ticket: GVA-REL-101 Runtime Crash in Intake Service

- Severity: SEV-2
- Expected SLA: Mitigation within 60 minutes, RCA within 1 business day
- Business Impact: Intake requests intermittently return HTTP 500, delaying downstream processing
- Service: `intake-service` (Python)

## Reported Symptoms
- Error spikes on `/submit`
- `/health` remains green
- Logs show `KeyError` during partner bursts
