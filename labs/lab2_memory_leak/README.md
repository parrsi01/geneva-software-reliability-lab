# Lab 2: Memory Leak Detection with `tracemalloc`

## Objective
Identify unbounded memory retention in a Python batch worker and confirm the leak using `tracemalloc`.

## Enterprise Context
Long-running workers often degrade gradually before restarts or OOM events appear.
