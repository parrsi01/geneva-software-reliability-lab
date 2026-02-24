from __future__ import annotations

import threading
import time

lock_primary = threading.Lock()
lock_secondary = threading.Lock()
barrier = threading.Barrier(2)


def path_a() -> None:
    with lock_primary:
        barrier.wait(timeout=0.2)
        time.sleep(0.05)
        with lock_secondary:
            pass


def path_b() -> None:
    with lock_secondary:
        barrier.wait(timeout=0.2)
        time.sleep(0.05)
        with lock_primary:
            pass


def start_two_paths(timeout: float = 0.3) -> bool:
    global barrier
    barrier = threading.Barrier(2)
    t1 = threading.Thread(target=path_a, daemon=True)
    t2 = threading.Thread(target=path_b, daemon=True)
    t1.start(); t2.start()
    t1.join(timeout); t2.join(timeout)
    return t1.is_alive() or t2.is_alive()
