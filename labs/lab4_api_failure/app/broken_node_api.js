const { createServer, parseTimeoutMs } = require('../../../src/broken_node_api/server');

function boot(port = 8086) {
  const server = createServer();
  server.listen(port, '127.0.0.1');
  return server;
}

if (require.main === module) {
  try {
    parseTimeoutMs(process.env.SERVICE_TIMEOUT_MS);
    const server = boot(Number(process.env.PORT || 8086));
    console.log(`lab4 api listening on ${server.address().port}`);
  } catch (err) {
    console.error(`FATAL ${err.message}`);
    process.exit(1);
  }
}

module.exports = { boot };
