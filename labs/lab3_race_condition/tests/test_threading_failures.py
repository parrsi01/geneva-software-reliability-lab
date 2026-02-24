from labs.lab3_race_condition.app.faulty_threading_app import start_two_paths


def test_no_deadlock_under_two_paths():
    assert start_two_paths() is False
