from __future__ import annotations

import logging
import tracemalloc
from dataclasses import dataclass, field

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
LOGGER = logging.getLogger("lab2")


@dataclass
class EnrichmentWorker:
    retained_payloads: list[dict] = field(default_factory=list)

    def process_batch(self, batch_id: int, records: int = 1000) -> int:
        payload = {
            "batch_id": batch_id,
            "records": [{"idx": i, "value": f"record-{batch_id}-{i}"} for i in range(records)],
        }
        self.retained_payloads.append(payload)  # Hidden defect: unbounded retention
        LOGGER.info("processed batch=%s retained=%s", batch_id, len(self.retained_payloads))
        return len(payload["records"])


def leak_profile(iterations: int = 10) -> tuple[int, int]:
    worker = EnrichmentWorker()
    tracemalloc.start()
    for i in range(iterations):
        worker.process_batch(i)
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    return current, peak
