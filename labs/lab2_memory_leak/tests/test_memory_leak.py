from labs.lab2_memory_leak.app.memory_leak_worker import leak_profile


def test_memory_usage_stays_bounded():
    current, peak = leak_profile(iterations=25)
    assert current < 200_000, f"memory leak suspected current={current} peak={peak}"
