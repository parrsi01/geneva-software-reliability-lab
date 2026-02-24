# Bash Debugging Cheatsheet

## Simplified Definition
Bash debugging means making shell execution visible and deterministic so you can reproduce and fix automation failures.

## Enterprise Context
CI, deployment, and operational automation often fail in shell. Fast diagnosis lowers MTTR and reduces risky hotfixes.

## Geneva IT Role Alignment
Relevant for CERN/UN contractor support, enterprise operations, and junior SRE/DevOps work.

## LinkedIn Skill Mapping
- Bash
- Linux
- Troubleshooting
- Automation

## Core Commands
- `set -Eeuo pipefail`
- `set -x`
- `trap 'echo fail at line $LINENO' ERR`
- `bash -n script.sh`
- `shellcheck script.sh`

## Troubleshooting Tree (ASCII)
```text
Script failed
|
+-- Syntax error? ---- yes --> bash -n
|                     no
+-- Missing var? ----- yes --> set -u / inspect env
|                     no
+-- External command? - yes --> PATH / permissions / availability
|                     no --> inspect exit codes and timing
```
