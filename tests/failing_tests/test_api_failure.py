import pathlib


def test_node_api_lab_present():
    assert pathlib.Path('labs/lab4_api_failure/tests/test_api_failure.js').exists()
