from __future__ import annotations

import threading

counter = 0


def increment_many(n: int = 50_000) -> None:
    global counter
    for _ in range(n):
        value = counter
        value += 1
        counter = value


def run_race(workers: int = 4, n: int = 50_000) -> int:
    global counter
    counter = 0
    threads = [threading.Thread(target=increment_many, args=(n,)) for _ in range(workers)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    return counter
