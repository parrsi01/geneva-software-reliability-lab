# Lesson Execution Companion

Author: Simon Parris  
Date: 2026-02-26

Use this checklist during each debugging lab so you build repeatable RCA habits instead of random guess loops.

## Per-Lab Checklist

1. State the failure symptom in one sentence.
2. Run the reproducer and confirm the symptom.
3. Capture logs/tests/output before modifying anything.
4. Identify the likely layer (code, config, runtime, container, CI, dependency).
5. Test one hypothesis at a time.
6. Re-run the reproducer after each change.
7. Record the root cause and final fix.
8. Add/confirm a regression guard (test, assertion, or runbook note).

## Debugging Prompts

- What evidence disproves my current assumption?
- What changed recently?
- Is this deterministic or intermittent?
- Is the bug in code, environment, or execution order?

## Stop Conditions

Pause if you are about to:

- delete evidence
- apply multiple fixes at once
- "fix" by suppressing an error without understanding cause
