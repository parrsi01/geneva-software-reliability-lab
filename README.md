# Geneva Software Reliability Lab

A production-style Junior Software Debugging & Reliability Engineering training repository aligned to Geneva-market roles (enterprise contractors, international organization IT support, transport and logistics operations, and enterprise SaaS support environments).

This is a professional debugging lab, not a hobby course. The content is designed for systematic incident response, reproducibility, and root-cause analysis under operational constraints.

## Role Alignment (Geneva)

- Enterprise contractor support: runtime diagnostics, Linux debugging, service logs, failure reproduction
- International organization IT support: incident triage, SLA communication, environment drift detection
- Transport and logistics enterprise operations: API failures, CI breaks, container crash loops, observability basics
- SaaS reliability teams: concurrency bugs, memory leaks, on-call investigation

## LinkedIn Job Skill Mapping

- Debugging, Troubleshooting, Root Cause Analysis (RCA)
- Linux, Bash, GDB, Strace, Lsof, Tcpdump, htop
- Python, Node.js, Test Failure Analysis, CI/CD, GitHub Actions
- Docker, Incident Response, Observability, Logging, Metrics

## Repository Layout

```text
geneva-software-reliability-lab/
├── cheatsheets/
├── theory/
├── labs/
├── incidents/
├── src/
├── tests/failing_tests/
├── soc/ devops/ data_science/ sysadmin/
└── run_course.sh
```

## Quick Start

```bash
chmod +x run_course.sh
./run_course.sh --interactive
```

## Automation Highlights

`run_course.sh` is the single orchestrator. It validates dependencies, creates a venv, installs Node tools, triggers failures, prompts for investigation, logs progress, supports resume, and generates a completion certificate.
