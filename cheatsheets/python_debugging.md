# Python Debugging Cheatsheet

## Simplified Definition
Python debugging is evidence-driven inspection of stack traces, variables, and runtime state.

## Enterprise Context
Used in backend support, batch processing failures, and internal service incident response.

## Geneva IT Role Alignment
Relevant for research platforms, agency systems, and enterprise SaaS support environments.

## LinkedIn Skill Mapping
- Python
- Pytest
- Debugging
- RCA

## Common Techniques
- `pytest -q -k <pattern>`
- `python -m pdb script.py`
- `breakpoint()`
- `tracemalloc.start()`
- `faulthandler` for hung services

## Troubleshooting Tree (ASCII)
```text
Python service failing
|
+-- Traceback available? -- yes --> isolate exception path
|                         no
+-- Hangs? ------------- yes --> thread dump / strace / faulthandler
|                        no
+-- Memory growth? ----- yes --> tracemalloc snapshots
                         no --> inspect config/env/logs
```
