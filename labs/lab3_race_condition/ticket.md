# Ticket: GVA-REL-303 Intermittent Service Hang Under Concurrent Requests

- Severity: SEV-1
- Expected SLA: Mitigation within 30 minutes
- Business Impact: Scheduler backlog and missed processing windows
- Service: `scheduler-worker`

## Reported Symptoms
- Process remains running but makes no progress
- Reappears under concurrent workloads
