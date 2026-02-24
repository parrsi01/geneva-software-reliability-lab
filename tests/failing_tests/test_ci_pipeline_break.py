import os


def test_ci_pipeline_env_is_corrupted_for_training():
    value = os.getenv('SERVICE_TIMEOUT_MS', 'not_a_number')
    assert value.isdigit(), f'training CI env corrupted as designed: {value}'
