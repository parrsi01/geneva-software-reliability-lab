from __future__ import annotations

import os
import subprocess
import sys


def test_container_entrypoint_contract(tmp_path):
    env = os.environ.copy()
    env.pop('REQUIRED_BOOT_TOKEN', None)
    proc = subprocess.run(
        [sys.executable, 'labs/lab6_container_crashloop/app/crash_app.py'],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr + proc.stdout
