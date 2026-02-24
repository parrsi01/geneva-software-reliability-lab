const test = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const { boot } = require('../app/broken_node_api');
const { parseTimeoutMs } = require('../../../src/broken_node_api/server');

function waitForListening(server) {
  return new Promise((resolve, reject) => {
    if (server.listening) {
      resolve();
      return;
    }
    server.once('listening', resolve);
    server.once('error', reject);
  });
}

function request(port, payload) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: '127.0.0.1',
        port,
        path: '/v1/reconcile',
        method: 'POST',
        headers: { 'content-type': 'application/json' },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => resolve({ statusCode: res.statusCode, body: data }));
      }
    );
    req.on('error', reject);
    req.end(JSON.stringify(payload));
  });
}

test('reconcile endpoint should reject invalid payload without 500', async () => {
  process.env.SERVICE_TIMEOUT_MS = '1000';
  const server = boot(0);
  try {
    await waitForListening(server);
    const port = server.address().port;
    const resp = await request(port, { trace_id: 'x1' });
    assert.equal(resp.statusCode, 400);
  } finally {
    server.close();
  }
});

test('corrupted SERVICE_TIMEOUT_MS should be detected', () => {
  assert.throws(() => parseTimeoutMs('not_a_number'), /invalid SERVICE_TIMEOUT_MS/);
});
