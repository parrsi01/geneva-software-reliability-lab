from __future__ import annotations

import os


def test_ci_env_contract():
    value = os.getenv('SERVICE_TIMEOUT_MS', '1000')
    assert value.isdigit(), 'SERVICE_TIMEOUT_MS must be numeric'
    assert int(value) >= 100
