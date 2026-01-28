require('dotenv').config();

const express = require('express');
const cors = require('cors');
const http = require('http');
const { WebSocketServer, WebSocket } = require('ws');
const chatRouter = require('./routes/chat');

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());
app.use('/api/chat', chatRouter);

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

const sendJson = (socket, payload) => {
  socket.send(JSON.stringify(payload));
};

const streamReply = (socket, text) => {
  const tokens = text.split(/(\s+)/).filter(Boolean);
  let index = 0;
  const interval = setInterval(() => {
    if (socket.readyState !== WebSocket.OPEN) {
      clearInterval(interval);
      return;
    }
    if (index >= tokens.length) {
      sendJson(socket, { type: 'done' });
      clearInterval(interval);
      return;
    }
    sendJson(socket, { type: 'chunk', text: tokens[index] });
    index += 1;
  }, 120);
};

wss.on('connection', (socket) => {
  sendJson(socket, { type: 'ready' });

  socket.on('message', (raw) => {
    let payload;
    try {
      payload = JSON.parse(raw.toString());
    } catch (error) {
      sendJson(socket, { type: 'error', message: 'Invalid JSON payload' });
      return;
    }

    if (payload.type === 'user_message' && payload.message) {
      streamReply(socket, `Echo: ${payload.message}`);
      return;
    }

    sendJson(socket, { type: 'error', message: 'Unsupported message format' });
  });
});

server.listen(port, () => {
  console.log(`API listening on http://localhost:${port}`);
});
