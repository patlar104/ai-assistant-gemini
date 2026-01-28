const express = require('express');
const cors = require('cors');
const chatRouter = require('./routes/chat');

const createApp = () => {
  const app = express();

  app.use(cors());
  app.use(express.json());
  app.use('/api/chat', chatRouter);

  app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
  });

  return app;
};

module.exports = createApp;
