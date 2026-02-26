# Project Manual

Author: Simon Parris  
Date: 2026-02-26

## Purpose

This repository is a structured reliability/debugging training lab for building professional troubleshooting habits under operational constraints.

## Operating Model

- Use `run_course.sh` for guided execution, progress logging, and reset flows.
- Use `labs/` for isolated failure scenarios.
- Use `incidents/` for ticket-style debugging drills.
- Use `theory/` and `cheatsheets/` for concept review and quick references.

## Standard Lab Workflow

1. Read the lab `README.md`
2. Read the associated `ticket.md`
3. Reproduce the failure
4. Capture evidence (logs, stack traces, outputs)
5. Hypothesize and test minimal changes
6. Verify behavior and prevent regression
7. Document root cause and remediation

## Evidence Standard

- exact reproduction commands
- error output / stack trace snippets
- before/after behavior confirmation
- root cause summary
- guardrail or regression test note

## Quality Gates Before Push

1. `./validate_repo.sh --quick`
2. `make lint`
3. Review diffs for accidental environment artifacts

Note: `tests/failing_tests/` intentionally contains failing scenarios and should not be treated as a "green suite" target.
