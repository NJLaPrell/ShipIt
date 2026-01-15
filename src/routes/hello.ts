import { IncomingMessage, ServerResponse } from 'http';

export function createHelloHandler() {
  return async (req: IncomingMessage, res: ServerResponse): Promise<void> => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ message: 'Hello, World!' }));
  };
}
