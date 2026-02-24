# Root Cause Analysis (RCA) Template

## Simplified Definition
An RCA explains what failed, why it failed, and how recurrence will be prevented.

## Enterprise Context
RCA quality matters for auditability, operations maturity, and stakeholder trust.

## Geneva IT Role Alignment
Useful for contractor delivery, agency IT support, and enterprise incident postmortems.

## RCA Template
- Incident ID:
- Date/Time (UTC):
- Service/Component:
- Severity:
- SLA/OLA Impact:
- Business Impact:
- Detection Method:
- Timeline:
- Immediate Mitigation:
- Root Cause:
- Contributing Factors:
- Corrective Actions:
- Preventive Actions:
- Validation Evidence:

## Troubleshooting Tree (ASCII)
```text
Symptom observed
|
+-- Reproducible? ---- no --> capture more evidence
|                     yes
+-- Config issue? ---- yes --> env/secrets/defaults/deploy diff
|                     no
+-- Code defect? ----- yes --> tests/debugger/patch
|                     no --> infra/resource/network/container checks
```
