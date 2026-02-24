# Ticket: GVA-REL-606 Container CrashLoopBackOff in API Worker

- Severity: SEV-1
- Expected SLA: Mitigation within 30 minutes
- Business Impact: Worker pool capacity drop and queue backlog
- Platform: Docker/Kubernetes-style runtime

## Reported Symptoms
- Container exits immediately with code 1
- Startup logs mention missing token
