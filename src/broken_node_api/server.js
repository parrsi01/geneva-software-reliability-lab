const http = require('node:http');

function parseTimeoutMs(envValue) {
  if (envValue === undefined) return 1000;
  const parsed = Number(envValue);
  if (!Number.isFinite(parsed)) {
    throw new Error(`invalid SERVICE_TIMEOUT_MS: ${envValue}`);
  }
  return parsed;
}

function createServer() {
  return http.createServer((req, res) => {
    try {
      if (req.url === '/health') {
        res.writeHead(200, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ ok: true }));
        return;
      }
      if (req.url === '/metrics') {
        res.writeHead(200, { 'content-type': 'text/plain' });
        res.end('http_requests_total 1\nhttp_errors_total 0\n');
        return;
      }
      if (req.url === '/v1/reconcile' && req.method === 'POST') {
        const timeoutMs = parseTimeoutMs(process.env.SERVICE_TIMEOUT_MS);
        let body = '';
        req.on('data', (chunk) => { body += chunk; });
        req.on('end', () => {
          try {
            const payload = body ? JSON.parse(body) : {};
            const amount = payload.invoice.amount; // Hidden defect: no validation.
            const faultInject = process.env.FAULT_INJECT_DB_TIMEOUT === '1';
            res.writeHead(200, { 'content-type': 'application/json' });
            res.end(JSON.stringify({ reconciled: true, amount, latencyMs: faultInject ? timeoutMs + 100 : 5 }));
          } catch (err) {
            res.writeHead(500, { 'content-type': 'application/json' });
            res.end(JSON.stringify({ error: err.message }));
          }
        });
        return;
      }
      res.writeHead(404, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ error: 'not found' }));
    } catch (err) {
      res.writeHead(500, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
  });
}

function start(port = 8085) {
  if (!process.env.REQUIRED_BOOT_TOKEN) {
    throw new Error('missing REQUIRED_BOOT_TOKEN');
  }
  const server = createServer();
  server.listen(port, '127.0.0.1');
  return server;
}

module.exports = { createServer, start, parseTimeoutMs };
