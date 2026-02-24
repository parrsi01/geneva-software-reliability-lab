from labs.lab2_memory_leak.tests.test_memory_leak import test_memory_usage_stays_bounded


def test_lab2_memory_leak_wrapper():
    test_memory_usage_stays_bounded()
