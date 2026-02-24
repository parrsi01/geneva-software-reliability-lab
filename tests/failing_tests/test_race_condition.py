from labs.lab3_race_condition.tests.test_threading_failures import test_no_deadlock_under_two_paths


def test_lab3_race_condition_wrapper():
    test_no_deadlock_under_two_paths()
