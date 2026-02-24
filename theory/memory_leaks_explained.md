# Memory Leaks Explained

## Short Definition
A memory leak is unbounded memory retention that grows over time without useful work benefit.

## Enterprise Context
Leaks often show up as slow degradation, restarts, or OOM kills instead of immediate crashes.

## Geneva Role Alignment
Important for long-running scientific, analytics, and backend service workloads.

## LinkedIn Skill Mapping
- Performance Optimization
- Python
- Observability
- Incident Response

## Signals
- Increasing RSS over time
- Restarts/OOM events
- Throughput decline under memory pressure
- GC overhead without recovery

## Lab Mapping
`labs/lab2_memory_leak` demonstrates leak detection with `tracemalloc`.
