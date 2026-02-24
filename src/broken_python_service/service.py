"""Shared broken Python service used across labs and demonstrations."""
from __future__ import annotations

import json
import logging
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import Any

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
LOGGER = logging.getLogger("broken_python_service")
REQUEST_COUNT = 0
ERROR_COUNT = 0


def handle_payload(payload: dict[str, Any]) -> dict[str, Any]:
    global REQUEST_COUNT
    REQUEST_COUNT += 1
    # Hidden defect: assumes nested fields are always present.
    priority = payload["job"]["priority"]
    return {"accepted": True, "priority": priority}


class Handler(BaseHTTPRequestHandler):
    def _send(self, status: int, body: str, content_type: str = "text/plain") -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.end_headers()
        self.wfile.write(body.encode())

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/health":
            self._send(200, "ok")
            return
        if self.path == "/metrics":
            self._send(200, f"service_requests_total {REQUEST_COUNT}\nservice_errors_total {ERROR_COUNT}\n", "text/plain")
            return
        self._send(404, "not found")

    def do_POST(self) -> None:  # noqa: N802
        global ERROR_COUNT
        if self.path != "/submit":
            self._send(404, "not found")
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length)
        try:
            response = handle_payload(json.loads(raw.decode() or "{}"))
            self._send(200, json.dumps(response), "application/json")
        except Exception as exc:
            ERROR_COUNT += 1
            LOGGER.exception("submit failed: %s", exc)
            self._send(500, "internal error")


def main(port: int = 8090) -> None:
    LOGGER.info("starting broken python service on port %s", port)
    server = HTTPServer(("127.0.0.1", port), Handler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        LOGGER.info("shutdown requested")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
