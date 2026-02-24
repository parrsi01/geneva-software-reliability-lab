# Ticket: GVA-REL-202 Memory Growth in Batch Enrichment Worker

- Severity: SEV-2
- Expected SLA: Stabilization within 2 hours
- Business Impact: Throughput drops and restart frequency increases under load
- Service: `batch-enricher`

## Reported Symptoms
- RSS rises continuously across repeated batches
- Restart temporarily clears the issue
