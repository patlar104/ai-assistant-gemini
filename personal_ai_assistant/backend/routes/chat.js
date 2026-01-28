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

module.exports = router;
