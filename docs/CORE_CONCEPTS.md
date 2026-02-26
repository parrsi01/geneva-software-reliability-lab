# Core Concepts

Author: Simon Parris  
Date: 2026-02-26

This repository trains debugging and reliability engineering as an evidence-driven operational discipline, not ad hoc trial-and-error.

## 1. Reproduce Before Fixing

- Confirm the failure condition with exact steps.
- Capture runtime evidence before changing code/config.
- Preserve a minimal reproduction path when possible.

## 2. Symptom vs Root Cause

- Symptoms are user-visible failures (timeouts, crashes, bad responses).
- Root cause is the underlying system/software condition.
- Effective debugging narrows from symptom to mechanism using evidence.

## 3. Reliability Domains Covered

- runtime crashes
- memory leaks
- race conditions / deadlocks
- API contract mismatches
- CI pipeline breakage
- container crash loops

## 4. Evidence Sources

- application logs and stack traces
- failing tests and reproducer scripts
- process state / system tools
- container/runtime inspection
- CI job outputs and diff history

## 5. Safe Remediation Loop

1. Reproduce
2. Instrument/observe
3. Form hypothesis
4. Test one change
5. Re-verify behavior
6. Document fix and regression guard
