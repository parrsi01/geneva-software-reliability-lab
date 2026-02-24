# Debugging Methodology

## Short Definition
Systematic debugging is reproducible, evidence-driven hypothesis testing.

## Enterprise Context
Professional debugging prioritizes safe mitigation, evidence preservation, and verifiable root cause confirmation.

## Geneva Role Alignment
- CERN contractor support: mixed-stack runtime diagnosis
- UN agency IT support: ticket-driven triage and RCA communication
- Enterprise SaaS: observability + CI/CD + container debugging

## LinkedIn Skill Mapping
- Root Cause Analysis
- Incident Management
- Linux Administration
- Python / Node.js Debugging
- Observability

## Workflow
1. Stabilize and collect evidence
2. Reproduce failure
3. Reduce scope
4. Form falsifiable hypotheses
5. Test one variable at a time
6. Confirm with fix + regression test
7. Document RCA and prevention controls

## Troubleshooting Tree (ASCII)
```text
Production symptom
|
+-- Active user impact? -- yes --> mitigate first
|                         no --> controlled repro
+-- Reproducible? ------ no --> add instrumentation / capture inputs
|                         yes
+-- Code / Config / Infra?
    +-- Code   --> tests / stack traces / debugger
    +-- Config --> env vars / defaults / deployment drift
    +-- Infra  --> resources / network / container runtime
```
