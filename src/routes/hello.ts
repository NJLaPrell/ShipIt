import { IncomingMessage, ServerResponse } from 'http';

export function createHelloHandler() {
  return (_req: IncomingMessage, res: ServerResponse): void => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ message: 'Hello, World!' }));
  };
}
