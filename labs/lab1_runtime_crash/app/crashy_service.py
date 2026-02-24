from __future__ import annotations

import logging
from typing import Any

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
LOGGER = logging.getLogger("lab1")


class IntakeService:
    def submit(self, payload: dict[str, Any]) -> dict[str, Any]:
        LOGGER.info("submit received trace_id=%s", payload.get("trace_id", "missing"))
        source = payload["metadata"]["source"]  # Hidden defect
        job_type = payload["job"]["type"]
        return {"accepted": True, "source": source, "job_type": job_type}
