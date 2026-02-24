# Linux Observability Cheatsheet

## Simplified Definition
Observability is understanding runtime behavior through logs, metrics, and low-level operating system signals.

## Enterprise Context
Most production diagnosis starts from process state and logs, not source code.

## Geneva IT Role Alignment
Important for uptime-critical support roles with auditability and incident-response requirements.

## LinkedIn Skill Mapping
- Linux
- Monitoring
- Observability
- Incident Response

## Tools
- `htop` / `top`
- `lsof -p <pid>`
- `strace -p <pid>`
- `ss -ltnp`
- `journalctl -u <service>`
- `tcpdump -i any port <port>`

## Metrics Primer
- RED: Rate, Errors, Duration
- USE: Utilization, Saturation, Errors
