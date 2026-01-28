const http = require('http');
const request = require('supertest');
const createApp = require('../app');

process.env.NODE_ENV = 'test';

describe('Chat API', () => {
  jest.useRealTimers();
  jest.setTimeout(10000);
  const app = createApp();
  let server;
  let baseUrl;

  beforeAll((done) => {
    server = http.createServer(app);
    server.listen(0, () => {
      baseUrl = `http://127.0.0.1:${server.address().port}`;
      done();
    });
  });

  afterAll((done) => {
    server.close(done);
  });

  it('POST /api/chat returns a reply', async () => {
    const response = await request(app)
      .post('/api/chat')
      .send({ message: 'Hello' })
      .expect(200);

    expect(response.body.reply).toContain('Echo: Hello');
    expect(response.body.createdAt).toBeDefined();
  });

  it('POST /api/chat validates required message', async () => {
    const response = await request(app).post('/api/chat').send({});
    expect(response.status).toBe(400);
    expect(response.body.error).toBe('message is required');
  });

  it('POST /api/chat/stream streams SSE chunks', (done) => {
    let finished = false;
    let doneCalled = false;
    const req = http.request(
      `${baseUrl}/api/chat/stream`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      },
      (res) => {
        let data = '';
        res.setEncoding('utf8');
        res.on('data', (chunk) => {
          data += chunk;
          if (!finished && data.includes('event: done')) {
            finished = true;
            req.destroy();
          }
        });
        const finalize = () => {
          if (!finished || doneCalled) {
            return;
          }
          doneCalled = true;
          expect(res.headers['content-type']).toMatch(/text\/event-stream/);
          expect(data).toContain('event: chunk');
          expect(data).toContain('event: done');
          done();
        };
        res.on('end', () => {
          finished = true;
          finalize();
        });
        res.on('close', finalize);
      },
    );

    req.on('error', done);
    req.write(JSON.stringify({ message: 'Stream me' }));
    req.end();
  });

  it('GET /api/chat/stream streams SSE chunks', (done) => {
    let finished = false;
    let doneCalled = false;
    const req = http.request(
      `${baseUrl}/api/chat/stream?message=Stream%20get`,
      { method: 'GET' },
      (res) => {
        let data = '';
        res.setEncoding('utf8');
        res.on('data', (chunk) => {
          data += chunk;
          if (!finished && data.includes('event: done')) {
            finished = true;
            req.destroy();
          }
        });
        const finalize = () => {
          if (!finished || doneCalled) {
            return;
          }
          doneCalled = true;
          expect(res.headers['content-type']).toMatch(/text\/event-stream/);
          expect(data).toContain('event: chunk');
          expect(data).toContain('event: done');
          done();
        };
        res.on('end', () => {
          finished = true;
          finalize();
        });
        res.on('close', finalize);
      },
    );

    req.on('error', done);
    req.end();
  });
});
