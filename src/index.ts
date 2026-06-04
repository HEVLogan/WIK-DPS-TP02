import http, { IncomingMessage, ServerResponse } from 'http';

const PORT: number = parseInt(process.env.PING_LISTEN_PORT ?? '8080', 10);

const server = http.createServer((req: IncomingMessage, res: ServerResponse): void => {
  if (req.method === 'GET' && req.url === '/ping') {
    const body: string = JSON.stringify(req.headers);
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
    });
    res.end(body);
  } else {
    res.writeHead(404);
    res.end();
  }
});

server.listen(PORT, '0.0.0.0', (): void => {
  console.log(`Listening on http://0.0.0.0:${PORT}`);
});
