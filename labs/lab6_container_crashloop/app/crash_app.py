from __future__ import annotations

import logging
import os
import time

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
LOGGER = logging.getLogger('lab6')


def main() -> int:
    token = os.getenv('REQUIRED_BOOT_TOKEN')
    if not token:
        LOGGER.error('FATAL missing REQUIRED_BOOT_TOKEN')
        return 1
    LOGGER.info('service boot token present length=%s', len(token))
    LOGGER.info('service running (simulated)')
    time.sleep(0.2)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
