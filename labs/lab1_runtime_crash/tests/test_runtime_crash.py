from labs.lab1_runtime_crash.app.crashy_service import IntakeService


def test_submit_handles_missing_metadata_gracefully():
    service = IntakeService()
    payload = {"trace_id": "abc-123", "job": {"type": "import"}}
    result = service.submit(payload)
    assert result["accepted"] is False
    assert "error" in result
