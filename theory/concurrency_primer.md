# Concurrency Primer

## Short Definition
Concurrency bugs are timing-dependent failures caused by unsafe interaction between execution paths.

## Enterprise Context
They are expensive because they can be intermittent and sensitive to instrumentation.

## LinkedIn Skill Mapping
- Multithreading
- Debugging
- Performance Tuning
- SRE

## Concepts in This Lab
- Race condition
- Deadlock
- Lock ordering
- Non-determinism

## Troubleshooting Tree (ASCII)
```text
Hung multithreaded service
|
+-- High CPU? -------- yes --> spin / contention
|                      no
+-- Waiting on locks? - yes --> inspect lock order / thread dump
|                      no --> inspect I/O blocking with strace
```
