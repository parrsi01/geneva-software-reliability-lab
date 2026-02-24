const test = require('node:test');
const assert = require('node:assert/strict');
const { parseTimeoutMs } = require('./server');

test('parseTimeoutMs throws on corrupted environment value', () => {
  assert.throws(() => parseTimeoutMs('not_a_number'), /invalid SERVICE_TIMEOUT_MS/);
});
