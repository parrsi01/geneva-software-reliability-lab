from __future__ import annotations

import logging
import threading
import time

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
LOGGER = logging.getLogger("deadlock_demo")
lock_a = threading.Lock()
lock_b = threading.Lock()
barrier = threading.Barrier(2)


def worker_one() -> None:
    with lock_a:
        LOGGER.info("worker_one acquired lock_a")
        barrier.wait(timeout=0.2)
        time.sleep(0.1)
        LOGGER.info("worker_one waiting for lock_b")
        with lock_b:
            LOGGER.info("worker_one acquired lock_b")


def worker_two() -> None:
    with lock_b:
        LOGGER.info("worker_two acquired lock_b")
        barrier.wait(timeout=0.2)
        time.sleep(0.1)
        LOGGER.info("worker_two waiting for lock_a")
        with lock_a:
            LOGGER.info("worker_two acquired lock_a")


def run_deadlock(timeout: float = 0.6) -> bool:
    global barrier
    barrier = threading.Barrier(2)
    t1 = threading.Thread(target=worker_one, daemon=True)
    t2 = threading.Thread(target=worker_two, daemon=True)
    t1.start(); t2.start()
    t1.join(timeout); t2.join(timeout)
    return t1.is_alive() or t2.is_alive()


if __name__ == "__main__":
    if run_deadlock():
        LOGGER.error("deadlock detected")
        raise SystemExit(1)
    LOGGER.info("no deadlock")
