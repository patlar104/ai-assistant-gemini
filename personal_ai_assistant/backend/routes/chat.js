const express = require('express');

const router = express.Router();

router.post('/', (req, res) => {
  const { message, conversationId } = req.body || {};
  if (!message) {
    return res.status(400).json({ error: 'message is required' });
  }

  return res.json({
    reply: `Echo: ${message}`,
    conversationId: conversationId || null,
    createdAt: new Date().toISOString(),
  });
});

router.post('/stream', (req, res) => {
  const { message } = req.body || {};
  if (!message) {
    return res.status(400).json({ error: 'message is required' });
  }

  res.status(200);
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  if (typeof res.flushHeaders === 'function') {
    res.flushHeaders();
  }

  const sendEvent = (event, data) => {
    res.write(`event: ${event}\n`);
    if (data !== undefined) {
      res.write(`data: ${JSON.stringify(data)}\n`);
    }
    res.write('\n');
  };

  const tokens = `Echo: ${message}`.split(/(\s+)/).filter(Boolean);
  let index = 0;
  sendEvent('ready', { ok: true });

  const interval = setInterval(() => {
    if (index >= tokens.length) {
      sendEvent('done');
      clearInterval(interval);
      res.end();
      return;
    }
    sendEvent('chunk', { text: tokens[index] });
    index += 1;
  }, 120);

  req.on('close', () => {
    clearInterval(interval);
  });
});

module.exports = router;
