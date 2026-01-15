import { createServer as createHttpServer, Server } from 'http';
import { createHelloHandler } from './routes/hello';

export function createServer(): Server {
  const server = createHttpServer((req, res) => {
    if (req.url === '/hello' && req.method === 'GET') {
      const handler = createHelloHandler();
      handler(req, res).catch((err) => {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Internal server error' }));
      });
    } else {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Not found' }));
    }
  });

  server.listen(3000, () => {
    console.log('Server listening on port 3000');
  });

  return server;
}
